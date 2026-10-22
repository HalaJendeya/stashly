import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/auth/data/token_store.dart';
import 'package:stashly/features/auth/domain/auth.dart';

/// Wire-format mapping for accounts and tokens (API v1).
abstract final class AuthMapper {
  static User user(JsonMap json) => User(
    id: json.str('id'),
    displayName: json.str('display_name'),
    email: json.str('email'),
    createdAt: json.date('created_at'),
    passwordSet: json.boolean('password_set', fallback: true),
  );

  static AuthToken token(JsonMap json) => AuthToken(
    accessToken: json.str('access_token'),
    tokenType: json.strOrNull('token_type') ?? 'Bearer',
    expiresAt: json.date('expires_at'),
  );
}

/// [AuthRepository] over the REST API (API-AUTH-001..008, API-PROF-001/002/005).
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(
    this._api,
    this._tokens, {
    this.deviceName = 'Stashly for Android',
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ApiClient _api;
  final TokenStore _tokens;
  final String deviceName;
  final DateTime Function() _clock;

  @override
  Future<bool> hasStoredSession() async {
    final token = await _tokens.read();
    return token != null && !token.isExpired(_clock().toUtc());
  }

  @override
  Future<Result<User>> register(RegistrationRequest request) => guard(() async {
    final response = await _api.post(
      '/auth/register',
      authenticated: false,
      body: {
        'display_name': request.displayName.trim(),
        'email': request.email.trim(),
        'password': request.password,
        'password_confirmation': request.password,
        'terms_accepted': request.termsAccepted,
        'terms_version': ?request.termsVersion,
        'device_name': deviceName,
      },
    );
    return _acceptSession(response.data);
  });

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) => guard(() async {
    final response = await _api.post(
      '/auth/login',
      authenticated: false,
      body: {
        'email': email.trim(),
        'password': password,
        'device_name': deviceName,
      },
    );
    return _acceptSession(response.data);
  });

  @override
  Future<Result<User>> signInWithGoogle({
    required String idToken,
    bool termsAccepted = false,
    String? termsVersion,
  }) => guard(() async {
    final response = await _api.post(
      '/auth/google',
      authenticated: false,
      body: {
        'id_token': idToken,
        'device_name': deviceName,
        if (termsAccepted) 'terms_accepted': true,
        'terms_version': ?termsVersion,
      },
    );
    return _acceptSession(response.data);
  });

  @override
  Future<Result<User>> currentUser() => guard(() async {
    final response = await _api.get('/me');
    return AuthMapper.user(response.data.obj('user'));
  });

  @override
  Future<Result<User>> updateDisplayName(String displayName) => guard(() async {
    final response = await _api.patch(
      '/me',
      body: {'display_name': displayName.trim()},
    );
    return AuthMapper.user(response.data.obj('user'));
  });

  @override
  Future<Result<void>> refreshIfNeeded() async {
    final token = await _tokens.read();
    if (token == null) {
      return const Err(AppFailure(FailureKind.unauthenticated));
    }
    if (!token.shouldRefresh(_clock().toUtc())) return const Ok(null);
    return guard(() async {
      final response = await _api.post('/auth/refresh');
      await _tokens.save(AuthMapper.token(response.data.obj('token')));
    });
  }

  @override
  Future<Result<void>> logout({bool allDevices = false}) async {
    final result = await guard(() async {
      await _api.post('/auth/logout', body: {'all_devices': allDevices});
    });
    // The local session ends even if the server could not be reached.
    await _tokens.clear();
    return result;
  }

  @override
  Future<Result<String>> forgotPassword(String email) => guard(() async {
    final response = await _api.post(
      '/auth/forgot-password',
      authenticated: false,
      body: {'email': email.trim()},
    );
    return response.data.strOrNull('message') ?? '';
  });

  @override
  Future<Result<String>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) => guard(() async {
    final response = await _api.post(
      '/auth/reset-password',
      authenticated: false,
      body: {
        'email': email.trim(),
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
    );
    return response.data.strOrNull('message') ?? '';
  });

  @override
  Future<Result<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => guard(() async {
    final response = await _api.put(
      '/me/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
    return response.data.strOrNull('message') ?? '';
  });

  @override
  Future<Result<void>> deleteAccount({
    String? password,
    String? googleIdToken,
  }) async {
    final result = await guard(() async {
      await _api.delete(
        '/me',
        body: {'password': ?password, 'id_token': ?googleIdToken},
      );
    });
    if (result.isOk) await _tokens.clear();
    return result;
  }

  @override
  Future<void> signOutLocally() => _tokens.clear();

  Future<User> _acceptSession(JsonMap data) async {
    final user = AuthMapper.user(data.obj('user'));
    await _tokens.save(AuthMapper.token(data.obj('token')));
    return user;
  }
}
