// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Stashly';

  @override
  String get tagline => 'كل ما يستحق الاحتفاظ به';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionTryAgain => 'إعادة المحاولة';

  @override
  String get actionLoadMore => 'تحميل المزيد';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionDismiss => 'تجاهل';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionPrevious => 'السابق';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionGetStarted => 'ابدأ الآن';

  @override
  String get actionSaveChanges => 'حفظ التغييرات';

  @override
  String get actionDiscard => 'تجاهل التغييرات';

  @override
  String get actionKeepEditing => 'متابعة التعديل';

  @override
  String get actionSignIn => 'تسجيل الدخول';

  @override
  String get actionCreateAccount => 'إنشاء حساب';

  @override
  String get actionSignOut => 'تسجيل الخروج';

  @override
  String get actionAccept => 'موافقة';

  @override
  String get labelOptional => 'اختياري';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String fieldValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get or => 'أو';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCollections => 'المجموعات';

  @override
  String get navSaveLink => 'حفظ رابط';

  @override
  String get navSearch => 'البحث';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get allSavedItems => 'كل العناصر المحفوظة';

  @override
  String get updateEyebrow => 'التحديث مطلوب';

  @override
  String get updateTitle => 'يرجى تحديث Stashly';

  @override
  String get updateBody =>
      'لم يعد هذا الإصدار مدعومًا. ثبّت أحدث إصدار من متجر Play للمتابعة.';

  @override
  String updateBodyVersion(String version) {
    return 'لم يعد هذا الإصدار مدعومًا. ثبّت الإصدار $version من متجر Play للمتابعة.';
  }

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String greetingMorning(String name) {
    return 'صباح الخير، $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'طاب يومك، $name';
  }

  @override
  String greetingEvening(String name) {
    return 'مساء الخير، $name';
  }

  @override
  String get greetingMorningPlain => 'صباح الخير';

  @override
  String get greetingAfternoonPlain => 'طاب يومك';

  @override
  String get greetingEveningPlain => 'مساء الخير';

  @override
  String memberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String get failureValidation => 'يرجى مراجعة الحقول المحددة.';

  @override
  String get failureInvalidUrl => 'أدخل رابط http أو https صالحًا.';

  @override
  String get failureInvalidCursor => 'تغيّرت القائمة. اسحب للتحديث.';

  @override
  String get failureLimit => 'لقد بلغت الحد المسموح لهذا العنصر.';

  @override
  String get failureResetToken =>
      'رابط إعادة التعيين غير صالح أو منتهي الصلاحية.';

  @override
  String get failureCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get failureGoogleToken =>
      'تعذّر تسجيل الدخول باستخدام Google. حاول مرة أخرى.';

  @override
  String get failureGoogleUnavailable =>
      'تسجيل الدخول باستخدام Google غير متاح على هذا الجهاز حاليًا.';

  @override
  String get failureGoogleNotConfigured =>
      'لم يُفعَّل تسجيل الدخول باستخدام Google في هذا الإصدار بعد.';

  @override
  String get failureSession => 'انتهت جلستك. يرجى تسجيل الدخول.';

  @override
  String get failureForbidden => 'ليست لديك صلاحية الوصول إلى هذا العنصر.';

  @override
  String get failureNotFound => 'لم يعد هذا العنصر موجودًا.';

  @override
  String get failureDuplicate => 'هذا الرابط محفوظ في Stashly لديك بالفعل.';

  @override
  String get failureRateLimited => 'طلبات كثيرة جدًا. يرجى الانتظار قليلًا.';

  @override
  String failureRateLimitedSeconds(int seconds) {
    return 'طلبات كثيرة جدًا. حاول مرة أخرى بعد $seconds ث.';
  }

  @override
  String get failureServer => 'حدث خطأ من جهتنا. حاول مرة أخرى.';

  @override
  String get failureUnavailable =>
      'Stashly غير متاح مؤقتًا. حاول مرة أخرى بعد قليل.';

  @override
  String get failureOffline => 'أنت غير متصل. تحقّق من اتصالك.';

  @override
  String get failureTimeout => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get failureUnknown => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get discardTitle => 'تجاهل التغييرات؟';

  @override
  String get discardMessage => 'لديك تعديلات لم تُحفظ بعد.';

  @override
  String get urlEmpty => 'الصق رابطًا لحفظه.';

  @override
  String urlTooLong(int max) {
    return 'يجب ألا يزيد طول الرابط على $max حرف.';
  }

  @override
  String get urlScheme => 'يمكن حفظ روابط http وhttps فقط.';

  @override
  String get urlInvalid => 'أدخل رابط ويب صالحًا.';

  @override
  String get createCollection => 'إنشاء مجموعة';

  @override
  String get collectionName => 'اسم المجموعة';

  @override
  String get nothingHereYet => 'لا يوجد شيء هنا بعد.';

  @override
  String get enterAName => 'أدخل اسمًا.';

  @override
  String get clearSelection => 'إلغاء التحديد';

  @override
  String tagTooLong(int max) {
    return 'يجب ألا يزيد طول الوسم على $max حرفًا.';
  }

  @override
  String tooManyTags(int max) {
    return 'يمكن أن يحمل العنصر $max وسمًا كحد أقصى.';
  }

  @override
  String get itemTagsEyebrow => 'وسوم العنصر';

  @override
  String get editTags => 'تعديل الوسوم';

  @override
  String get addTags => 'إضافة وسوم';

  @override
  String get saveTags => 'حفظ الوسوم';

  @override
  String get findOrCreateTag => 'ابحث عن وسم أو أنشئ واحدًا';

  @override
  String get suggestions => 'اقتراحات';

  @override
  String removeItem(String label) {
    return 'إزالة $label';
  }

  @override
  String get previewPending => 'المعاينة قيد التجهيز';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get moreActions => 'إجراءات أخرى';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String cardLabel(String title, String domain) {
    return '$title، $domain';
  }

  @override
  String get deleteItemTitle => 'حذف هذا العنصر المحفوظ؟';

  @override
  String deleteItemMessage(String title) {
    return 'ستتم إزالة «$title» من مكتبتك. لن يتأثر المحتوى الأصلي.';
  }

  @override
  String get keepItem => 'الإبقاء على العنصر';

  @override
  String get linkCopied => 'تم نسخ الرابط';

  @override
  String get itemDeleted => 'تم حذف العنصر';

  @override
  String get offlineTitle => 'أنت غير متصل';

  @override
  String get loadFailedTitle => 'تعذّر التحميل';

  @override
  String get emailRequired => 'أدخل بريدك الإلكتروني.';

  @override
  String get emailInvalid => 'أدخل عنوان بريد إلكتروني صالحًا.';

  @override
  String get passwordTooShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get passwordTooLong => 'استخدم 128 حرفًا كحد أقصى.';

  @override
  String get nameRequired => 'أخبرنا كيف نناديك.';

  @override
  String get nameTooLong => 'استخدم 100 حرف كحد أقصى.';

  @override
  String get passwordRequired => 'أدخل كلمة المرور.';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get acceptTermsRequired => 'يرجى الموافقة على الشروط للمتابعة.';

  @override
  String get documentUnavailable => 'هذا المستند غير متاح بعد.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get newPasswordHint => '8 أحرف على الأقل';

  @override
  String get sessionEnded => 'انتهت جلستك. يرجى تسجيل الدخول مجددًا.';

  @override
  String get welcomeEyebrow => 'محفظتك للمحتوى الرقمي';

  @override
  String get welcomeTitle => 'احفظ كل ما يستحق الاحتفاظ به.';

  @override
  String get welcomeBody =>
      'اجمع الروابط المفيدة من أي مكان، ونظّمها على طريقتك، واعثر عليها حين تحتاجها.';

  @override
  String get welcomePointSave => 'احفظ الروابط في ثوانٍ';

  @override
  String get welcomePointOrganize => 'نظّم متى شئت';

  @override
  String get welcomePointSearch => 'ابحث في كل ما حفظته';

  @override
  String get welcomeFootnote =>
      'يحتفظ Stashly بالرابط وتفاصيله فقط — ولا يحفظ نسخة من المحتوى أبدًا.';

  @override
  String get signInTitle => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول لتعود إلى كل ما احتفظت به.';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get newToStashly => 'جديد على Stashly؟';

  @override
  String get createAccountLink => 'إنشاء حساب';

  @override
  String get registerTitle => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'ابدأ مجموعة يسهل الرجوع إليها.';

  @override
  String get displayNameLabel => 'الاسم الظاهر';

  @override
  String get displayNameHint => 'كيف نخاطبك؟';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أدخلها مرة أخرى';

  @override
  String get termsPrefix => 'أوافق على ';

  @override
  String get termsLink => 'شروط';

  @override
  String get termsAnd => ' Stashly و';

  @override
  String get privacyLink => 'سياسة الخصوصية';

  @override
  String get termsSuffix => '.';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get resetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetSubtitle => 'أدخل البريد الإلكتروني المرتبط بحسابك.';

  @override
  String get resetNotice =>
      'سنرسل رابط إعادة تعيين آمنًا إن كان هناك حساب. تنتهي صلاحيته بعد 60 دقيقة.';

  @override
  String get resetSentEyebrow => 'تم إرسال الرابط';

  @override
  String get checkInboxTitle => 'الآن، تفقّد بريدك';

  @override
  String get checkInboxBefore => 'إن كان هناك حساب مرتبط بـ ';

  @override
  String get checkInboxAfter =>
      '، فرابط إعادة تعيين كلمة المرور في طريقه إليك.';

  @override
  String get checkInboxStepOpen => 'افتح الرابط الآمن في الرسالة.';

  @override
  String get checkInboxStepChoose =>
      'اختر كلمة مرور جديدة، ثم عد لتسجيل الدخول.';

  @override
  String get returnToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get yourEmailFallback => 'بريدك الإلكتروني';

  @override
  String get googleTermsTitle => 'أنشئ حسابك في Stashly';

  @override
  String get googleTermsBody =>
      'حساب Google هذا جديد على Stashly. وافق على الشروط لإنشاء حسابك.';

  @override
  String get readTerms => 'قراءة الشروط';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get onboardingSaveEyebrow => 'احفظ في لحظة';

  @override
  String get onboardingSaveTitle => 'احفظ ما يهمك';

  @override
  String get onboardingSaveBody =>
      'شارك الروابط المفيدة من التطبيقات التي تستخدمها. يحتفظ Stashly بالمصدر، لا بنسخة منزّلة.';

  @override
  String get onboardingOrganizeEyebrow => 'اجعله على طريقتك';

  @override
  String get onboardingOrganizeTitle => 'نظّم عالمك';

  @override
  String get onboardingOrganizeBody =>
      'المجموعات والوسوم تمنحك التنظيم حين تريده، وتبتعد عن طريقك حين لا تحتاجها.';

  @override
  String get onboardingFindEyebrow => 'جاهز متى احتجته';

  @override
  String get onboardingFindTitle => 'اعثر عليه حين تحتاجه';

  @override
  String get onboardingFindBody =>
      'ابحث في العناوين والمصادر والمجموعات والمفضلة لتعثر على الرابط المناسب بسرعة.';

  @override
  String onboardingStep(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get artSavedTitle => 'مساحات تستحق التذكّر';

  @override
  String get artLearning => 'تعلّم';

  @override
  String get artInspiration => 'إلهام';

  @override
  String artSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محفوظ',
      many: '$count محفوظًا',
      few: '$count محفوظات',
      two: 'محفوظان',
      one: 'محفوظ واحد',
      zero: 'لا محفوظات',
    );
    return '$_temp0';
  }

  @override
  String get artCurated => 'مختارة';

  @override
  String get artQuery => 'إلهام تصميمي';

  @override
  String get artResultTitle => 'مساحات عصرية هادئة';

  @override
  String get artResultTitle2 => 'أنظمة هوية تستحق العودة';

  @override
  String artIdeasFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فكرة',
      many: '$count فكرة',
      few: '$count أفكار',
      two: 'فكرتان',
      one: 'فكرة واحدة',
      zero: 'لا أفكار',
    );
    return '$_temp0';
  }

  @override
  String get artTagInteriors => '#ديكور';

  @override
  String get artTagIdeas => '#أفكار';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصرًا',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }

  @override
  String get collectionsEyebrow => 'منظّمة على طريقتك';

  @override
  String get collectionsSubtitle =>
      'مجموعات شخصية يمكن أن تتداخل بقدر تداخل اهتماماتك.';

  @override
  String get startOrganizing => 'ابدأ التنظيم';

  @override
  String get startOrganizingBody =>
      'أنشئ مجموعة لتجميع الروابط المترابطة. ويمكن أن ينتمي الرابط إلى أكثر من مجموعة.';

  @override
  String get newCollection => 'مجموعة جديدة';

  @override
  String get deleteCollectionTitle => 'حذف هذه المجموعة؟';

  @override
  String deleteCollectionMessage(String name) {
    return 'ستتم إزالة «$name». ستبقى الروابط التي فيها في مكتبتك.';
  }

  @override
  String get keepIt => 'الإبقاء عليها';

  @override
  String get collectionDeleted => 'تم حذف المجموعة';

  @override
  String get membershipEyebrow => 'عناصر المجموعة';

  @override
  String get addExistingItems => 'إضافة عناصر محفوظة';

  @override
  String membershipHelper(String name) {
    return 'اختر الروابط لـ $name. إزالة أي رابط من هنا تبقيه في مكتبتك.';
  }

  @override
  String get saveMembership => 'حفظ العناصر';

  @override
  String get libraryEmpty => 'مكتبتك فارغة.';

  @override
  String get collectionUpdated => 'تم تحديث المجموعة';

  @override
  String get editCollection => 'تعديل المجموعة';

  @override
  String get addExisting => 'إضافة عناصر';

  @override
  String get searchInCollection => 'ابحث داخل هذه المجموعة';

  @override
  String get collectionEmpty => 'هذه المجموعة فارغة';

  @override
  String get collectionNoMatches => 'لا نتائج في هذه المجموعة';

  @override
  String get collectionEmptyHint =>
      'استخدم «إضافة عناصر» لجلب الروابط، أو نظّمها من أي عنصر.';

  @override
  String get tryBroaderWord => 'جرّب كلمة أعمّ.';

  @override
  String sortLabel(String label) {
    return 'الترتيب: $label';
  }

  @override
  String get collectionNameRequired => 'امنح مجموعتك اسمًا.';

  @override
  String get newCollectionEyebrow => 'مجموعة جديدة';

  @override
  String get collectionEyebrow => 'مجموعة';

  @override
  String get collectionNameHint => 'مثال: مشاريع نهاية الأسبوع';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descriptionHint => 'ما الذي ينتمي إلى هنا؟';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String get browseAll => 'تصفّح الكل';

  @override
  String get yourSpace => 'مساحتك';

  @override
  String get recentlySaved => 'المحفوظ مؤخرًا';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get filterAll => 'الكل';

  @override
  String get moreFilters => 'مزيد من عوامل التصفية';

  @override
  String get nothingSavedYet => 'لا يوجد شيء محفوظ بعد';

  @override
  String noItemsOfType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'video': 'لا مقاطع فيديو بعد',
      'article': 'لا مقالات بعد',
      'product': 'لا منتجات بعد',
      'social': 'لا منشورات بعد',
      'other': 'لا عناصر أخرى بعد',
    });
    return '$_temp0';
  }

  @override
  String get homeEmptyBody =>
      'شارك رابطًا من أي تطبيق، أو اضغط «حفظ رابط» لإضافته.';

  @override
  String get homeEmptyTypeBody => 'ستظهر العناصر من هذا النوع هنا.';

  @override
  String get homeSubtitle => 'كل ما يستحق الاحتفاظ به، حيث تركته تمامًا.';

  @override
  String get homeSearchHint => 'ابحث في العناوين والمصادر والمجموعات…';

  @override
  String get searchFilters => 'عوامل تصفية البحث';

  @override
  String get saveLink => 'حفظ رابط';

  @override
  String get favorites => 'المفضلة';

  @override
  String savedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر محفوظ',
      many: '$count عنصرًا محفوظًا',
      few: '$count عناصر محفوظة',
      two: 'عنصران محفوظان',
      one: 'عنصر محفوظ',
      zero: 'لا شيء محفوظ',
    );
    return '$_temp0';
  }

  @override
  String favoritesTileLabel(String saved) {
    return 'المفضلة، $saved';
  }

  @override
  String contentType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'video': 'فيديو',
      'article': 'مقالات',
      'product': 'منتجات',
      'social': 'تواصل',
      'other': 'أخرى',
    });
    return '$_temp0';
  }

  @override
  String linkSort(String sort) {
    String _temp0 = intl.Intl.selectLogic(sort, {
      'newest': 'الأحدث',
      'oldest': 'الأقدم',
      'other': '$sort',
    });
    return '$_temp0';
  }

  @override
  String get collectionsUpdated => 'تم تحديث المجموعات';

  @override
  String get incomingLink => 'رابط وارد';

  @override
  String get alreadyEyebrow => 'موجود في Stashly';

  @override
  String get alreadyTitle => 'لقد حفظت هذا الرابط من قبل';

  @override
  String get alreadyBody =>
      'لم يتم إنشاء نسخة مكررة. يمكنك فتح العنصر الموجود أو تنظيمه أكثر.';

  @override
  String get openSavedItem => 'فتح العنصر المحفوظ';

  @override
  String get addToCollection => 'إضافة إلى مجموعة';

  @override
  String get editPersonalNote => 'تعديل الملاحظة الشخصية';

  @override
  String get openMyLibrary => 'فتح مكتبتي';

  @override
  String get changesSaved => 'تم حفظ التغييرات';

  @override
  String get savedItemEyebrow => 'عنصر محفوظ';

  @override
  String get editDetails => 'تعديل التفاصيل';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get titleHint => 'أضف عنوانًا يسهل تذكّره';

  @override
  String get originalUrl => 'الرابط الأصلي';

  @override
  String get personalNote => 'ملاحظة شخصية';

  @override
  String get noteHint => 'لماذا يستحق الاحتفاظ به؟';

  @override
  String get tagsLabel => 'الوسوم';

  @override
  String get tagsHint => 'سفر، إيطاليا، أفلام';

  @override
  String get sharedTagsHint => 'سفر، مشاهدة لاحقًا';

  @override
  String get collectionLabel => 'المجموعة';

  @override
  String get libraryEyebrow => 'مكتبة محتواك';

  @override
  String get listLayout => 'عرض القائمة';

  @override
  String get gridLayout => 'عرض الشبكة';

  @override
  String get noFilterMatches => 'لا شيء يطابق عوامل التصفية هذه';

  @override
  String get noFilterMatchesBody => 'جرّب نوعًا آخر أو أوقف تصفية المفضلة.';

  @override
  String get libraryEmptyBody =>
      'شارك رابطًا إلى Stashly أو اضغط + لحفظ أول رابط لك.';

  @override
  String get openFailed => 'تعذّر فتح هذا الرابط.';

  @override
  String get savedItemTitle => 'عنصر محفوظ';

  @override
  String get openOriginal => 'فتح الأصل';

  @override
  String get copyLinkButton => 'نسخ الرابط';

  @override
  String get savedLabel => 'تاريخ الحفظ';

  @override
  String get descriptionEyebrow => 'الوصف';

  @override
  String get tagsEyebrow => 'الوسوم';

  @override
  String get noTagsYet => 'لا وسوم بعد.';

  @override
  String get addToFavoritesButton => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavoritesButton => 'إزالة من المفضلة';

  @override
  String get organizeIntoCollections => 'تنظيم في مجموعات';

  @override
  String get deleteSavedItem => 'حذف العنصر المحفوظ';

  @override
  String get fetchingDetails => 'جارٍ جلب التفاصيل…';

  @override
  String get noDescription => 'لا يتوفر وصف.';

  @override
  String get previewBlocked => 'لا يمكن معاينة هذه الصفحة.';

  @override
  String get previewFailed => 'تعذّر تحميل المعاينة.';

  @override
  String get refreshPreview => 'تحديث المعاينة';

  @override
  String get organizeEyebrow => 'تنظيم';

  @override
  String get addToCollections => 'إضافة إلى المجموعات';

  @override
  String get organizeHelper =>
      'اختر أي عدد من المجموعات. ألغِ تحديد الكل لإبقاء العنصر دون تصنيف.';

  @override
  String get selected => 'محدد';

  @override
  String get noCollectionsYet => 'لا مجموعات بعد. أنشئ أول مجموعة أدناه.';

  @override
  String get unsorted => 'دون تصنيف';

  @override
  String get savedToStashly => 'تم الحفظ في Stashly';

  @override
  String get addToStashlyEyebrow => 'أضف إلى Stashly';

  @override
  String get saveToStashly => 'حفظ في Stashly';

  @override
  String get urlLabel => 'الرابط';

  @override
  String get previewNotice =>
      'سنجلب معاينة عند توفرها. ويمكنك الحفظ دائمًا من دونها.';

  @override
  String get shareNoLink =>
      'لا تحتوي هذه المشاركة على رابط ويب يمكن لـ Stashly حفظه.';

  @override
  String get linkCantBeSaved => 'لا يمكن حفظ هذا الرابط.';

  @override
  String get sharedToStashly => 'تمت المشاركة إلى Stashly';

  @override
  String get storageNotice =>
      'يُحفظ الرابط وبياناته المتاحة فقط، لا الفيديو أو الصورة الأصلية.';

  @override
  String get saveNow => 'احفظ الآن';

  @override
  String get cantSaveThis => 'لا يمكن حفظ هذا';

  @override
  String get lookingForPreview => 'جارٍ البحث عن معاينة…';

  @override
  String get lookingForPreviewBody =>
      'يمكنك الحفظ فورًا؛ وقد تصل التفاصيل لاحقًا.';

  @override
  String get previewReady => 'المعاينة جاهزة';

  @override
  String get previewReadyBody => 'تم العثور على العنوان والصورة المصغّرة.';

  @override
  String get previewPartial => 'معاينة جزئية';

  @override
  String get previewPartialBody =>
      'تم العثور على بعض التفاصيل. سنواصل البحث بعد الحفظ.';

  @override
  String get previewNone => 'لا معاينة بعد';

  @override
  String get previewNoneBody =>
      'احفظ الآن — سنحاول جلب العنوان والصورة في الخلفية.';

  @override
  String get previewUnavailable => 'المعاينة غير متاحة';

  @override
  String get previewUnavailableBody =>
      'لا يمكن معاينة هذه الصفحة، لكن يمكنك حفظ الرابط.';

  @override
  String get offlineSaveBody => 'اتصل بالإنترنت لحفظ هذا الرابط.';

  @override
  String get nameLength => 'استخدم من 1 إلى 100 حرف.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get accountEyebrow => 'الحساب';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailLocked =>
      'بريدك الإلكتروني هو وسيلة تسجيل دخولك ولا يمكن تغييره حاليًا.';

  @override
  String get currentPasswordRequired => 'أدخل كلمة المرور الحالية.';

  @override
  String get choosePasswordNew => 'اختر كلمة مرور لم تستخدمها هنا من قبل.';

  @override
  String get passwordUpdated =>
      'تم تحديث كلمة المرور. وتم تسجيل الخروج من الأجهزة الأخرى.';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle =>
      'أكّد كلمة المرور الحالية، ثم اختر كلمة جديدة.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get currentPasswordHint => 'أدخل كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get confirmNewPasswordHint => 'أدخلها مجددًا';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get otherDevicesNotice =>
      'حفاظًا على أمانك، سيتم تسجيل الخروج من الأجهزة الأخرى.';

  @override
  String get profileEyebrow => 'Stashly الخاص بك';

  @override
  String get settings => 'الإعدادات';

  @override
  String get totalSaves => 'إجمالي المحفوظات';

  @override
  String get walletTitle => 'محفظة محتوى شخصية';

  @override
  String get walletBody =>
      'يحفظ Stashly روابطك وبياناتها، لا نسخًا منزّلة من الأصل.';

  @override
  String get settingsRowSubtitle => 'الحساب والخصوصية وحول التطبيق';

  @override
  String statLabel(int value, String label) {
    return '$value $label';
  }

  @override
  String get exportSubject => 'تصدير بياناتي من Stashly';

  @override
  String get signOutTitle => 'تسجيل الخروج؟';

  @override
  String get signOutBody =>
      'يمكنك تسجيل الخروج من هذا الجهاز فقط، أو من كل الأجهزة المسجّلة في حسابك.';

  @override
  String get signOutThisDevice => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get signOutEverywhere => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get aboutBody =>
      'محفظة شخصية للروابط التي تستحق الاحتفاظ بها. يحفظ Stashly الرابط وتفاصيله، ولا يحفظ نسخة من المحتوى أبدًا.';

  @override
  String get changePasswordRowSubtitle =>
      'أكّد كلمة المرور الحالية لتعيين كلمة جديدة';

  @override
  String get setPasswordViaForgot =>
      'استخدم «نسيت كلمة المرور» لتعيين كلمة مرور';

  @override
  String get appearanceGroup => 'المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeDarkSubtitle => 'المظهر المميّز لـ Stashly';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeLightSubtitle => 'ساطع وسهل القراءة في ضوء النهار';

  @override
  String get themeSystem => 'مطابقة الجهاز';

  @override
  String get themeSystemSubtitle => 'يتبع إعداد الوضع الداكن في هاتفك';

  @override
  String get languageGroup => 'اللغة';

  @override
  String get languageDevice => 'لغة الجهاز';

  @override
  String get languageDeviceSubtitle => 'العربية أو الإنجليزية، حسب هاتفك';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageArabicSubtitle => 'العربية';

  @override
  String get dataGroup => 'البيانات والخصوصية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacySubtitle => 'كيف يتعامل Stashly مع بياناتك';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get termsSubtitle => 'اتفاقية استخدام Stashly';

  @override
  String get exportData => 'تصدير بياناتي';

  @override
  String get exportPreparing => 'جارٍ تجهيز ملفك…';

  @override
  String get exportSubtitle => 'نزّل كل شيء كملف JSON';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountSubtitle => 'يزيل حسابك وعناصرك المحفوظة نهائيًا';

  @override
  String get aboutGroup => 'حول';

  @override
  String get aboutStashly => 'حول Stashly';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String versionValue(String version) {
    return 'الإصدار $version';
  }

  @override
  String get buildBadge => 'بناء';

  @override
  String get passwordConfirmRequired => 'أدخل كلمة المرور للتأكيد.';

  @override
  String get deleteAccountTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'سيؤدي هذا إلى حذف حسابك وروابطك المحفوظة ومجموعاتك ووسومك نهائيًا، ولا يمكن التراجع عنه. صدّر بياناتك أولًا إن أردت نسخة منها.';

  @override
  String get confirmWithGoogleNotice => 'ستؤكّد باستخدام حسابك في Google.';

  @override
  String get yourPasswordHint => 'كلمة المرور';

  @override
  String get keepAccount => 'الإبقاء على الحساب';

  @override
  String get refineEyebrow => 'تحسين النتائج';

  @override
  String get resetAll => 'إعادة تعيين الكل';

  @override
  String get applyFilters => 'تطبيق عوامل التصفية';

  @override
  String get contentTypeLabel => 'نوع المحتوى';

  @override
  String get sourceLabel => 'المنصة أو المصدر';

  @override
  String get dateSaved => 'تاريخ الحفظ';

  @override
  String get anyTime => 'أي وقت';

  @override
  String lastDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'آخر $days يوم',
      many: 'آخر $days يومًا',
      few: 'آخر $days أيام',
      two: 'آخر يومين',
      one: 'آخر يوم',
    );
    return '$_temp0';
  }

  @override
  String get favoritesOnly => 'المفضلة فقط';

  @override
  String get sortOrder => 'ترتيب العرض';

  @override
  String get searchEyebrow => 'اعثر عليه مجددًا';

  @override
  String get searchTitle => 'ابحث في محفوظاتك';

  @override
  String get searchSubtitle =>
      'ابحث في الكلمات المحفوظة مع روابطك، دون حاجة إلى ذكاء اصطناعي أو التطبيق المصدر.';

  @override
  String get searchHint => 'عنوان أو ملاحظة أو وصف أو مصدر…';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get filters => 'عوامل التصفية';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get suggestedSearches => 'عمليات بحث مقترحة';

  @override
  String get noMatches => 'لم يتم العثور على نتائج';

  @override
  String get noMatchesBody => 'جرّب كلمة أعمّ أو راجع عوامل التصفية.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String searchFor(String query) {
    return 'البحث عن $query';
  }

  @override
  String get searchEmptyTitle => 'لا داعي لتتذكّر من أين جاء';

  @override
  String get searchEmptyBody =>
      'جرّب عنوانًا بالعربية أو الإنجليزية، أو ملاحظة، أو نطاق موقع.';
}
