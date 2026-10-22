import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/features/auth/domain/auth.dart';

/// Persists the bearer token. Implementations must use platform-protected
/// storage; tokens never go to plain preferences or logs (CLAUDE.md §7).
abstract class TokenStore implements AccessTokenSource {
  Future<AuthToken?> read();
  Future<void> save(AuthToken token);
  Future<void> clear();

  @override
  Future<String?> accessToken() async => (await read())?.accessToken;
}

/// [TokenStore] backed by the Android Keystore / iOS Keychain.
class SecureTokenStore extends TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'stashly.access_token';
  static const _expiresKey = 'stashly.access_token_expires_at';

  final FlutterSecureStorage _storage;
  AuthToken? _cached;
  bool _loaded = false;

  @override
  Future<AuthToken?> read() async {
    if (_loaded) return _cached;
    final token = await _storage.read(key: _tokenKey);
    final expires = DateTime.tryParse(
      await _storage.read(key: _expiresKey) ?? '',
    );
    _loaded = true;
    _cached = token == null || expires == null
        ? null
        : AuthToken(accessToken: token, expiresAt: expires.toUtc());
    return _cached;
  }

  @override
  Future<void> save(AuthToken token) async {
    await _storage.write(key: _tokenKey, value: token.accessToken);
    await _storage.write(
      key: _expiresKey,
      value: token.expiresAt.toUtc().toIso8601String(),
    );
    _cached = token;
    _loaded = true;
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresKey);
    _cached = null;
    _loaded = true;
  }
}

/// In-memory [TokenStore] for tests.
class MemoryTokenStore extends TokenStore {
  MemoryTokenStore([this.token]);

  AuthToken? token;

  @override
  Future<AuthToken?> read() async => token;

  @override
  Future<void> save(AuthToken token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}
