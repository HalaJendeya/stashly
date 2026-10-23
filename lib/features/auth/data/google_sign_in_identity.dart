import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInException, GoogleSignInExceptionCode;

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/auth/domain/google_identity.dart';

/// [GoogleIdentity] over `google_sign_in` (Credential Manager on Android).
class GoogleSignInIdentity implements GoogleIdentity {
  GoogleSignInIdentity({required this._serverClientId, GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;

  final String _serverClientId;
  final GoogleSignIn _signIn;
  Future<void>? _initialized;

  @override
  bool get isConfigured => _serverClientId.isNotEmpty;

  Future<void> _ensureInitialized() =>
      _initialized ??= _signIn.initialize(serverClientId: _serverClientId);

  @override
  Future<Result<String?>> requestIdToken() async {
    if (!isConfigured) {
      return const Err(AppFailure(FailureKind.googleNotConfigured));
    }
    try {
      await _ensureInitialized();
      if (!_signIn.supportsAuthenticate()) {
        return const Err(AppFailure(FailureKind.googleUnavailable));
      }
      final account = await _signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const Err(AppFailure(FailureKind.googleUnavailable));
      }
      return Ok(idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return const Ok(null);
      }
      // The code is safe to log; descriptions never include the token.
      log('Google sign-in failed: ${error.code}', name: 'auth');
      // A failed attempt must not leave a broken initialization cached.
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        _initialized = null;
      }
      return const Err(AppFailure(FailureKind.googleUnavailable));
    }
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured || _initialized == null) return;
    try {
      await _signIn.signOut();
    } on GoogleSignInException catch (error) {
      log('Google sign-out failed: ${error.code}', name: 'auth');
    }
  }
}
