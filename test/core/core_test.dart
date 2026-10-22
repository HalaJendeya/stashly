import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/format/date_labels.dart';
import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/idempotency.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/url/url_utils.dart';
import 'package:stashly/core/widgets/pickers.dart';
import 'package:stashly/features/app_config/domain/app_config.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

void main() {
  group('UrlUtils', () {
    test('accepts http(s) and adds https to bare hosts', () {
      expect(
        UrlUtils.prepareForSave('  example.com/a '),
        'https://example.com/a',
      );
      expect(
        UrlUtils.prepareForSave('http://example.com'),
        'http://example.com',
      );
      expect(
        UrlUtils.prepareForSave('https://youtu.be/x'),
        'https://youtu.be/x',
      );
    });

    test('rejects dangerous or invalid schemes (CLAUDE.md §7)', () {
      for (final bad in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'intent://scan#Intent;end',
        'data:text/html,hi',
        'ftp://example.com',
        'https://user:pass@example.com',
        'not a url',
        '',
      ]) {
        expect(UrlUtils.prepareForSave(bad), isNull, reason: bad);
        expect(UrlUtils.validationMessage(bad), isNotNull, reason: bad);
      }
    });

    test('enforces the 2048 character limit', () {
      final long = 'https://example.com/${'a' * 2040}';
      expect(UrlUtils.prepareForSave(long), isNull);
      expect(UrlUtils.validationMessage(long), contains('2048'));
    });

    test('extracts the first link from shared text and trims punctuation', () {
      expect(
        UrlUtils.extractFromSharedText(
          'Look at this https://example.com/post).',
        ),
        'https://example.com/post',
      );
      expect(
        UrlUtils.extractFromSharedText('www.example.com/x'),
        'https://www.example.com/x',
      );
      expect(UrlUtils.extractFromSharedText('no link here'), isNull);
    });

    test('displayHost strips www', () {
      expect(
        UrlUtils.displayHost('https://www.design-milk.com/a'),
        'design-milk.com',
      );
    });
  });

  group('failureFromResponse', () {
    test('maps documented codes and keeps field errors', () {
      final failure = failureFromResponse(422, {
        'error': {
          'code': 'VALIDATION_FAILED',
          'message': 'The given data was invalid.',
          'details': {
            'tags.1': ['bad tag'],
          },
          'request_id': 'r1',
        },
      }, const {});
      expect(failure.kind, FailureKind.validation);
      expect(failure.fieldError('tags'), 'bad tag');
      expect(failure.requestId, 'r1');
    });

    test('falls back to the HTTP status and hides 5xx messages', () {
      final failure = failureFromResponse(500, {
        'error': {'message': 'SQLSTATE[42S02] leaked'},
      }, const {});
      expect(failure.kind, FailureKind.server);
      expect(failure.message, isNull);
      expect(
        failureFromResponse(404, null, const {}).kind,
        FailureKind.notFound,
      );
      expect(
        failureFromResponse(503, null, const {}).kind,
        FailureKind.serviceUnavailable,
      );
    });

    test('reads Retry-After for rate limits', () {
      final failure = failureFromResponse(429, null, const {
        'retry-after': '37',
      });
      expect(failure.kind, FailureKind.rateLimited);
      expect(failure.retryAfter, const Duration(seconds: 37));
      expect(failure.userMessage, contains('37'));
    });
  });

  test('idempotency keys are random UUID v4', () {
    final a = newIdempotencyKey();
    final b = newIdempotencyKey();
    expect(
      a,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(a, isNot(b));
  });

  group('AppConfig', () {
    test('compares semantic versions', () {
      expect(AppConfig.compareVersions('1.0.0', '1.0.0'), 0);
      expect(AppConfig.compareVersions('1.2.0', '1.10.0'), lessThan(0));
      expect(AppConfig.compareVersions('2.0', '1.9.9'), greaterThan(0));
      expect(AppConfig.compareVersions('1.0.0+5', '1.0.0'), 0);
    });

    test('requires an update only below the minimum', () {
      const config = AppConfig(
        apiVersion: '1.0',
        minSupportedAppVersion: '1.1.0',
        latestAppVersion: '1.2.0',
        termsVersion: null,
        termsUrl: null,
        privacyUrl: null,
        googleEnabled: false,
        limits: {'tags_per_link_max': 15},
      );
      expect(config.requiresUpdate('1.0.9'), isTrue);
      expect(config.requiresUpdate('1.1.0'), isFalse);
      expect(config.tagsPerLinkMax, 15);
      expect(config.noteMaxLength, 2000, reason: 'documented default');
      expect(AppConfig.fallback.requiresUpdate('0.0.1'), isFalse);
    });
  });

  group('DateLabels', () {
    final now = DateTime(2026, 10, 16, 21);
    test('relative days', () {
      expect(
        DateLabels.relativeDay(DateTime(2026, 10, 16, 8), now: now),
        'Today',
      );
      expect(
        DateLabels.relativeDay(DateTime(2026, 10, 15, 23), now: now),
        'Yesterday',
      );
      expect(DateLabels.relativeDay(DateTime(2026, 9, 18), now: now), 'Sep 18');
      expect(
        DateLabels.relativeDay(DateTime(2025, 9, 18), now: now),
        'Sep 18, 2025',
      );
    });

    test('home eyebrow and greeting', () {
      expect(DateLabels.eyebrowDate(now), 'FRIDAY, OCTOBER 16');
      expect(DateLabels.greeting(now), 'Good evening');
      expect(DateLabels.greeting(DateTime(2026, 1, 1, 9)), 'Good morning');
      expect(DateLabels.monthYear(DateTime(2025, 10, 2)), 'October 2025');
    });
  });

  test('tag input is normalized like the server (trim, #, case, spaces)', () {
    expect(TagEditorSheet.normalize('  #Design   Systems '), 'design systems');
    expect(parseTagInput('travel, #Italy,  film , travel,,'), [
      'travel',
      'italy',
      'film',
    ]);
  });

  group('PagedController', () {
    Paged<String> page(List<String> items, {String? next}) =>
        Paged(items: items, nextCursor: next, hasMore: next != null, total: 5);

    test(
      'loads, appends without duplicates and stops at the last page',
      () async {
        final calls = <String?>[];
        final controller = PagedController<String>(
          fetch: (cursor) async {
            calls.add(cursor);
            return Ok(
              cursor == null ? page(['a', 'b'], next: 'c1') : page(['b', 'c']),
            );
          },
          idOf: (s) => s,
        );
        await controller.refresh();
        expect(controller.items, ['a', 'b']);
        expect(controller.hasMore, isTrue);
        expect(controller.total, 5);
        await controller.loadMore();
        expect(controller.items, ['a', 'b', 'c']);
        expect(controller.hasMore, isFalse);
        await controller.loadMore();
        expect(calls, [null, 'c1']);
      },
    );

    test(
      'restarts from the first page when the cursor became invalid',
      () async {
        var first = true;
        final controller = PagedController<String>(
          fetch: (cursor) async {
            if (cursor == null) {
              final result = first ? page(['a'], next: 'stale') : page(['x']);
              first = false;
              return Ok(result);
            }
            return const Err(AppFailure(FailureKind.invalidCursor));
          },
          idOf: (s) => s,
        );
        await controller.refresh();
        await controller.loadMore();
        expect(controller.items, ['x']);
        expect(controller.failure, isNull);
      },
    );

    test('keeps loaded items when "load more" fails', () async {
      final controller = PagedController<String>(
        fetch: (cursor) async => cursor == null
            ? Ok(page(['a'], next: 'n'))
            : const Err(AppFailure(FailureKind.offline)),
        idOf: (s) => s,
      );
      await controller.refresh();
      await controller.loadMore();
      expect(controller.items, ['a']);
      expect(controller.loadMoreFailure?.kind, FailureKind.offline);
    });

    test('local replace and remove keep the total in sync', () async {
      final controller = PagedController<String>(
        fetch: (_) async => Ok(page(['a', 'b'])),
        idOf: (s) => s,
      );
      await controller.refresh();
      controller.remove('a');
      expect(controller.items, ['b']);
      expect(controller.total, 4);
    });
  });
}
