import 'package:flutter/widgets.dart';

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/url/url_utils.dart';
import 'package:stashly/l10n/generated/app_localizations.dart';

export 'package:stashly/l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Messages in the active language (English or Arabic).
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension LocalizedFailure on AppFailure {
  /// A short sentence for a snackbar or inline error. Validation and limit
  /// errors prefer the server's own message, which names the problem field.
  String describe(AppLocalizations l10n) => switch (kind) {
    FailureKind.validation =>
      fieldErrors.values.expand((m) => m).firstOrNull ?? l10n.failureValidation,
    FailureKind.invalidUrl => l10n.failureInvalidUrl,
    FailureKind.invalidCursor => l10n.failureInvalidCursor,
    FailureKind.limitExceeded => message ?? l10n.failureLimit,
    FailureKind.tokenInvalidOrExpired => l10n.failureResetToken,
    FailureKind.invalidCredentials => l10n.failureCredentials,
    FailureKind.invalidGoogleToken => l10n.failureGoogleToken,
    FailureKind.googleUnavailable => l10n.failureGoogleUnavailable,
    FailureKind.googleNotConfigured => l10n.failureGoogleNotConfigured,
    FailureKind.unauthenticated => l10n.failureSession,
    FailureKind.forbidden => l10n.failureForbidden,
    FailureKind.notFound => l10n.failureNotFound,
    FailureKind.duplicateLink => l10n.failureDuplicate,
    FailureKind.rateLimited =>
      retryAfter == null
          ? l10n.failureRateLimited
          : l10n.failureRateLimitedSeconds(retryAfter!.inSeconds),
    FailureKind.server => l10n.failureServer,
    FailureKind.serviceUnavailable => l10n.failureUnavailable,
    FailureKind.offline => l10n.failureOffline,
    FailureKind.timeout => l10n.failureTimeout,
    FailureKind.unknown => l10n.failureUnknown,
  };
}

extension LocalizedUrlProblem on UrlProblem {
  String describe(AppLocalizations l10n) => switch (this) {
    UrlProblem.empty => l10n.urlEmpty,
    UrlProblem.tooLong => l10n.urlTooLong(UrlUtils.maxLength),
    UrlProblem.unsupportedScheme => l10n.urlScheme,
    UrlProblem.invalid => l10n.urlInvalid,
  };
}
