import 'package:stashly/core/result/result.dart';

/// Public app configuration (`GET /config`). Release fields may be null
/// until the server environment configures them.
class AppConfig {
  const AppConfig({
    required this.apiVersion,
    required this.minSupportedAppVersion,
    required this.latestAppVersion,
    required this.termsVersion,
    required this.termsUrl,
    required this.privacyUrl,
    required this.googleEnabled,
    required this.limits,
  });

  /// Used when the config cannot be loaded; mirrors the documented limits.
  static const fallback = AppConfig(
    apiVersion: '1.0',
    minSupportedAppVersion: null,
    latestAppVersion: null,
    termsVersion: null,
    termsUrl: null,
    privacyUrl: null,
    googleEnabled: false,
    limits: {},
  );

  final String apiVersion;
  final String? minSupportedAppVersion;
  final String? latestAppVersion;
  final String? termsVersion;
  final String? termsUrl;
  final String? privacyUrl;
  final bool googleEnabled;
  final Map<String, int> limits;

  int limit(String key, int fallbackValue) => limits[key] ?? fallbackValue;

  int get titleMaxLength => limit('title_max_length', 300);
  int get noteMaxLength => limit('note_max_length', 2000);
  int get tagMaxLength => limit('tag_max_length', 40);
  int get tagsPerLinkMax => limit('tags_per_link_max', 20);
  int get collectionNameMaxLength => limit('collection_name_max_length', 60);
  int get collectionDescriptionMaxLength =>
      limit('collection_description_max_length', 300);

  /// True when [appVersion] is older than the minimum the server supports.
  bool requiresUpdate(String appVersion) {
    final minimum = minSupportedAppVersion;
    return minimum != null && compareVersions(appVersion, minimum) < 0;
  }

  static int compareVersions(String a, String b) {
    List<int> parts(String v) =>
        v.split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final left = parts(a);
    final right = parts(b);
    for (var i = 0; i < 3; i++) {
      final l = i < left.length ? left[i] : 0;
      final r = i < right.length ? right[i] : 0;
      if (l != r) return l.compareTo(r);
    }
    return 0;
  }
}

/// Service health (`GET /health`).
class ServiceHealth {
  const ServiceHealth({required this.healthy, required this.checks});

  final bool healthy;
  final Map<String, String> checks;
}

abstract interface class AppConfigRepository {
  Future<Result<AppConfig>> fetchConfig();
  Future<Result<ServiceHealth>> checkHealth();
}
