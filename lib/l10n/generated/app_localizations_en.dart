// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stashly';

  @override
  String get tagline => 'Everything Worth Keeping';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionLoadMore => 'Load more';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionShare => 'Share';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionGetStarted => 'Get Started';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get actionSignIn => 'Sign In';

  @override
  String get actionCreateAccount => 'Create Account';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionAccept => 'Accept';

  @override
  String get labelOptional => 'Optional';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String fieldValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get or => 'or';

  @override
  String get navHome => 'Home';

  @override
  String get navCollections => 'Collections';

  @override
  String get navSaveLink => 'Save a link';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String get allSavedItems => 'All saved items';

  @override
  String get updateEyebrow => 'UPDATE REQUIRED';

  @override
  String get updateTitle => 'Please update Stashly';

  @override
  String get updateBody =>
      'This version is no longer supported. Install the latest version from the Play Store to continue.';

  @override
  String updateBodyVersion(String version) {
    return 'This version is no longer supported. Install version $version from the Play Store to continue.';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get greetingMorningPlain => 'Good morning';

  @override
  String get greetingAfternoonPlain => 'Good afternoon';

  @override
  String get greetingEveningPlain => 'Good evening';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get failureValidation => 'Please check the highlighted fields.';

  @override
  String get failureInvalidUrl => 'Enter a valid http or https link.';

  @override
  String get failureInvalidCursor => 'The list changed. Pull to refresh.';

  @override
  String get failureLimit => 'You have reached the limit for this item.';

  @override
  String get failureResetToken => 'This reset link is invalid or has expired.';

  @override
  String get failureCredentials => 'The email or password is incorrect.';

  @override
  String get failureGoogleToken => 'Google sign-in failed. Please try again.';

  @override
  String get failureGoogleUnavailable =>
      'Google sign-in isn’t available on this device right now.';

  @override
  String get failureGoogleNotConfigured =>
      'Google sign-in isn’t set up in this version of the app yet.';

  @override
  String get failureSession => 'Your session has ended. Please sign in.';

  @override
  String get failureForbidden => 'You don’t have access to this item.';

  @override
  String get failureNotFound => 'This item no longer exists.';

  @override
  String get failureDuplicate => 'This link is already in your Stashly.';

  @override
  String get failureRateLimited => 'Too many requests. Please wait a moment.';

  @override
  String failureRateLimitedSeconds(int seconds) {
    return 'Too many requests. Try again in ${seconds}s.';
  }

  @override
  String get failureServer =>
      'Something went wrong on our side. Please try again.';

  @override
  String get failureUnavailable =>
      'Stashly is temporarily unavailable. Please try again soon.';

  @override
  String get failureOffline => 'You’re offline. Check your connection.';

  @override
  String get failureTimeout => 'The request timed out. Please try again.';

  @override
  String get failureUnknown => 'Something went wrong. Please try again.';

  @override
  String get discardTitle => 'Discard your changes?';

  @override
  String get discardMessage => 'You have edits that haven’t been saved yet.';

  @override
  String get urlEmpty => 'Paste a link to save.';

  @override
  String urlTooLong(int max) {
    return 'Links can be at most $max characters.';
  }

  @override
  String get urlScheme => 'Only http and https links can be saved.';

  @override
  String get urlInvalid => 'Enter a valid web link.';

  @override
  String get createCollection => 'Create collection';

  @override
  String get collectionName => 'Collection name';

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String get enterAName => 'Enter a name.';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String tagTooLong(int max) {
    return 'Tags can be at most $max characters.';
  }

  @override
  String tooManyTags(int max) {
    return 'An item can have at most $max tags.';
  }

  @override
  String get itemTagsEyebrow => 'ITEM TAGS';

  @override
  String get editTags => 'Edit tags';

  @override
  String get addTags => 'Add tags';

  @override
  String get saveTags => 'Save tags';

  @override
  String get findOrCreateTag => 'Find or create a tag';

  @override
  String get suggestions => 'Suggestions';

  @override
  String removeItem(String label) {
    return 'Remove $label';
  }

  @override
  String get previewPending => 'Preview pending';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get moreActions => 'More actions';

  @override
  String get viewDetails => 'View details';

  @override
  String get copyLink => 'Copy link';

  @override
  String cardLabel(String title, String domain) {
    return '$title, $domain';
  }

  @override
  String get deleteItemTitle => 'Delete this saved item?';

  @override
  String deleteItemMessage(String title) {
    return '“$title” will be removed from your library. The original content won’t be affected.';
  }

  @override
  String get keepItem => 'Keep item';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get offlineTitle => 'You’re offline';

  @override
  String get loadFailedTitle => 'Couldn’t load this';

  @override
  String get emailRequired => 'Enter your email.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get passwordTooLong => 'Use at most 128 characters.';

  @override
  String get nameRequired => 'Tell us what to call you.';

  @override
  String get nameTooLong => 'Use at most 100 characters.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get passwordsDontMatch => 'Passwords don’t match.';

  @override
  String get acceptTermsRequired => 'Please accept the Terms to continue.';

  @override
  String get documentUnavailable => 'This document isn’t available yet.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get newPasswordHint => 'At least 8 characters';

  @override
  String get sessionEnded => 'Your session ended. Please sign in again.';

  @override
  String get welcomeEyebrow => 'YOUR DIGITAL-CONTENT WALLET';

  @override
  String get welcomeTitle => 'Save anything worth keeping.';

  @override
  String get welcomeBody =>
      'Collect useful links from anywhere, organize them your way, and find them when they matter.';

  @override
  String get welcomePointSave => 'Save links in seconds';

  @override
  String get welcomePointOrganize => 'Organize when you’re ready';

  @override
  String get welcomePointSearch => 'Search your whole stash';

  @override
  String get welcomeFootnote =>
      'Stashly keeps the link and its details — never a copy of the content.';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to return to everything you’ve kept.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get newToStashly => 'New to Stashly?';

  @override
  String get createAccountLink => 'Create account';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Start building a stash that’s easy to return to.';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameHint => 'How should we address you?';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Enter it once more';

  @override
  String get termsPrefix => 'I agree to the Stashly ';

  @override
  String get termsLink => 'Terms';

  @override
  String get termsAnd => ' and ';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get termsSuffix => '.';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetSubtitle => 'Enter the email associated with your account.';

  @override
  String get resetNotice =>
      'We’ll email a secure reset link if an account exists. It expires in 60 minutes.';

  @override
  String get resetSentEyebrow => 'RESET LINK SENT';

  @override
  String get checkInboxTitle => 'Next, check your inbox';

  @override
  String get checkInboxBefore => 'If an account exists for ';

  @override
  String get checkInboxAfter => ', a password reset link is on its way.';

  @override
  String get checkInboxStepOpen => 'Open the secure link in the email.';

  @override
  String get checkInboxStepChoose =>
      'Choose a new password, then return to sign in.';

  @override
  String get returnToSignIn => 'Return to Sign In';

  @override
  String get yourEmailFallback => 'your email';

  @override
  String get googleTermsTitle => 'Create your Stashly account';

  @override
  String get googleTermsBody =>
      'This Google account is new to Stashly. Accept the Terms to create your account.';

  @override
  String get readTerms => 'Read the Terms';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get onboardingSaveEyebrow => 'SAVE IN A MOMENT';

  @override
  String get onboardingSaveTitle => 'Save what matters';

  @override
  String get onboardingSaveBody =>
      'Share useful links from the apps you already use. Stashly keeps the source, not a downloaded copy.';

  @override
  String get onboardingOrganizeEyebrow => 'MAKE IT YOURS';

  @override
  String get onboardingOrganizeTitle => 'Organize your world';

  @override
  String get onboardingOrganizeBody =>
      'Collections and tags add structure when you want it—and stay out of the way when you don’t.';

  @override
  String get onboardingFindEyebrow => 'READY WHEN YOU ARE';

  @override
  String get onboardingFindTitle => 'Find it when you need it';

  @override
  String get onboardingFindBody =>
      'Search across titles, sources, collections, and favorites to rediscover the right link fast.';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get artSavedTitle => 'Spaces worth remembering';

  @override
  String get artLearning => 'Learning';

  @override
  String get artInspiration => 'Inspiration';

  @override
  String artSaves(int count) {
    return '$count saves';
  }

  @override
  String get artCurated => 'Curated';

  @override
  String get artQuery => 'design inspiration';

  @override
  String get artResultTitle => 'Quiet modern spaces';

  @override
  String get artResultTitle2 => 'Brand systems to revisit';

  @override
  String artIdeasFound(int count) {
    return '$count ideas found';
  }

  @override
  String get artTagInteriors => '#interiors';

  @override
  String get artTagIdeas => '#ideas';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: '0 items',
    );
    return '$_temp0';
  }

  @override
  String get collectionsEyebrow => 'ORGANIZED YOUR WAY';

  @override
  String get collectionsSubtitle =>
      'Personal groups that can overlap as much as your interests do.';

  @override
  String get startOrganizing => 'Start organizing';

  @override
  String get startOrganizingBody =>
      'Create a collection to group related links. A link can live in several.';

  @override
  String get newCollection => 'New collection';

  @override
  String get deleteCollectionTitle => 'Delete this collection?';

  @override
  String deleteCollectionMessage(String name) {
    return '“$name” will be removed. The links inside stay in your library.';
  }

  @override
  String get keepIt => 'Keep it';

  @override
  String get collectionDeleted => 'Collection deleted';

  @override
  String get membershipEyebrow => 'COLLECTION MEMBERSHIP';

  @override
  String get addExistingItems => 'Add existing items';

  @override
  String membershipHelper(String name) {
    return 'Select links for $name. Removing one here keeps it in your library.';
  }

  @override
  String get saveMembership => 'Save membership';

  @override
  String get libraryEmpty => 'Your library is empty.';

  @override
  String get collectionUpdated => 'Collection updated';

  @override
  String get editCollection => 'Edit collection';

  @override
  String get addExisting => 'Add existing';

  @override
  String get searchInCollection => 'Search within this collection';

  @override
  String get collectionEmpty => 'This collection is empty';

  @override
  String get collectionNoMatches => 'No matches in this collection';

  @override
  String get collectionEmptyHint =>
      'Use “Add existing” to bring links in, or organize from any item.';

  @override
  String get tryBroaderWord => 'Try a broader word.';

  @override
  String sortLabel(String label) {
    return 'Sort: $label';
  }

  @override
  String get collectionNameRequired => 'Give your collection a name.';

  @override
  String get newCollectionEyebrow => 'NEW COLLECTION';

  @override
  String get collectionEyebrow => 'COLLECTION';

  @override
  String get collectionNameHint => 'e.g. Weekend projects';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'What belongs here?';

  @override
  String get quickAccess => 'QUICK ACCESS';

  @override
  String get browseAll => 'Browse all';

  @override
  String get yourSpace => 'YOUR SPACE';

  @override
  String get recentlySaved => 'Recently saved';

  @override
  String get viewAll => 'View all';

  @override
  String get filterAll => 'All';

  @override
  String get moreFilters => 'More filters';

  @override
  String get nothingSavedYet => 'Nothing saved yet';

  @override
  String noItemsOfType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'video': 'No videos yet',
      'article': 'No articles yet',
      'product': 'No products yet',
      'social': 'No social yet',
      'other': 'No other yet',
    });
    return '$_temp0';
  }

  @override
  String get homeEmptyBody =>
      'Share a link from any app, or tap Save Link to add one.';

  @override
  String get homeEmptyTypeBody => 'Items of this type will show up here.';

  @override
  String get homeSubtitle =>
      'Everything worth keeping, right where you left it.';

  @override
  String get homeSearchHint => 'Search titles, sources, collections…';

  @override
  String get searchFilters => 'Search filters';

  @override
  String get saveLink => 'Save Link';

  @override
  String get favorites => 'Favorites';

  @override
  String savedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved',
      one: '1 saved',
      zero: '0 saved',
    );
    return '$_temp0';
  }

  @override
  String favoritesTileLabel(String saved) {
    return 'Favorites, $saved';
  }

  @override
  String contentType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'video': 'Videos',
      'article': 'Articles',
      'product': 'Products',
      'social': 'Social',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String linkSort(String sort) {
    String _temp0 = intl.Intl.selectLogic(sort, {
      'newest': 'Newest',
      'oldest': 'Oldest',
      'other': '$sort',
    });
    return '$_temp0';
  }

  @override
  String get collectionsUpdated => 'Collections updated';

  @override
  String get incomingLink => 'Incoming link';

  @override
  String get alreadyEyebrow => 'ALREADY IN STASHLY';

  @override
  String get alreadyTitle => 'You’ve saved this link before';

  @override
  String get alreadyBody =>
      'No duplicate was created. You can open the existing item or add more organization.';

  @override
  String get openSavedItem => 'Open saved item';

  @override
  String get addToCollection => 'Add to a collection';

  @override
  String get editPersonalNote => 'Edit personal note';

  @override
  String get openMyLibrary => 'Open my library';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get savedItemEyebrow => 'SAVED ITEM';

  @override
  String get editDetails => 'Edit details';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'Add a memorable title';

  @override
  String get originalUrl => 'Original URL';

  @override
  String get personalNote => 'Personal note';

  @override
  String get noteHint => 'Why is this worth keeping?';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'travel, italy, film';

  @override
  String get sharedTagsHint => 'travel, watch later';

  @override
  String get collectionLabel => 'Collection';

  @override
  String get libraryEyebrow => 'YOUR CONTENT LIBRARY';

  @override
  String get listLayout => 'List layout';

  @override
  String get gridLayout => 'Grid layout';

  @override
  String get noFilterMatches => 'Nothing matches these filters';

  @override
  String get noFilterMatchesBody => 'Try another type or turn off Favorites.';

  @override
  String get libraryEmptyBody =>
      'Share a link to Stashly or tap + to save your first one.';

  @override
  String get openFailed => 'Couldn’t open this link.';

  @override
  String get savedItemTitle => 'Saved item';

  @override
  String get openOriginal => 'Open Original';

  @override
  String get copyLinkButton => 'Copy Link';

  @override
  String get savedLabel => 'Saved';

  @override
  String get descriptionEyebrow => 'DESCRIPTION';

  @override
  String get tagsEyebrow => 'TAGS';

  @override
  String get noTagsYet => 'No tags yet.';

  @override
  String get addToFavoritesButton => 'Add to Favorites';

  @override
  String get removeFromFavoritesButton => 'Remove from Favorites';

  @override
  String get organizeIntoCollections => 'Organize into Collections';

  @override
  String get deleteSavedItem => 'Delete saved item';

  @override
  String get fetchingDetails => 'Fetching details…';

  @override
  String get noDescription => 'No description available.';

  @override
  String get previewBlocked => 'This page can’t be previewed.';

  @override
  String get previewFailed => 'We couldn’t load a preview.';

  @override
  String get refreshPreview => 'Refresh preview';

  @override
  String get organizeEyebrow => 'ORGANIZE';

  @override
  String get addToCollections => 'Add to collections';

  @override
  String get organizeHelper =>
      'Choose any number of collections. Clear all to keep this item Unsorted.';

  @override
  String get selected => 'Selected';

  @override
  String get noCollectionsYet =>
      'No collections yet. Create your first one below.';

  @override
  String get unsorted => 'Unsorted';

  @override
  String get savedToStashly => 'Saved to Stashly';

  @override
  String get addToStashlyEyebrow => 'ADD TO STASHLY';

  @override
  String get saveToStashly => 'Save to Stashly';

  @override
  String get urlLabel => 'URL';

  @override
  String get previewNotice =>
      'We’ll fetch a preview when available. You can always save without one.';

  @override
  String get shareNoLink =>
      'This share doesn’t contain a web link Stashly can save.';

  @override
  String get linkCantBeSaved => 'This link can’t be saved.';

  @override
  String get sharedToStashly => 'Shared to Stashly';

  @override
  String get storageNotice =>
      'Only the URL and available metadata are stored—not the original video or image.';

  @override
  String get saveNow => 'Save now';

  @override
  String get cantSaveThis => 'Can’t save this';

  @override
  String get lookingForPreview => 'Looking for a preview…';

  @override
  String get lookingForPreviewBody =>
      'You can save right away; details can arrive later.';

  @override
  String get previewReady => 'Preview ready';

  @override
  String get previewReadyBody => 'Title and thumbnail found.';

  @override
  String get previewPartial => 'Partial preview';

  @override
  String get previewPartialBody =>
      'Some details were found. We’ll keep looking after you save.';

  @override
  String get previewNone => 'No preview yet';

  @override
  String get previewNoneBody =>
      'Save now — we’ll try to fetch the title and image in the background.';

  @override
  String get previewUnavailable => 'Preview unavailable';

  @override
  String get previewUnavailableBody =>
      'This page can’t be previewed, but you can still save the link.';

  @override
  String get offlineSaveBody => 'Connect to the internet to save this link.';

  @override
  String get nameLength => 'Use 1–100 characters.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get accountEyebrow => 'ACCOUNT';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailLocked =>
      'Your email is your sign-in and can’t be changed yet.';

  @override
  String get currentPasswordRequired => 'Enter your current password.';

  @override
  String get choosePasswordNew => 'Choose a password you haven’t used here.';

  @override
  String get passwordUpdated =>
      'Password updated. Other devices were signed out.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle =>
      'Confirm your current password, then choose a new one.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPasswordHint => 'Enter current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get confirmNewPasswordHint => 'Enter it again';

  @override
  String get updatePassword => 'Update password';

  @override
  String get otherDevicesNotice =>
      'For your security, other devices will be signed out.';

  @override
  String get profileEyebrow => 'YOUR STASHLY';

  @override
  String get settings => 'Settings';

  @override
  String get totalSaves => 'Total saves';

  @override
  String get walletTitle => 'Personal content wallet';

  @override
  String get walletBody =>
      'Stashly stores your links and metadata—not downloaded originals.';

  @override
  String get settingsRowSubtitle => 'Account, privacy, and about';

  @override
  String statLabel(int value, String label) {
    return '$value $label';
  }

  @override
  String get exportSubject => 'My Stashly data export';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'You can sign out of this device only, or every device signed in to your account.';

  @override
  String get signOutThisDevice => 'Sign out of this device';

  @override
  String get signOutEverywhere => 'Sign out everywhere';

  @override
  String get aboutBody =>
      'A personal wallet for links worth keeping. Stashly saves the link and its details—never a copy of the content.';

  @override
  String get changePasswordRowSubtitle =>
      'Confirm your current password to set a new one';

  @override
  String get setPasswordViaForgot => 'Use “Forgot password” to set a password';

  @override
  String get appearanceGroup => 'APPEARANCE';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkSubtitle => 'Stashly’s signature look';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightSubtitle => 'Bright and easy to read in daylight';

  @override
  String get themeSystem => 'Match device';

  @override
  String get themeSystemSubtitle => 'Follow your phone’s dark mode setting';

  @override
  String get languageGroup => 'LANGUAGE';

  @override
  String get languageDevice => 'Device language';

  @override
  String get languageDeviceSubtitle =>
      'Arabic or English, following your phone';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageArabicSubtitle => 'Arabic';

  @override
  String get dataGroup => 'DATA & PRIVACY';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacySubtitle => 'How Stashly handles your data';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get termsSubtitle => 'The agreement for using Stashly';

  @override
  String get exportData => 'Export my data';

  @override
  String get exportPreparing => 'Preparing your file…';

  @override
  String get exportSubtitle => 'Download everything as a JSON file';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently removes your account and saved items';

  @override
  String get aboutGroup => 'ABOUT';

  @override
  String get aboutStashly => 'About Stashly';

  @override
  String get appVersion => 'App version';

  @override
  String versionValue(String version) {
    return 'Version $version';
  }

  @override
  String get buildBadge => 'Build';

  @override
  String get passwordConfirmRequired => 'Enter your password to confirm.';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account, saved links, collections and tags. It can’t be undone. Export your data first if you want a copy.';

  @override
  String get confirmWithGoogleNotice =>
      'You’ll confirm with your Google account.';

  @override
  String get yourPasswordHint => 'Your password';

  @override
  String get keepAccount => 'Keep account';

  @override
  String get refineEyebrow => 'REFINE RESULTS';

  @override
  String get resetAll => 'Reset All';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get contentTypeLabel => 'Content type';

  @override
  String get sourceLabel => 'Platform or source';

  @override
  String get dateSaved => 'Date saved';

  @override
  String get anyTime => 'Any time';

  @override
  String lastDays(int days) {
    return 'Last $days days';
  }

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get searchEyebrow => 'FIND IT AGAIN';

  @override
  String get searchTitle => 'Search your stash';

  @override
  String get searchSubtitle =>
      'Search the words stored with your links—no AI or source app required.';

  @override
  String get searchHint => 'Title, note, description, or source…';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filters => 'Filters';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get suggestedSearches => 'Suggested searches';

  @override
  String get noMatches => 'No matches found';

  @override
  String get noMatchesBody => 'Try a broader word or check your filters.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: '0 results',
    );
    return '$_temp0';
  }

  @override
  String searchFor(String query) {
    return 'Search for $query';
  }

  @override
  String get searchEmptyTitle =>
      'You don’t need to remember where it came from';

  @override
  String get searchEmptyBody =>
      'Try an English or Arabic title, a note, or a website domain.';
}
