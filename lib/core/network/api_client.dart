import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';

/// Supplies the bearer token for authenticated calls.
abstract interface class AccessTokenSource {
  Future<String?> accessToken();
}

/// A non-2xx response or transport problem, already mapped to [AppFailure].
final class ApiException implements Exception {
  const ApiException(this.failure, {this.statusCode});

  final AppFailure failure;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode, $failure)';
}

/// A successful (2xx) response.
final class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.bytes,
    required this.json,
  });

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bytes;

  /// Decoded body, or `null` for empty bodies (204) and non-JSON downloads.
  final Object? json;

  /// The `data` object of the standard `{ "data": ... }` envelope.
  JsonMap get data {
    final body = json;
    if (body is JsonMap && body['data'] is JsonMap) {
      return body['data'] as JsonMap;
    }
    throw const FormatException('Expected {"data": {...}} envelope');
  }

  /// The `data` list of a paginated envelope.
  List<JsonMap> get dataList {
    final body = json;
    if (body is JsonMap && body['data'] is List) {
      return [
        for (final item in body['data'] as List)
          if (item is JsonMap)
            item
          else
            throw const FormatException('Expected objects in data list'),
      ];
    }
    throw const FormatException('Expected {"data": [...]} envelope');
  }

  /// The `meta` object of a paginated envelope.
  JsonMap get meta {
    final body = json;
    if (body is JsonMap && body['meta'] is JsonMap) {
      return body['meta'] as JsonMap;
    }
    return const {};
  }
}

/// Thin JSON-over-HTTPS client for the Stashly REST API (`/api/v1`).
///
/// Lives in `core` only as shared plumbing; it is used exclusively by the
/// `data` layers of features (CLAUDE.md §3).
class ApiClient {
  ApiClient({
    required this.baseUri,
    required http.Client httpClient,
    required this._tokens,
    this.appVersion = '1.0.0',
    this.timeout = const Duration(seconds: 20),
  }) : _http = httpClient {
    // Release builds must never talk to the API in clear text (CLAUDE.md §7).
    if (_isRelease && baseUri.scheme != 'https') {
      throw StateError('API base URL must use https in release builds.');
    }
  }

  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');

  final Uri baseUri;
  final String appVersion;
  final Duration timeout;
  final http.Client _http;
  final AccessTokenSource _tokens;

  final _unauthenticated = StreamController<void>.broadcast();

  /// Fires when an authenticated call is rejected with 401 (token revoked or
  /// expired) so the session can sign out locally.
  Stream<void> get onUnauthenticated => _unauthenticated.stream;

  Future<ApiResponse> get(
    String path, {
    Map<String, Object?> query = const {},
    bool authenticated = true,
    Duration? timeout,
  }) => send(
    'GET',
    path,
    query: query,
    authenticated: authenticated,
    timeout: timeout,
  );

  Future<ApiResponse> post(
    String path, {
    Object? body,
    bool authenticated = true,
    Map<String, String> headers = const {},
    Duration? timeout,
  }) => send(
    'POST',
    path,
    body: body,
    authenticated: authenticated,
    headers: headers,
    timeout: timeout,
  );

  Future<ApiResponse> patch(String path, {Object? body}) =>
      send('PATCH', path, body: body);

  Future<ApiResponse> put(String path, {Object? body}) =>
      send('PUT', path, body: body);

  Future<ApiResponse> delete(String path, {Object? body}) =>
      send('DELETE', path, body: body);

  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, Object?> query = const {},
    Object? body,
    bool authenticated = true,
    Map<String, String> headers = const {},
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, query);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'X-App-Version': appVersion,
        'X-Platform': Platform.isIOS ? 'ios' : 'android',
        ...headers,
      });

    if (authenticated) {
      final token = await _tokens.accessToken();
      if (token == null) {
        throw const ApiException(AppFailure(FailureKind.unauthenticated));
      }
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamed = await _http
          .send(request)
          .timeout(timeout ?? this.timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      _log(method, uri, 'timeout');
      throw const ApiException(AppFailure(FailureKind.timeout));
    } on SocketException {
      _log(method, uri, 'offline');
      throw const ApiException(AppFailure(FailureKind.offline));
    } on http.ClientException {
      _log(method, uri, 'client error');
      throw const ApiException(AppFailure(FailureKind.offline));
    }

    _log(method, uri, '${response.statusCode}');
    final decoded = _decode(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        bytes: response.bodyBytes,
        json: decoded,
      );
    }

    final failure = failureFromResponse(
      response.statusCode,
      decoded,
      response.headers,
    );
    if (authenticated && failure.kind == FailureKind.unauthenticated) {
      _unauthenticated.add(null);
    }
    throw ApiException(failure, statusCode: response.statusCode);
  }

  Uri _buildUri(String path, Map<String, Object?> query) {
    final params = <String, String>{};
    for (final MapEntry(:key, :value) in query.entries) {
      switch (value) {
        case null:
          continue;
        case Iterable<Object?> list when list.isEmpty:
          continue;
        case Iterable<Object?> list:
          params[key] = list.join(',');
        case _:
          params[key] = value.toString();
      }
    }
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    return baseUri.replace(
      path: '$basePath$path',
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Object? _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    final type = response.headers['content-type'] ?? '';
    if (!type.contains('json')) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  /// Logs method, path and status only: never query strings (they may carry
  /// user URLs or search terms) and never headers (they carry the token).
  void _log(String method, Uri uri, String outcome) {
    assert(() {
      developer.log('$method ${uri.path} -> $outcome', name: 'stashly.api');
      return true;
    }());
  }

  void dispose() {
    _unauthenticated.close();
    _http.close();
  }
}

/// Maps an error response to a typed failure using `error.code` first and the
/// HTTP status as a fallback.
AppFailure failureFromResponse(
  int status,
  Object? body,
  Map<String, String> headers,
) {
  final error = body is JsonMap && body['error'] is JsonMap
      ? body['error'] as JsonMap
      : const <String, dynamic>{};
  final code = error['code'] is String ? error['code'] as String : null;
  final details = error['details'];

  final kind = switch (code) {
    'VALIDATION_FAILED' => FailureKind.validation,
    'INVALID_URL' => FailureKind.invalidUrl,
    'INVALID_CURSOR' => FailureKind.invalidCursor,
    'LIMIT_EXCEEDED' => FailureKind.limitExceeded,
    'TOKEN_INVALID_OR_EXPIRED' => FailureKind.tokenInvalidOrExpired,
    'INVALID_CREDENTIALS' => FailureKind.invalidCredentials,
    'INVALID_GOOGLE_TOKEN' => FailureKind.invalidGoogleToken,
    'UNAUTHENTICATED' => FailureKind.unauthenticated,
    'FORBIDDEN' => FailureKind.forbidden,
    'NOT_FOUND' => FailureKind.notFound,
    'DUPLICATE_LINK' => FailureKind.duplicateLink,
    'RATE_LIMITED' => FailureKind.rateLimited,
    'SERVER_ERROR' => FailureKind.server,
    'SERVICE_UNAVAILABLE' => FailureKind.serviceUnavailable,
    _ => switch (status) {
      401 => FailureKind.unauthenticated,
      403 => FailureKind.forbidden,
      404 => FailureKind.notFound,
      409 => FailureKind.duplicateLink,
      422 => FailureKind.validation,
      429 => FailureKind.rateLimited,
      503 => FailureKind.serviceUnavailable,
      >= 500 => FailureKind.server,
      _ => FailureKind.unknown,
    },
  };

  final fieldErrors = <String, List<String>>{};
  if (details is JsonMap) {
    for (final MapEntry(:key, :value) in details.entries) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      }
    }
  }

  final retryAfterSeconds = int.tryParse(headers['retry-after'] ?? '');

  return AppFailure(
    kind,
    code: code,
    // 5xx messages are never shown to users (they may be generic or leaky).
    message: status >= 500 || error['message'] is! String
        ? null
        : error['message'] as String,
    fieldErrors: fieldErrors,
    retryAfter: retryAfterSeconds == null
        ? null
        : Duration(seconds: retryAfterSeconds),
    requestId: error['request_id'] is String
        ? error['request_id'] as String
        : null,
    payload: details is JsonMap ? details : null,
  );
}

/// Runs a repository call and converts transport/shape problems to [Result].
Future<Result<T>> guard<T>(Future<T> Function() call) async {
  try {
    return Ok(await call());
  } on ApiException catch (error) {
    return Err(error.failure);
  } on FormatException catch (error) {
    developer.log(
      'Unexpected response shape: ${error.message}',
      name: 'stashly.api',
    );
    return const Err(AppFailure(FailureKind.unknown));
  }
}
