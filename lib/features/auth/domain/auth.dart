import 'package:stashly/core/result/result.dart';

/// The signed-in account (`user` object of the API).
class User {
  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.passwordSet,
  });

  final String id;
  final String displayName;
  final String email;
  final DateTime createdAt;

  /// False for Google-only accounts; they confirm sensitive actions with a
  /// fresh Google ID token instead of a password.
  final bool passwordSet;

  String get firstName => displayName.trim().split(RegExp(r'\s+')).first;
}

/// Bearer token issued by register, login, Google sign-in and refresh.
class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  /// Tokens live 60 days; the app refreshes after 30 (API-AUTH-004).
  bool shouldRefresh(DateTime now) =>
      expiresAt.difference(now) < const Duration(days: 30);

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);
}

class RegistrationRequest {
  const RegistrationRequest({
    required this.displayName,
    required this.email,
    required this.password,
    required this.termsAccepted,
    this.termsVersion,
  });

  final String displayName;
  final String email;
  final String password;
  final bool termsAccepted;
  final String? termsVersion;
}

/// Account lifecycle and session operations.
///
/// Implementations persist the issued token so the session survives restarts;
/// [signOutLocally] wipes it without calling the server.
abstract interface class AuthRepository {
  /// True when a non-expired token is stored on the device.
  Future<bool> hasStoredSession();

  Future<Result<User>> register(RegistrationRequest request);
  Future<Result<User>> login({required String email, required String password});

  /// Google sign-in / link / register with an Android ID token (DEC-035).
  Future<Result<User>> signInWithGoogle({
    required String idToken,
    bool termsAccepted = false,
    String? termsVersion,
  });

  Future<Result<User>> currentUser();
  Future<Result<User>> updateDisplayName(String displayName);

  /// Swaps the token when it is older than 30 days; no-op otherwise.
  Future<Result<void>> refreshIfNeeded();

  Future<Result<void>> logout({bool allDevices = false});
  Future<Result<String>> forgotPassword(String email);
  Future<Result<String>> resetPassword({
    required String email,
    required String token,
    required String password,
  });
  Future<Result<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Deletes the account. Password accounts send [password]; Google-only
  /// accounts send a fresh [googleIdToken].
  Future<Result<void>> deleteAccount({String? password, String? googleIdToken});

  Future<void> signOutLocally();
}
