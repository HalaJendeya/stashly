/// What went wrong, independent of transport. Mirrors the API error codes
/// (`error.code`) plus client-side network conditions.
enum FailureKind {
  validation,
  invalidUrl,
  invalidCursor,
  limitExceeded,
  tokenInvalidOrExpired,
  invalidCredentials,
  invalidGoogleToken,

  /// Google sign-in could not run on this device (not configured, no
  /// Google Play services, or the picker failed).
  googleUnavailable,

  /// This build has no Google client ID (`GOOGLE_SERVER_CLIENT_ID`).
  googleNotConfigured,
  unauthenticated,
  forbidden,
  notFound,
  duplicateLink,
  rateLimited,
  server,
  serviceUnavailable,
  offline,
  timeout,
  unknown,
}

/// A typed, user-presentable failure. Never carries tokens or credentials.
final class AppFailure {
  const AppFailure(
    this.kind, {
    this.code,
    this.message,
    this.fieldErrors = const {},
    this.retryAfter,
    this.requestId,
    this.payload,
  });

  final FailureKind kind;

  /// Raw API `error.code` when the server sent one.
  final String? code;

  /// Server message; only shown for validation details, never for 5xx.
  final String? message;

  /// `error.details` for `VALIDATION_FAILED` (`field` -> messages).
  final Map<String, List<String>> fieldErrors;
  final Duration? retryAfter;
  final String? requestId;

  /// Domain object attached to the failure (e.g. the existing link on a duplicate).
  final Object? payload;

  /// First validation message for [field] (also matches `field.0`-style keys).
  String? fieldError(String field) {
    final direct = fieldErrors[field];
    if (direct != null && direct.isNotEmpty) return direct.first;
    for (final entry in fieldErrors.entries) {
      if (entry.key.startsWith('$field.') && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }
    return null;
  }

  /// A short sentence suitable for a snackbar or inline error.
  String get userMessage => switch (kind) {
    FailureKind.validation =>
      fieldErrors.values.expand((m) => m).firstOrNull ??
          'Please check the highlighted fields.',
    FailureKind.invalidUrl => 'Enter a valid http or https link.',
    FailureKind.invalidCursor => 'The list changed. Pull to refresh.',
    FailureKind.limitExceeded =>
      message ?? 'You have reached the limit for this item.',
    FailureKind.tokenInvalidOrExpired =>
      'This reset link is invalid or has expired.',
    FailureKind.invalidCredentials => 'The email or password is incorrect.',
    FailureKind.invalidGoogleToken =>
      'Google sign-in failed. Please try again.',
    FailureKind.googleUnavailable =>
      'Google sign-in isn’t available on this device right now.',
    FailureKind.googleNotConfigured =>
      'Google sign-in isn’t set up in this version of the app yet.',
    FailureKind.unauthenticated => 'Your session has ended. Please sign in.',
    FailureKind.forbidden => 'You don’t have access to this item.',
    FailureKind.notFound => 'This item no longer exists.',
    FailureKind.duplicateLink => 'This link is already in your Stashly.',
    FailureKind.rateLimited =>
      retryAfter == null
          ? 'Too many requests. Please wait a moment.'
          : 'Too many requests. Try again in ${retryAfter!.inSeconds}s.',
    FailureKind.server => 'Something went wrong on our side. Please try again.',
    FailureKind.serviceUnavailable =>
      'Stashly is temporarily unavailable. Please try again soon.',
    FailureKind.offline => 'You’re offline. Check your connection.',
    FailureKind.timeout => 'The request timed out. Please try again.',
    FailureKind.unknown => 'Something went wrong. Please try again.',
  };

  bool get isRetryable => switch (kind) {
    FailureKind.offline ||
    FailureKind.timeout ||
    FailureKind.server ||
    FailureKind.serviceUnavailable ||
    FailureKind.rateLimited ||
    FailureKind.unknown => true,
    _ => false,
  };

  @override
  String toString() => 'AppFailure($kind, code: $code, requestId: $requestId)';
}
