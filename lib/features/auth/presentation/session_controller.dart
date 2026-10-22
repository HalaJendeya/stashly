import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/storage/key_value_store.dart';
import 'package:stashly/features/app_config/domain/app_config.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/domain/google_identity.dart';
import 'package:stashly/features/search/domain/search.dart';

enum SessionStatus { unknown, signedOut, signedIn }

/// App-wide session state: who is signed in, server config, onboarding and a
/// link shared while signed out. Drives router redirects.
class SessionController extends ChangeNotifier {
  SessionController({
    required this._auth,
    required this._google,
    required AppConfigRepository config,
    required this._preferences,
    required this._recentSearches,
    required Stream<void> unauthenticatedEvents,
    required this.appVersion,
  }) : _configRepository = config {
    _unauthenticated = unauthenticatedEvents.listen((_) => _expireSession());
  }

  static const _onboardingKey = 'onboarding_seen';

  final AuthRepository _auth;
  final GoogleIdentity _google;
  final AppConfigRepository _configRepository;
  final KeyValueStore _preferences;
  final RecentSearchStore _recentSearches;
  final String appVersion;
  late final StreamSubscription<void> _unauthenticated;

  SessionStatus _status = SessionStatus.unknown;
  SessionStatus get status => _status;

  User? _user;
  User? get user => _user;

  AppConfig _config = AppConfig.fallback;
  AppConfig get config => _config;

  bool _onboardingSeen = false;
  bool get onboardingSeen => _onboardingSeen;

  bool get updateRequired => _config.requiresUpdate(appVersion);

  /// Link shared from another app before sign-in; resumed afterwards.
  String? pendingSharedText;

  /// Set when the server rejected the stored token, to explain the sign-out.
  bool sessionExpired = false;

  Future<void> bootstrap() async {
    final seen = await _preferences.read(_onboardingKey);
    _onboardingSeen = seen == true;
    // Config is best-effort: the app works with documented defaults.
    unawaited(loadConfig());

    if (!await _auth.hasStoredSession()) {
      _setStatus(SessionStatus.signedOut);
      return;
    }
    await _auth.refreshIfNeeded();
    final result = await _auth.currentUser();
    switch (result) {
      case Ok(:final value):
        _user = value;
        _setStatus(SessionStatus.signedIn);
      case Err(:final failure) when failure.kind == FailureKind.unauthenticated:
        await _auth.signOutLocally();
        _setStatus(SessionStatus.signedOut);
      case Err():
        // Offline or server trouble: keep the session; screens show their
        // own retryable error states and the profile loads later.
        _setStatus(SessionStatus.signedIn);
    }
  }

  Future<void> loadConfig() async {
    final result = await _configRepository.fetchConfig();
    if (result case Ok(:final value)) {
      _config = value;
      notifyListeners();
    }
  }

  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) => _completeSignIn(_auth.login(email: email, password: password));

  Future<Result<User>> register(RegistrationRequest request) =>
      _completeSignIn(_auth.register(request));

  /// Google sign-in is offered whenever the server supports it (`GET /config`
  /// → `auth.google_enabled`). A build without a Google client ID still shows
  /// the button and explains the problem on tap instead of hiding it.
  bool get googleAvailable => _config.googleEnabled;

  /// ID token kept between a "terms required" answer and the retry, so the
  /// user doesn't pick their account twice. Tokens live about an hour.
  String? _pendingGoogleToken;

  /// Signs in, links or registers with Google. `Ok(null)` when the user
  /// dismissed the account picker. A new account needs [termsAccepted]; the
  /// server answers 422 on `terms_accepted` otherwise (see [needsTerms]).
  Future<Result<User?>> signInWithGoogle({bool termsAccepted = false}) async {
    var idToken = _pendingGoogleToken;
    _pendingGoogleToken = null;
    if (idToken == null) {
      final picked = await _google.requestIdToken();
      switch (picked) {
        case Err(:final failure):
          return Err(failure);
        case Ok(value: null):
          return const Ok(null);
        case Ok(:final value?):
          idToken = value;
      }
    }
    final result = await _completeSignIn(
      _auth.signInWithGoogle(
        idToken: idToken,
        termsAccepted: termsAccepted,
        termsVersion: termsAccepted ? _config.termsVersion : null,
      ),
    );
    if (result case Err(:final failure) when needsTerms(failure)) {
      _pendingGoogleToken = idToken;
    }
    return result;
  }

  /// The user declined the Terms; forget the ID token kept for the retry.
  void discardPendingGoogleSignIn() => _pendingGoogleToken = null;

  /// True when a Google sign-in failed only because a new account must
  /// accept the terms first.
  static bool needsTerms(AppFailure failure) =>
      failure.kind == FailureKind.validation &&
      failure.fieldError('terms_accepted') != null;

  /// A fresh Google ID token to confirm a sensitive action (account
  /// deletion) on a Google-only account. `Ok(null)` when dismissed.
  Future<Result<String?>> confirmWithGoogle() => _google.requestIdToken();

  Future<Result<User>> _completeSignIn(Future<Result<User>> call) async {
    final result = await call;
    if (result case Ok(:final value)) {
      _user = value;
      sessionExpired = false;
      await markOnboardingSeen();
      _setStatus(SessionStatus.signedIn);
    }
    return result;
  }

  Future<void> refreshUser() async {
    final result = await _auth.currentUser();
    if (result case Ok(:final value)) {
      _user = value;
      notifyListeners();
    }
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    if (_onboardingSeen) return;
    _onboardingSeen = true;
    await _preferences.write(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> signOut({bool allDevices = false}) async {
    await _auth.logout(allDevices: allDevices);
    await _clearLocalState();
  }

  /// Called after the account was deleted on the server.
  Future<void> accountDeleted() => _clearLocalState();

  Future<void> _expireSession() async {
    if (_status != SessionStatus.signedIn) return;
    sessionExpired = true;
    await _auth.signOutLocally();
    await _clearLocalState();
  }

  Future<void> _clearLocalState() async {
    _user = null;
    pendingSharedText = null;
    _pendingGoogleToken = null;
    // Otherwise the next Google sign-in silently reuses this account.
    await _google.signOut();
    // Recent searches are personal; they never outlive the session.
    await _recentSearches.clear();
    _setStatus(SessionStatus.signedOut);
  }

  void _setStatus(SessionStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _unauthenticated.cancel();
    super.dispose();
  }
}
