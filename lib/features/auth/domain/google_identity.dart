import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';

/// The device's Google account picker, which yields an ID token for
/// `POST /auth/google` (and for confirming account deletion of Google-only
/// accounts). The app never sees the Google password.
abstract interface class GoogleIdentity {
  /// False when this build has no Google client configured.
  bool get isConfigured;

  /// Shows the account picker. `Ok(null)` when the user dismissed it;
  /// `FailureKind.googleNotConfigured` when [isConfigured] is false.
  Future<Result<String?>> requestIdToken();

  /// Forgets the chosen account so the picker shows again next time.
  Future<void> signOut();
}

/// Used when Google sign-in is not configured for this build.
class UnavailableGoogleIdentity implements GoogleIdentity {
  const UnavailableGoogleIdentity();

  @override
  bool get isConfigured => false;

  @override
  Future<Result<String?>> requestIdToken() async =>
      const Err(AppFailure(FailureKind.googleNotConfigured));

  @override
  Future<void> signOut() async {}
}
