import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/app_config/domain/app_config.dart';

/// [AppConfigRepository] over the public `GET /config` and `GET /health`.
class HttpAppConfigRepository implements AppConfigRepository {
  HttpAppConfigRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AppConfig>> fetchConfig() => guard(() async {
    final data = (await _api.get('/config', authenticated: false)).data;
    final terms = data.objOrNull('terms');
    final privacy = data.objOrNull('privacy');
    final auth = data.objOrNull('auth');
    final limits = data.objOrNull('limits') ?? const {};
    return AppConfig(
      apiVersion: data.strOrNull('api_version') ?? '1.0',
      minSupportedAppVersion: _nonBlank(
        data.strOrNull('min_supported_app_version'),
      ),
      latestAppVersion: _nonBlank(data.strOrNull('latest_app_version')),
      termsVersion: terms?.strOrNull('version'),
      termsUrl: terms?.strOrNull('url'),
      privacyUrl: privacy?.strOrNull('url'),
      googleEnabled: auth?.boolean('google_enabled', fallback: false) ?? false,
      limits: {
        for (final MapEntry(:key, :value) in limits.entries)
          if (value is num) key: value.toInt(),
      },
    );
  });

  @override
  Future<Result<ServiceHealth>> checkHealth() async {
    final result = await guard(() async {
      final data = (await _api.get('/health', authenticated: false)).data;
      return _health(data);
    });
    // 503 carries the health body in error.details; it is a valid answer.
    if (result case Err(:final failure)
        when failure.kind == FailureKind.serviceUnavailable &&
            failure.payload is JsonMap) {
      return Ok(_health(failure.payload! as JsonMap));
    }
    return result;
  }

  ServiceHealth _health(JsonMap data) {
    final checks = data.objOrNull('checks') ?? const {};
    return ServiceHealth(
      healthy: data.strOrNull('status') == 'ok',
      checks: {
        for (final MapEntry(:key, :value) in checks.entries) key: '$value',
      },
    );
  }
}

/// The deployed server sends `""` for release fields it hasn't configured.
String? _nonBlank(String? value) =>
    value == null || value.trim().isEmpty ? null : value;
