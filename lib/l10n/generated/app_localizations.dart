import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Stashly'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Everything Worth Keeping'**
  String get tagline;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @actionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get actionLoadMore;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get actionPrevious;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get actionGetStarted;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @actionKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// No description provided for @actionSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get actionSignIn;

  /// No description provided for @actionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get actionCreateAccount;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get labelOptional;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @fieldValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String fieldValue(String label, String value);

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCollections;

  /// No description provided for @navSaveLink.
  ///
  /// In en, this message translates to:
  /// **'Save a link'**
  String get navSaveLink;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @allSavedItems.
  ///
  /// In en, this message translates to:
  /// **'All saved items'**
  String get allSavedItems;

  /// No description provided for @updateEyebrow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE REQUIRED'**
  String get updateEyebrow;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Please update Stashly'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Install the latest version from the Play Store to continue.'**
  String get updateBody;

  /// No description provided for @updateBodyVersion.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Install version {version} from the Play Store to continue.'**
  String updateBodyVersion(String version);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @greetingMorningPlain.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorningPlain;

  /// No description provided for @greetingAfternoonPlain.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoonPlain;

  /// No description provided for @greetingEveningPlain.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEveningPlain;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get failureValidation;

  /// No description provided for @failureInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http or https link.'**
  String get failureInvalidUrl;

  /// No description provided for @failureInvalidCursor.
  ///
  /// In en, this message translates to:
  /// **'The list changed. Pull to refresh.'**
  String get failureInvalidCursor;

  /// No description provided for @failureLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit for this item.'**
  String get failureLimit;

  /// No description provided for @failureResetToken.
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has expired.'**
  String get failureResetToken;

  /// No description provided for @failureCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get failureCredentials;

  /// No description provided for @failureGoogleToken.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get failureGoogleToken;

  /// No description provided for @failureGoogleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn’t available on this device right now.'**
  String get failureGoogleUnavailable;

  /// No description provided for @failureGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn’t set up in this version of the app yet.'**
  String get failureGoogleNotConfigured;

  /// No description provided for @failureSession.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please sign in.'**
  String get failureSession;

  /// No description provided for @failureForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don’t have access to this item.'**
  String get failureForbidden;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get failureNotFound;

  /// No description provided for @failureDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This link is already in your Stashly.'**
  String get failureDuplicate;

  /// No description provided for @failureRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get failureRateLimited;

  /// No description provided for @failureRateLimitedSeconds.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again in {seconds}s.'**
  String failureRateLimitedSeconds(int seconds);

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again.'**
  String get failureServer;

  /// No description provided for @failureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Stashly is temporarily unavailable. Please try again soon.'**
  String get failureUnavailable;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Check your connection.'**
  String get failureOffline;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get failureTimeout;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get failureUnknown;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have edits that haven’t been saved yet.'**
  String get discardMessage;

  /// No description provided for @urlEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to save.'**
  String get urlEmpty;

  /// No description provided for @urlTooLong.
  ///
  /// In en, this message translates to:
  /// **'Links can be at most {max} characters.'**
  String urlTooLong(int max);

  /// No description provided for @urlScheme.
  ///
  /// In en, this message translates to:
  /// **'Only http and https links can be saved.'**
  String get urlScheme;

  /// No description provided for @urlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid web link.'**
  String get urlInvalid;

  /// No description provided for @createCollection.
  ///
  /// In en, this message translates to:
  /// **'Create collection'**
  String get createCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionName;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHereYet;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get enterAName;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @tagTooLong.
  ///
  /// In en, this message translates to:
  /// **'Tags can be at most {max} characters.'**
  String tagTooLong(int max);

  /// No description provided for @tooManyTags.
  ///
  /// In en, this message translates to:
  /// **'An item can have at most {max} tags.'**
  String tooManyTags(int max);

  /// No description provided for @itemTagsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ITEM TAGS'**
  String get itemTagsEyebrow;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTags;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get addTags;

  /// No description provided for @saveTags.
  ///
  /// In en, this message translates to:
  /// **'Save tags'**
  String get saveTags;

  /// No description provided for @findOrCreateTag.
  ///
  /// In en, this message translates to:
  /// **'Find or create a tag'**
  String get findOrCreateTag;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String removeItem(String label);

  /// No description provided for @previewPending.
  ///
  /// In en, this message translates to:
  /// **'Preview pending'**
  String get previewPending;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @cardLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}, {domain}'**
  String cardLabel(String title, String domain);

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this saved item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from your library. The original content won’t be affected.'**
  String deleteItemMessage(String title);

  /// No description provided for @keepItem.
  ///
  /// In en, this message translates to:
  /// **'Keep item'**
  String get keepItem;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get offlineTitle;

  /// No description provided for @loadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this'**
  String get loadFailedTitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most 128 characters.'**
  String get passwordTooLong;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Tell us what to call you.'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most 100 characters.'**
  String get nameTooLong;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don’t match.'**
  String get passwordsDontMatch;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms to continue.'**
  String get acceptTermsRequired;

  /// No description provided for @documentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document isn’t available yet.'**
  String get documentUnavailable;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get newPasswordHint;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Please sign in again.'**
  String get sessionEnded;

  /// No description provided for @welcomeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR DIGITAL-CONTENT WALLET'**
  String get welcomeEyebrow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Save anything worth keeping.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Collect useful links from anywhere, organize them your way, and find them when they matter.'**
  String get welcomeBody;

  /// No description provided for @welcomePointSave.
  ///
  /// In en, this message translates to:
  /// **'Save links in seconds'**
  String get welcomePointSave;

  /// No description provided for @welcomePointOrganize.
  ///
  /// In en, this message translates to:
  /// **'Organize when you’re ready'**
  String get welcomePointOrganize;

  /// No description provided for @welcomePointSearch.
  ///
  /// In en, this message translates to:
  /// **'Search your whole stash'**
  String get welcomePointSearch;

  /// No description provided for @welcomeFootnote.
  ///
  /// In en, this message translates to:
  /// **'Stashly keeps the link and its details — never a copy of the content.'**
  String get welcomeFootnote;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to return to everything you’ve kept.'**
  String get signInSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @newToStashly.
  ///
  /// In en, this message translates to:
  /// **'New to Stashly?'**
  String get newToStashly;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start building a stash that’s easy to return to.'**
  String get registerSubtitle;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we address you?'**
  String get displayNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter it once more'**
  String get confirmPasswordHint;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Stashly '**
  String get termsPrefix;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLink;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsAnd;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLink;

  /// No description provided for @termsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsSuffix;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account.'**
  String get resetSubtitle;

  /// No description provided for @resetNotice.
  ///
  /// In en, this message translates to:
  /// **'We’ll email a secure reset link if an account exists. It expires in 60 minutes.'**
  String get resetNotice;

  /// No description provided for @resetSentEyebrow.
  ///
  /// In en, this message translates to:
  /// **'RESET LINK SENT'**
  String get resetSentEyebrow;

  /// No description provided for @checkInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Next, check your inbox'**
  String get checkInboxTitle;

  /// No description provided for @checkInboxBefore.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for '**
  String get checkInboxBefore;

  /// No description provided for @checkInboxAfter.
  ///
  /// In en, this message translates to:
  /// **', a password reset link is on its way.'**
  String get checkInboxAfter;

  /// No description provided for @checkInboxStepOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the secure link in the email.'**
  String get checkInboxStepOpen;

  /// No description provided for @checkInboxStepChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password, then return to sign in.'**
  String get checkInboxStepChoose;

  /// No description provided for @returnToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Return to Sign In'**
  String get returnToSignIn;

  /// No description provided for @yourEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmailFallback;

  /// No description provided for @googleTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Stashly account'**
  String get googleTermsTitle;

  /// No description provided for @googleTermsBody.
  ///
  /// In en, this message translates to:
  /// **'This Google account is new to Stashly. Accept the Terms to create your account.'**
  String get googleTermsBody;

  /// No description provided for @readTerms.
  ///
  /// In en, this message translates to:
  /// **'Read the Terms'**
  String get readTerms;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @onboardingSaveEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SAVE IN A MOMENT'**
  String get onboardingSaveEyebrow;

  /// No description provided for @onboardingSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save what matters'**
  String get onboardingSaveTitle;

  /// No description provided for @onboardingSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Share useful links from the apps you already use. Stashly keeps the source, not a downloaded copy.'**
  String get onboardingSaveBody;

  /// No description provided for @onboardingOrganizeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MAKE IT YOURS'**
  String get onboardingOrganizeEyebrow;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your world'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeBody.
  ///
  /// In en, this message translates to:
  /// **'Collections and tags add structure when you want it—and stay out of the way when you don’t.'**
  String get onboardingOrganizeBody;

  /// No description provided for @onboardingFindEyebrow.
  ///
  /// In en, this message translates to:
  /// **'READY WHEN YOU ARE'**
  String get onboardingFindEyebrow;

  /// No description provided for @onboardingFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find it when you need it'**
  String get onboardingFindTitle;

  /// No description provided for @onboardingFindBody.
  ///
  /// In en, this message translates to:
  /// **'Search across titles, sources, collections, and favorites to rediscover the right link fast.'**
  String get onboardingFindBody;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @artSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Spaces worth remembering'**
  String get artSavedTitle;

  /// No description provided for @artLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get artLearning;

  /// No description provided for @artInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get artInspiration;

  /// No description provided for @artSaves.
  ///
  /// In en, this message translates to:
  /// **'{count} saves'**
  String artSaves(int count);

  /// No description provided for @artCurated.
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get artCurated;

  /// No description provided for @artQuery.
  ///
  /// In en, this message translates to:
  /// **'design inspiration'**
  String get artQuery;

  /// No description provided for @artResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet modern spaces'**
  String get artResultTitle;

  /// No description provided for @artResultTitle2.
  ///
  /// In en, this message translates to:
  /// **'Brand systems to revisit'**
  String get artResultTitle2;

  /// No description provided for @artIdeasFound.
  ///
  /// In en, this message translates to:
  /// **'{count} ideas found'**
  String artIdeasFound(int count);

  /// No description provided for @artTagInteriors.
  ///
  /// In en, this message translates to:
  /// **'#interiors'**
  String get artTagInteriors;

  /// No description provided for @artTagIdeas.
  ///
  /// In en, this message translates to:
  /// **'#ideas'**
  String get artTagIdeas;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @collectionsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZED YOUR WAY'**
  String get collectionsEyebrow;

  /// No description provided for @collectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal groups that can overlap as much as your interests do.'**
  String get collectionsSubtitle;

  /// No description provided for @startOrganizing.
  ///
  /// In en, this message translates to:
  /// **'Start organizing'**
  String get startOrganizing;

  /// No description provided for @startOrganizingBody.
  ///
  /// In en, this message translates to:
  /// **'Create a collection to group related links. A link can live in several.'**
  String get startOrganizingBody;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @deleteCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this collection?'**
  String get deleteCollectionTitle;

  /// No description provided for @deleteCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed. The links inside stay in your library.'**
  String deleteCollectionMessage(String name);

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @collectionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Collection deleted'**
  String get collectionDeleted;

  /// No description provided for @membershipEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION MEMBERSHIP'**
  String get membershipEyebrow;

  /// No description provided for @addExistingItems.
  ///
  /// In en, this message translates to:
  /// **'Add existing items'**
  String get addExistingItems;

  /// No description provided for @membershipHelper.
  ///
  /// In en, this message translates to:
  /// **'Select links for {name}. Removing one here keeps it in your library.'**
  String membershipHelper(String name);

  /// No description provided for @saveMembership.
  ///
  /// In en, this message translates to:
  /// **'Save membership'**
  String get saveMembership;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty.'**
  String get libraryEmpty;

  /// No description provided for @collectionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Collection updated'**
  String get collectionUpdated;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// No description provided for @addExisting.
  ///
  /// In en, this message translates to:
  /// **'Add existing'**
  String get addExisting;

  /// No description provided for @searchInCollection.
  ///
  /// In en, this message translates to:
  /// **'Search within this collection'**
  String get searchInCollection;

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'This collection is empty'**
  String get collectionEmpty;

  /// No description provided for @collectionNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches in this collection'**
  String get collectionNoMatches;

  /// No description provided for @collectionEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Use “Add existing” to bring links in, or organize from any item.'**
  String get collectionEmptyHint;

  /// No description provided for @tryBroaderWord.
  ///
  /// In en, this message translates to:
  /// **'Try a broader word.'**
  String get tryBroaderWord;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort: {label}'**
  String sortLabel(String label);

  /// No description provided for @collectionNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your collection a name.'**
  String get collectionNameRequired;

  /// No description provided for @newCollectionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'NEW COLLECTION'**
  String get newCollectionEyebrow;

  /// No description provided for @collectionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get collectionEyebrow;

  /// No description provided for @collectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekend projects'**
  String get collectionNameHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What belongs here?'**
  String get descriptionHint;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACCESS'**
  String get quickAccess;

  /// No description provided for @browseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get browseAll;

  /// No description provided for @yourSpace.
  ///
  /// In en, this message translates to:
  /// **'YOUR SPACE'**
  String get yourSpace;

  /// No description provided for @recentlySaved.
  ///
  /// In en, this message translates to:
  /// **'Recently saved'**
  String get recentlySaved;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @moreFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get moreFilters;

  /// No description provided for @nothingSavedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get nothingSavedYet;

  /// No description provided for @noItemsOfType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, video{No videos yet} article{No articles yet} product{No products yet} social{No social yet} other{No other yet}}'**
  String noItemsOfType(String type);

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Share a link from any app, or tap Save Link to add one.'**
  String get homeEmptyBody;

  /// No description provided for @homeEmptyTypeBody.
  ///
  /// In en, this message translates to:
  /// **'Items of this type will show up here.'**
  String get homeEmptyTypeBody;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything worth keeping, right where you left it.'**
  String get homeSubtitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search titles, sources, collections…'**
  String get homeSearchHint;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFilters;

  /// No description provided for @saveLink.
  ///
  /// In en, this message translates to:
  /// **'Save Link'**
  String get saveLink;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 saved} =1{1 saved} other{{count} saved}}'**
  String savedCount(int count);

  /// No description provided for @favoritesTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites, {saved}'**
  String favoritesTileLabel(String saved);

  /// No description provided for @contentType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, video{Videos} article{Articles} product{Products} social{Social} other{Other}}'**
  String contentType(String type);

  /// No description provided for @linkSort.
  ///
  /// In en, this message translates to:
  /// **'{sort, select, newest{Newest} oldest{Oldest} other{{sort}}}'**
  String linkSort(String sort);

  /// No description provided for @collectionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Collections updated'**
  String get collectionsUpdated;

  /// No description provided for @incomingLink.
  ///
  /// In en, this message translates to:
  /// **'Incoming link'**
  String get incomingLink;

  /// No description provided for @alreadyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ALREADY IN STASHLY'**
  String get alreadyEyebrow;

  /// No description provided for @alreadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve saved this link before'**
  String get alreadyTitle;

  /// No description provided for @alreadyBody.
  ///
  /// In en, this message translates to:
  /// **'No duplicate was created. You can open the existing item or add more organization.'**
  String get alreadyBody;

  /// No description provided for @openSavedItem.
  ///
  /// In en, this message translates to:
  /// **'Open saved item'**
  String get openSavedItem;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to a collection'**
  String get addToCollection;

  /// No description provided for @editPersonalNote.
  ///
  /// In en, this message translates to:
  /// **'Edit personal note'**
  String get editPersonalNote;

  /// No description provided for @openMyLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open my library'**
  String get openMyLibrary;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @savedItemEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SAVED ITEM'**
  String get savedItemEyebrow;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetails;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Add a memorable title'**
  String get titleHint;

  /// No description provided for @originalUrl.
  ///
  /// In en, this message translates to:
  /// **'Original URL'**
  String get originalUrl;

  /// No description provided for @personalNote.
  ///
  /// In en, this message translates to:
  /// **'Personal note'**
  String get personalNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this worth keeping?'**
  String get noteHint;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'travel, italy, film'**
  String get tagsHint;

  /// No description provided for @sharedTagsHint.
  ///
  /// In en, this message translates to:
  /// **'travel, watch later'**
  String get sharedTagsHint;

  /// No description provided for @collectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionLabel;

  /// No description provided for @libraryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR CONTENT LIBRARY'**
  String get libraryEyebrow;

  /// No description provided for @listLayout.
  ///
  /// In en, this message translates to:
  /// **'List layout'**
  String get listLayout;

  /// No description provided for @gridLayout.
  ///
  /// In en, this message translates to:
  /// **'Grid layout'**
  String get gridLayout;

  /// No description provided for @noFilterMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get noFilterMatches;

  /// No description provided for @noFilterMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try another type or turn off Favorites.'**
  String get noFilterMatchesBody;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Share a link to Stashly or tap + to save your first one.'**
  String get libraryEmptyBody;

  /// No description provided for @openFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open this link.'**
  String get openFailed;

  /// No description provided for @savedItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved item'**
  String get savedItemTitle;

  /// No description provided for @openOriginal.
  ///
  /// In en, this message translates to:
  /// **'Open Original'**
  String get openOriginal;

  /// No description provided for @copyLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLinkButton;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel;

  /// No description provided for @descriptionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionEyebrow;

  /// No description provided for @tagsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get tagsEyebrow;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet.'**
  String get noTagsYet;

  /// No description provided for @addToFavoritesButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavoritesButton;

  /// No description provided for @removeFromFavoritesButton.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavoritesButton;

  /// No description provided for @organizeIntoCollections.
  ///
  /// In en, this message translates to:
  /// **'Organize into Collections'**
  String get organizeIntoCollections;

  /// No description provided for @deleteSavedItem.
  ///
  /// In en, this message translates to:
  /// **'Delete saved item'**
  String get deleteSavedItem;

  /// No description provided for @fetchingDetails.
  ///
  /// In en, this message translates to:
  /// **'Fetching details…'**
  String get fetchingDetails;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescription;

  /// No description provided for @previewBlocked.
  ///
  /// In en, this message translates to:
  /// **'This page can’t be previewed.'**
  String get previewBlocked;

  /// No description provided for @previewFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load a preview.'**
  String get previewFailed;

  /// No description provided for @refreshPreview.
  ///
  /// In en, this message translates to:
  /// **'Refresh preview'**
  String get refreshPreview;

  /// No description provided for @organizeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZE'**
  String get organizeEyebrow;

  /// No description provided for @addToCollections.
  ///
  /// In en, this message translates to:
  /// **'Add to collections'**
  String get addToCollections;

  /// No description provided for @organizeHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose any number of collections. Clear all to keep this item Unsorted.'**
  String get organizeHelper;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @noCollectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet. Create your first one below.'**
  String get noCollectionsYet;

  /// No description provided for @unsorted.
  ///
  /// In en, this message translates to:
  /// **'Unsorted'**
  String get unsorted;

  /// No description provided for @savedToStashly.
  ///
  /// In en, this message translates to:
  /// **'Saved to Stashly'**
  String get savedToStashly;

  /// No description provided for @addToStashlyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ADD TO STASHLY'**
  String get addToStashlyEyebrow;

  /// No description provided for @saveToStashly.
  ///
  /// In en, this message translates to:
  /// **'Save to Stashly'**
  String get saveToStashly;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @previewNotice.
  ///
  /// In en, this message translates to:
  /// **'We’ll fetch a preview when available. You can always save without one.'**
  String get previewNotice;

  /// No description provided for @shareNoLink.
  ///
  /// In en, this message translates to:
  /// **'This share doesn’t contain a web link Stashly can save.'**
  String get shareNoLink;

  /// No description provided for @linkCantBeSaved.
  ///
  /// In en, this message translates to:
  /// **'This link can’t be saved.'**
  String get linkCantBeSaved;

  /// No description provided for @sharedToStashly.
  ///
  /// In en, this message translates to:
  /// **'Shared to Stashly'**
  String get sharedToStashly;

  /// No description provided for @storageNotice.
  ///
  /// In en, this message translates to:
  /// **'Only the URL and available metadata are stored—not the original video or image.'**
  String get storageNotice;

  /// No description provided for @saveNow.
  ///
  /// In en, this message translates to:
  /// **'Save now'**
  String get saveNow;

  /// No description provided for @cantSaveThis.
  ///
  /// In en, this message translates to:
  /// **'Can’t save this'**
  String get cantSaveThis;

  /// No description provided for @lookingForPreview.
  ///
  /// In en, this message translates to:
  /// **'Looking for a preview…'**
  String get lookingForPreview;

  /// No description provided for @lookingForPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'You can save right away; details can arrive later.'**
  String get lookingForPreviewBody;

  /// No description provided for @previewReady.
  ///
  /// In en, this message translates to:
  /// **'Preview ready'**
  String get previewReady;

  /// No description provided for @previewReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Title and thumbnail found.'**
  String get previewReadyBody;

  /// No description provided for @previewPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial preview'**
  String get previewPartial;

  /// No description provided for @previewPartialBody.
  ///
  /// In en, this message translates to:
  /// **'Some details were found. We’ll keep looking after you save.'**
  String get previewPartialBody;

  /// No description provided for @previewNone.
  ///
  /// In en, this message translates to:
  /// **'No preview yet'**
  String get previewNone;

  /// No description provided for @previewNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Save now — we’ll try to fetch the title and image in the background.'**
  String get previewNoneBody;

  /// No description provided for @previewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get previewUnavailable;

  /// No description provided for @previewUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This page can’t be previewed, but you can still save the link.'**
  String get previewUnavailableBody;

  /// No description provided for @offlineSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to save this link.'**
  String get offlineSaveBody;

  /// No description provided for @nameLength.
  ///
  /// In en, this message translates to:
  /// **'Use 1–100 characters.'**
  String get nameLength;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @accountEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountEyebrow;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailLocked.
  ///
  /// In en, this message translates to:
  /// **'Your email is your sign-in and can’t be changed yet.'**
  String get emailLocked;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get currentPasswordRequired;

  /// No description provided for @choosePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'Choose a password you haven’t used here.'**
  String get choosePasswordNew;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Other devices were signed out.'**
  String get passwordUpdated;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your current password, then choose a new one.'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get currentPasswordHint;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter it again'**
  String get confirmNewPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @otherDevicesNotice.
  ///
  /// In en, this message translates to:
  /// **'For your security, other devices will be signed out.'**
  String get otherDevicesNotice;

  /// No description provided for @profileEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR STASHLY'**
  String get profileEyebrow;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalSaves.
  ///
  /// In en, this message translates to:
  /// **'Total saves'**
  String get totalSaves;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal content wallet'**
  String get walletTitle;

  /// No description provided for @walletBody.
  ///
  /// In en, this message translates to:
  /// **'Stashly stores your links and metadata—not downloaded originals.'**
  String get walletBody;

  /// No description provided for @settingsRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account, privacy, and about'**
  String get settingsRowSubtitle;

  /// No description provided for @statLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} {label}'**
  String statLabel(int value, String label);

  /// No description provided for @exportSubject.
  ///
  /// In en, this message translates to:
  /// **'My Stashly data export'**
  String get exportSubject;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign out of this device only, or every device signed in to your account.'**
  String get signOutBody;

  /// No description provided for @signOutThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device'**
  String get signOutThisDevice;

  /// No description provided for @signOutEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get signOutEverywhere;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A personal wallet for links worth keeping. Stashly saves the link and its details—never a copy of the content.'**
  String get aboutBody;

  /// No description provided for @changePasswordRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your current password to set a new one'**
  String get changePasswordRowSubtitle;

  /// No description provided for @setPasswordViaForgot.
  ///
  /// In en, this message translates to:
  /// **'Use “Forgot password” to set a password'**
  String get setPasswordViaForgot;

  /// No description provided for @appearanceGroup.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceGroup;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stashly’s signature look'**
  String get themeDarkSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bright and easy to read in daylight'**
  String get themeLightSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get themeSystem;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your phone’s dark mode setting'**
  String get themeSystemSubtitle;

  /// No description provided for @languageGroup.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageGroup;

  /// No description provided for @languageDevice.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageDevice;

  /// No description provided for @languageDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic or English, following your phone'**
  String get languageDeviceSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishSubtitle;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageArabicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabicSubtitle;

  /// No description provided for @dataGroup.
  ///
  /// In en, this message translates to:
  /// **'DATA & PRIVACY'**
  String get dataGroup;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Stashly handles your data'**
  String get privacySubtitle;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The agreement for using Stashly'**
  String get termsSubtitle;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @exportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your file…'**
  String get exportPreparing;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download everything as a JSON file'**
  String get exportSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently removes your account and saved items'**
  String get deleteAccountSubtitle;

  /// No description provided for @aboutGroup.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutGroup;

  /// No description provided for @aboutStashly.
  ///
  /// In en, this message translates to:
  /// **'About Stashly'**
  String get aboutStashly;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @versionValue.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionValue(String version);

  /// No description provided for @buildBadge.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get buildBadge;

  /// No description provided for @passwordConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm.'**
  String get passwordConfirmRequired;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, saved links, collections and tags. It can’t be undone. Export your data first if you want a copy.'**
  String get deleteAccountBody;

  /// No description provided for @confirmWithGoogleNotice.
  ///
  /// In en, this message translates to:
  /// **'You’ll confirm with your Google account.'**
  String get confirmWithGoogleNotice;

  /// No description provided for @yourPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPasswordHint;

  /// No description provided for @keepAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep account'**
  String get keepAccount;

  /// No description provided for @refineEyebrow.
  ///
  /// In en, this message translates to:
  /// **'REFINE RESULTS'**
  String get refineEyebrow;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @contentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get contentTypeLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform or source'**
  String get sourceLabel;

  /// No description provided for @dateSaved.
  ///
  /// In en, this message translates to:
  /// **'Date saved'**
  String get dateSaved;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// No description provided for @lastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String lastDays(int days);

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// No description provided for @searchEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FIND IT AGAIN'**
  String get searchEyebrow;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your stash'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search the words stored with your links—no AI or source app required.'**
  String get searchSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, note, description, or source…'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @suggestedSearches.
  ///
  /// In en, this message translates to:
  /// **'Suggested searches'**
  String get suggestedSearches;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatches;

  /// No description provided for @noMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a broader word or check your filters.'**
  String get noMatchesBody;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 results} =1{1 result} other{{count} results}}'**
  String resultCount(int count);

  /// No description provided for @searchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for {query}'**
  String searchFor(String query);

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t need to remember where it came from'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try an English or Arabic title, a note, or a website domain.'**
  String get searchEmptyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
