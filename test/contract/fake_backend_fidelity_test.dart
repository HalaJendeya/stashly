// Guards the scenario tests: the in-memory fake backend must answer every
// documented request with (at least) the fields the Postman examples show.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/fake_backend/fake_backend.dart';

const _email = 'fidelity@stashly.test';
const _password = 'fidelity-pass-1';

/// Every key in [expected] must exist in [actual], recursively.
List<String> _missingKeys(Object? expected, Object? actual, String path) {
  final missing = <String>[];
  if (expected is Map && actual is Map) {
    for (final key in expected.keys) {
      if (!actual.containsKey(key)) {
        missing.add('$path.$key');
      } else if (expected[key] != null && actual[key] != null) {
        missing.addAll(_missingKeys(expected[key], actual[key], '$path.$key'));
      }
    }
  } else if (expected is List &&
      actual is List &&
      expected.isNotEmpty &&
      actual.isNotEmpty) {
    missing.addAll(_missingKeys(expected.first, actual.first, '$path[0]'));
  }
  return missing;
}

void main() {
  final root =
      jsonDecode(
            File(
              'test/fixtures/stashly_api_v1_examples.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  final requests = <Map<String, dynamic>>[
    for (final folder in (root['item'] as List).cast<Map<String, dynamic>>())
      ...(folder['item'] as List).cast<Map<String, dynamic>>(),
  ];

  for (final item in requests) {
    final successes = (item['response'] as List)
        .cast<Map<String, dynamic>>()
        .where((r) => (r['code'] as int) < 300)
        .toList();
    if (successes.isEmpty || item['name'] == 'Sign in with Google') continue;

    test('fake backend honours "${item['name']}"', () {
      final backend = FakeStashlyBackend(readsUntilMetadataReady: 1);
      final token = backend.seedUser(
        name: 'Fidelity',
        email: _email,
        password: _password,
      );
      final collectionId = backend.seedCollection(
        token,
        'Reading list',
        description: 'Read later',
      );
      final linkId = backend.seedLink(
        token,
        'https://example.com/post',
        title: 'Postman test link',
        collectionIds: [collectionId],
        tags: ['postman'],
      );

      final request = item['request'] as Map<String, dynamic>;
      String substitute(String text) => text
          .replaceAll('{{base_url}}', '')
          .replaceAll('{{link_id}}', linkId)
          .replaceAll('{{collection_id}}', collectionId)
          .replaceAll(
            '{{user_email}}',
            item['name'] == 'Register' ? 'new@stashly.test' : _email,
          )
          .replaceAll('{{user_password}}', _password)
          .replaceAll('{{initial_password}}', _password)
          .replaceAll('{{new_password}}', 'fidelity-pass-2')
          .replaceAll('{{reset_token}}', 'valid-reset-token')
          .replaceAll('{{\$timestamp}}', '1')
          .replaceAll('{{\$guid}}', '00000000-0000-4000-8000-000000000000');

      final uri = Uri.parse(
        'http://fake${substitute(request['url'] as String)}',
      );
      var body = substitute(request['body'] as String? ?? '');
      if (item['name'] == 'Set link collections') {
        body = jsonEncode({
          'collection_ids': [collectionId],
        });
      }
      final isPublic = request['auth'] == 'noauth';
      final response = backend.handle(
        FakeRequest(
          method: request['method'] as String,
          path: uri.path,
          query: uri.queryParameters,
          headers: {
            if (!isPublic) 'authorization': 'Bearer $token',
            if (item['name'] == 'Create link')
              'idempotency-key': 'fidelity-key',
          },
          body: body,
        ),
      );

      final documentedCodes = successes.map((s) => s['code'] as int).toSet();
      expect(documentedCodes, contains(response.status), reason: response.body);
      final example = successes.firstWhere(
        (s) => s['code'] == response.status,
        orElse: () => successes.first,
      );
      final exampleBody = example['body'] as String? ?? '';
      if (exampleBody.isEmpty) {
        expect(response.body, isEmpty);
        return;
      }
      final missing = _missingKeys(
        jsonDecode(exampleBody),
        jsonDecode(response.body),
        r'$',
      );
      expect(missing, isEmpty, reason: 'fake response lacks documented fields');
    });
  }
}
