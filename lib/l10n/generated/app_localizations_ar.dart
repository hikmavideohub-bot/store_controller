// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة المنتجات';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get sessionExpired => 'انتهت صلاحية الجلسة. يرجى إعادة التحقق.';

  @override
  String get noStore => 'الحساب غير مسجل. يرجى إنشاء متجر جديد.';

  @override
  String get appearanceTitle => 'المظهر (Theme)';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'نهاري';

  @override
  String get themeDark => 'ليلي';

  @override
  String get contactAndAddressTitle => 'التواصل والعنوان';

  @override
  String get phoneNumberLabel => 'رقم الهاتف*';

  @override
  String get whatsappSameAsPhone => 'واتساب نفس رقم الهاتف؟';

  @override
  String get whatsappNumberLabel => 'رقم واتساب*';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get selectCountry => 'اختر الدولة';

  @override
  String get addressLabel => 'عنوان المتجر';

  @override
  String get addressHint => 'الشارع، الحي، المدينة...';

  @override
  String get useCurrentLocationTooltip => 'استخدام الموقع الحالي';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get loginEmailLabel => 'بريد تسجيل الدخول';

  @override
  String get googleAuthInfo =>
      'أنت مسجل عبر Google. يمكنك تعيين كلمة مرور لتمكين الدخول المباشر بالبريد.';

  @override
  String get passwordResetSent =>
      'تم إرسال رابط تعيين كلمة المرور إلى بريدك الإلكتروني';

  @override
  String get sendingStatus => 'جاري الإرسال...';

  @override
  String get sendResetLinkButton => 'إرسال رابط تعيين كلمة المرور';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور';

  @override
  String get changePasswordButton => 'تغيير كلمة المرور';

  @override
  String get forgotPasswordButton => 'نسيت كلمة المرور؟';

  @override
  String get storeFallbackName => 'متجرك';

  @override
  String get noEmail => 'لم يتم تحديد البريد';

  @override
  String statusTrialDays(Object days) {
    return 'تجريبي • $days يوم';
  }

  @override
  String get statusTrial => 'تجريبي';

  @override
  String get statusActive => 'مفعّل';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get statusSuspended => 'موقوف';

  @override
  String get statusUnknown => 'غير محدد';

  @override
  String get shippingTitle => 'التوصيل';

  @override
  String get shippingEnabled => 'التوصيل متاح';

  @override
  String get shippingEnabledSubtitle => 'تفعيل خدمة التوصيل للعملاء';

  @override
  String get shippingCostLabel => 'سعر التوصيل';

  @override
  String get shippingCostHint => '0.00';

  @override
  String get socialLinksTitle => 'الروابط والتواصل';

  @override
  String get socialTiktok => 'تيك توك';

  @override
  String get socialInstagram => 'إنستغرام';

  @override
  String get socialFacebook => 'فيسبوك';

  @override
  String get supportEmailLabel => 'ايميل المتجر';

  @override
  String get supportEmailHint => 'email@example.com';

  @override
  String get storeInfoTitle => 'معلومات المتجر';

  @override
  String get storeNameLabel => 'اسم المتجر*';

  @override
  String get storeDescLabel => 'وصف المتجر';

  @override
  String get storeDescHint => 'جودة عالية وأسعار مناسبة';

  @override
  String get storeDescHelper =>
      'يظهر هذا الوصف أسفل اسم المتجر في الموقع الالكتروني.';

  @override
  String createdAtDate(Object date) {
    return 'تم الإنشاء: $date';
  }

  @override
  String get currencyLabel => 'عملة المتجر*';

  @override
  String get workingHoursTitle => 'أوقات العمل';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get appearanceSectionTitle => 'مظهر';

  @override
  String get appearanceSectionSubtitle => 'تخصيص مظهر التطبيق';

  @override
  String get storeInfoSectionTitle => 'معلومات المتجر';

  @override
  String get storeInfoSectionSubtitle => 'الاسم، العملة، الوصف';

  @override
  String get contactSectionTitle => 'وسائل تواصل المتجر';

  @override
  String get contactSectionSubtitle => 'الهاتف، العنوان، الروابط الاجتماعية';

  @override
  String get otherSettingsSectionTitle => 'إعدادات أخرى';

  @override
  String get otherSettingsSectionSubtitle => 'أوقات العمل، التوصيل، الأمان';

  @override
  String get saveChangesButton => 'حفظ التغييرات';

  @override
  String get savingButton => 'جاري الحفظ...';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get saveSuccessMsg => 'تم حفظ التغييرات';

  @override
  String get saveErrorMsg => 'خطأ في الحفظ';

  @override
  String get setupStoreTitle => 'إعداد المتجر';

  @override
  String get stepIdentity => 'الهوية';

  @override
  String get stepContact => 'التواصل';

  @override
  String get stepDelivery => 'التوصيل';

  @override
  String get stepHours => 'الأوقات';

  @override
  String get stepFinish => 'النهاية';

  @override
  String get step1Title => 'لنبدأ بالأساسيات';

  @override
  String get step1Subtitle => 'اختر اسماً وشعاراً لمتجرك ليتعرف عليه العملاء';

  @override
  String get step2Title => 'معلومات التواصل';

  @override
  String get step2Subtitle =>
      'أدخل رقم الهاتف والعنوان ليتمكن العملاء من التواصل';

  @override
  String get step3Title => 'خدمة التوصيل';

  @override
  String get step3Subtitle => 'هل توفر خدمة التوصيل لزبائنك؟';

  @override
  String get enableDeliveryLabel => 'تفعيل التوصيل';

  @override
  String get deliveryEnabled => 'الخدمة مفعلة';

  @override
  String get deliveryDisabled => 'الخدمة متوقفة';

  @override
  String get fixedDeliveryPriceLabel => 'سعر التوصيل الثابت';

  @override
  String get deliveryPriceHelper =>
      'اتركه فارغاً لتحديد السعر لاحقاً لكل طلب على حدة';

  @override
  String get step4Title => 'متى يكون متجرك مفتوحاً؟';

  @override
  String get step4Subtitle => 'يمكنك تخطي هذه الخطوة وإضافتها لاحقاً';

  @override
  String get step5Title => 'تهانينا🏆';

  @override
  String get step5Subtitle =>
      'مبروك! اكتمل إعداد متجرك بنجاح 🎉\nاستمتع بالتجربة الآن وشارك رابط متجرك مع الجميع\nحان الوقت ليرى العالم منتجاتك!\n\nلا تنسَ زيارة «نصائح مفيدة» في القائمة\nستجد أسراراً تسرّع نمو مبيعاتك.';

  @override
  String get step5SubtitleWeb =>
      'For iPhone users: Tap the Share button and select \'Add to Home Screen\' for a better experience.';

  @override
  String get shortDescriptionLabel => 'وصف قصير للمتجر (اختياري)';

  @override
  String get optionalBadge => 'اختياري';

  @override
  String get skipButton => 'تخطي';

  @override
  String get nextButton => 'التالي';

  @override
  String get finishSetupButton => 'إنهاء الإعداد';

  @override
  String get validationEnterStoreName => 'الرجاء إدخال اسم المتجر';

  @override
  String get validationEnterPhone => 'الرجاء إدخال رقم الهاتف';

  @override
  String get logoutConfirmMsg => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutConfirmButton => 'خروج';

  @override
  String locationFetchError(Object error) {
    return 'خطأ في تحديد الموقع: $error';
  }

  @override
  String get fillAllFieldsError => 'يرجى ملء جميع الحقول';

  @override
  String get passwordsNotMatch => 'كلمة المرور غير متطابقة';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';

  @override
  String generalError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get storeNameRequired => 'اسم المتجر مطلوب';

  @override
  String get noEditPermission => 'لا تملك صلاحية التعديل';

  @override
  String get addProductTitle => 'إضافة منتج';

  @override
  String get editProductTitle => 'تعديل المنتج';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get productNameLabel => 'اسم المنتج';

  @override
  String get priceLabel => 'السعر';

  @override
  String get newCategoryLabel => 'فئة جديدة';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get addNewCategory => 'إضافة جديد';

  @override
  String get sizeLabel => 'الحجم';

  @override
  String get unitLabel => 'الوحدة';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descQuality => 'جودة عالية ومذاق رائع';

  @override
  String get descFresh => 'طازج ويومي';

  @override
  String get descBestseller => 'الأكثر مبيعاً لدينا';

  @override
  String get descLimited => 'عرض لفترة محدودة';

  @override
  String get descHandmade => 'صناعة يدوية فاخرة';

  @override
  String get descNatural => 'طبيعي 100%';

  @override
  String get productAvailable => 'المنتج متوفر';

  @override
  String get visibleToCustomers => 'يظهر للعملاء';

  @override
  String get hiddenFromCustomers => 'مخفي عن العملاء';

  @override
  String get specialOfferAvailable => 'إضافة عرض خاص';

  @override
  String get specialOfferSubtitle => 'تفعيل الخصومات أو عروض الجملة';

  @override
  String get offerTypeLabel => 'نوع العرض';

  @override
  String get offerTypePercent => 'نسبة مئوية %';

  @override
  String get offerTypeBundle => 'عرض باقة';

  @override
  String get offerTypeBulk => 'سعر الجملة';

  @override
  String get percentageLabel => 'النسبة (%)';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get totalPriceLabel => 'السعر الإجمالي';

  @override
  String get quantityStartLabel => 'الكمية (بدءاً)';

  @override
  String get pricePerPieceLabel => 'سعر القطعة';

  @override
  String get offerDurationLabel => 'مدة العرض';

  @override
  String get saveButton => 'حفظ';

  @override
  String get productPublishedMsg => 'تم نشر المنتج';

  @override
  String get uploading => 'جاري رفع الصورة...';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get errorStatus => 'خطأ';

  @override
  String get productImageLabel => 'صورة المنتج';

  @override
  String get tapToUpload => 'اضغط لرفع صورة';

  @override
  String get optionalSuffix => '(اختياري)';

  @override
  String get unitKg => 'كغ';

  @override
  String get unitG => 'غرام';

  @override
  String get unitL => 'لتر';

  @override
  String get unitMl => 'مل';

  @override
  String get unitPcs => 'قطعة';

  @override
  String get deleteCategoryTitle => 'حذف الفئة';

  @override
  String deleteCategoryMsg(Object name) {
    return 'هل تريد حذف \"$name\" ؟ سيتم نقل المنتجات إلى \"اخرى\".';
  }

  @override
  String get categoriesLoadError => 'تعذر تحميل الفئات';

  @override
  String get categoryRenameTitle => 'تعديل الفئة';

  @override
  String get categoryRenameLabel => 'اسم الفئة الجديد';

  @override
  String get categoryRenameSuccess => 'تم تعديل الفئة بنجاح';

  @override
  String get categoryRenameFail => 'فشل تعديل الفئة';

  @override
  String get categoryRenameError => 'حدث خطأ أثناء تعديل الفئة';

  @override
  String deleteCategoryConfirmMsg(Object moveTo, Object name) {
    return 'سيتم نقل كل المنتجات من \"$name\" إلى \"$moveTo\". هل أنت متأكد؟';
  }

  @override
  String get categoryDeleteSuccess => 'تم حذف الفئة بنجاح';

  @override
  String get categoryDeleteFail => 'فشل حذف الفئة';

  @override
  String get categoryDeleteError => 'حدث خطأ أثناء حذف الفئة';

  @override
  String productsCount(Object count) {
    return '$count منتج';
  }

  @override
  String get viewProductsAction => 'عرض المنتجات';

  @override
  String get viewProductsSubtitle => 'فتح قائمة منتجات هذه الفئة';

  @override
  String get applyCategoryOfferAction => 'تطبيق عرض على الفئة';

  @override
  String get applyCategoryOfferSubtitle => 'تخفيض بنسبة مئوية لجميع المنتجات';

  @override
  String get stopCategoryOffersAction => 'إيقاف عروض الفئة';

  @override
  String get stopCategoryOffersSubtitle =>
      'إلغاء تفعيل جميع العروض في هذه الفئة';

  @override
  String get categoryFullOfferTitle => 'عرض فئة كاملة';

  @override
  String applyToCategorySubtitle(Object category) {
    return 'تطبيق على \"$category\"';
  }

  @override
  String get percentageHint => 'مثال: 15';

  @override
  String get offerValidityLabel => 'صلاحية العرض';

  @override
  String get invalidPercentageError => 'أدخل نسبة صحيحة';

  @override
  String get applyOfferButton => 'تطبيق العرض';

  @override
  String categoryOfferAppliedMsg(Object category) {
    return 'تم تطبيق العرض على فئة \"$category\"';
  }

  @override
  String get categoryOfferApplyFail => 'فشل تطبيق العرض';

  @override
  String categoryOffersDisabledMsg(Object category) {
    return 'تم إيقاف عروض فئة \"$category\"';
  }

  @override
  String get categoryOffersDisableFail => 'فشل إيقاف العروض';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String categoriesCountLabel(Object count) {
    return '$count فئة';
  }

  @override
  String get noCategoriesTitle => 'لا توجد فئات بعد';

  @override
  String get noCategoriesSubtitle => 'قم بإضافة فئات جديدة لتنظيم منتجاتك';

  @override
  String offerUntilDate(Object date) {
    return 'حتى $date';
  }

  @override
  String discountPercent(Object percent) {
    return 'خصم $percent%';
  }

  @override
  String bundleOfferLabel(Object currency, Object price, Object qty) {
    return '$qty بـ $price $currency';
  }

  @override
  String get offerLabel => 'عرض';

  @override
  String get availableStatus => ' متوفر';

  @override
  String get unavailableStatus => 'غير متوفر';

  @override
  String get updateFail => 'فشل التحديث';

  @override
  String get deleteProductTitle => 'حذف المنتج';

  @override
  String deleteProductConfirmMsg(Object name) {
    return 'هل تريد حذف \"$name\"؟';
  }

  @override
  String get deleteSuccess => 'تم الحذف';

  @override
  String get deleteFail => 'فشل الحذف';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get customerMessageTitle => 'رسالتك للعملاء';

  @override
  String get templateDiscountTitle => 'خصم خاص';

  @override
  String get templateDiscountText =>
      '🔥 خصم خاص 20% على جميع المنتجات لفترة محدودة! لا تفوتوا الفرصة.';

  @override
  String get templateWelcomeTitle => 'ترحيب';

  @override
  String get templateWelcomeText =>
      'أهلاً بكم في متجرنا! نتمنى لكم تجربة تسوق ممتعة وسعيدة. ✨';

  @override
  String get templateNewTitle => 'جديدنا';

  @override
  String get templateNewText =>
      'وصلت تشكيلة جديدة ومميزة! تصفحوا أحدث المنتجات الآن في المتجر. 🆕';

  @override
  String get templateDeliveryTitle => 'توصيل مجاني';

  @override
  String get templateDeliveryText =>
      'تسوق الآن واحصل على توصيل مجاني لجميع الطلبات فوق 50 يورو! 🚚';

  @override
  String get templateOccasionTitle => 'مناسبة';

  @override
  String get templateOccasionText =>
      'كل عام وأنتم بخير! بمناسبة العيد، استمتعوا بعروضنا الحصرية. 🌙';

  @override
  String get loadDataError => 'فشل تحميل البيانات';

  @override
  String get messagePublishedSuccess => 'تم نشر الرسالة بنجاح ✅';

  @override
  String get saveFailed => 'فشل الحفظ، حاول مرة أخرى';

  @override
  String get connectionError => 'حدث خطأ في الاتصال';

  @override
  String get messageDeleted => 'تم حذف الرسالة 🗑';

  @override
  String get deleteMessageTitle => 'حذف الرسالة';

  @override
  String get deleteMessageConfirm =>
      'هل أنت متأكد من حذف الرسالة؟ لن تظهر للعملاء بعد الآن.';

  @override
  String get chooseTemplateTitle => 'اختر نموذجاً جاهزاً';

  @override
  String get previewTitle => 'معاينة العرض للعملاء';

  @override
  String get editMessageTitle => 'تعديل الرسالة';

  @override
  String get templatesButton => 'نماذج جاهزة';

  @override
  String get displayDurationTitle => 'وقت عرض الرسالة';

  @override
  String get previewPlaceholder => 'هنا ستظهر رسالتك للعملاء...';

  @override
  String get messageHint =>
      'مثلاً: خصم 20% بمناسبة عيد الفطر المبارك على جميع المنتجات 🌙';

  @override
  String get engageTextHint => 'أدخل نصاً جذاباً لزيادة المبيعات';

  @override
  String get durationAlways => 'دائم';

  @override
  String get durationDay => 'يوم';

  @override
  String get duration3Days => '3 أيام';

  @override
  String get durationWeek => 'أسبوع';

  @override
  String get durationMonth => 'شهر';

  @override
  String get saveAndPublishButton => 'حفظ ونشر التعديلات';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get restorePasswordHeadline => 'استعادة كلمة المرور';

  @override
  String get restorePasswordDesc =>
      'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً لتعيين كلمة مرور جديدة.';

  @override
  String get enterEmailValidation => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get invalidEmailFormat => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get resetLinkSentMsg =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';

  @override
  String get emailNotRegistered => 'هذا البريد غير مسجل لدينا.';

  @override
  String get generalSendError =>
      'تعذر الإرسال الآن. تأكد من صحة البريد الإلكتروني.';

  @override
  String get sendLinkButton => 'إرسال الرابط';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get welcomeBack => 'أهلاً بك مجدداً!';

  @override
  String welcomeStoreName(Object storeName) {
    return 'مرحباً بك، $storeName';
  }

  @override
  String get validationEnterAddress => 'يرجى إدخال عنوان المتجر';

  @override
  String get dashboardSubtitle => 'إليك ملخص سريع لمتجرك اليوم';

  @override
  String get publicStoreLink => 'رابط المتجر العام';

  @override
  String get noLinkYet => 'لا يوجد رابط بعد';

  @override
  String get copyLinkSuccess => 'تم نسخ الرابط!';

  @override
  String get shareStoreInvite => 'مشاركة دعوة المتجر';

  @override
  String get customerMessagePlaceholder =>
      'لم يتم تعيين رسالة بعد. اضغط هنا للإضافة.';

  @override
  String get liveStatsTitle => 'الإحصائيات المباشرة';

  @override
  String get statsTotalProducts => 'المنتجات';

  @override
  String get statsAvailable => ' متوفر';

  @override
  String get statsUnavailable => 'غير متوفر';

  @override
  String get statsOffers => 'عروض';

  @override
  String get statsCategoryOffers => 'عروض الفئات';

  @override
  String get statsNoImage => 'بدون صورة';

  @override
  String get statsLargestCategory => 'أكبر فئة';

  @override
  String get filterAllProducts => 'جميع المنتجات';

  @override
  String get filterAvailable => 'منتجات متوفرة';

  @override
  String get filterUnavailable => 'منتجات غير متوفرة';

  @override
  String get filterActiveOffers => 'عروض نشطة';

  @override
  String get filterNoImage => 'منتجات بدون صورة';

  @override
  String filterCategoryPrefix(Object category) {
    return 'فئة: $category';
  }

  @override
  String noProductsFoundTitle(Object title) {
    return 'لا توجد منتجات: $title';
  }

  @override
  String get categoryOffersTitle => 'عروض الفئات الكاملة';

  @override
  String get categoryOffersSubtitle => 'فئات جميع منتجاتها في عرض';

  @override
  String get noCategoryOffers => 'لا توجد فئات بعروض كاملة';

  @override
  String get stopOfferAction => 'إيقاف';

  @override
  String get stopCategoryOfferSuccess => 'تم إيقاف عروض فئة';

  @override
  String get stopCategoryOfferConfirm =>
      'هل أنت متأكد؟ سيتم إيقاف جميع أنواع العروض في هذه الفئة.';

  @override
  String get expirationAlertTitle => 'تنبيه انتهاء التفعيل';

  @override
  String expirationAlertMsg(Object days) {
    return 'مرحباً! تفعيل متجرك سينتهي خلال $days أيام. يرجى التجديد الآن لضمان استمرار عمل متجرك دون انقطاع.';
  }

  @override
  String get renewNowButton => 'تفعيل الآن';

  @override
  String get laterButton => 'لاحقاً';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navStore => 'متجرك';

  @override
  String get activateButton => 'تفعيل';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'أدخل بيانات حسابك للوصول إلى متجرك';

  @override
  String get loginEmailOrPassError =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get noStoreTitle => 'لا يوجد متجر';

  @override
  String get noStoreMessage => 'هل تريد إنشاء متجر جديد باستخدام هذا الحساب؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get createStore => 'إنشاء متجر';

  @override
  String get loginNoPermission => 'ليس لديك صلاحية الوصول';

  @override
  String get googleLoginFailed => 'فشل تسجيل الدخول بـ Google';

  @override
  String get unexpectedError => 'عذراً، حدث خطأ غير متوقع.';

  @override
  String get googleSigningIn => 'جاري الدخول...';

  @override
  String get googleSignIn => 'الدخول بحساب Google';

  @override
  String get orSeparator => 'أو';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInButton => 'دخول';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get createNewStore => 'إنشاء متجر جديد';

  @override
  String get activationSuccessTitle => 'تم التفعيل بنجاح!';

  @override
  String get activationSuccessMsg => 'شكراً لك! لقد تم تفعيل متجرك بنجاح.';

  @override
  String get startNowButton => 'ابدأ الآن';

  @override
  String get loadingErrorPrefix => 'خطأ: ';

  @override
  String get choosePlanTitle => 'اختر باقتك';

  @override
  String get noPlansAvailable => 'لا توجد باقات متاحة حالياً';

  @override
  String get choosePlanSubtitle => 'اختر خطة الاشتراك المناسبة لك';

  @override
  String get savePercentage => 'توفير';

  @override
  String get paymentLinkError => 'لم يقم الخادم بإرجاع رابط الدفع';

  @override
  String get paymentPrepError =>
      'حدث خطأ أثناء تحضير عملية الدفع. يرجى المحاولة لاحقاً.';

  @override
  String payAndActivate(Object price) {
    return 'تفعيل';
  }

  @override
  String get featureUnlimitedProducts => 'مخزون واسع (حتى ٤٠٠ منتج)';

  @override
  String get featurePremiumSupport => 'دعم فني متميز';

  @override
  String get featureAdvancedStats => 'إحصائيات متقدمة (قيد التطوير)';

  @override
  String get featureNoCommission => 'بدون عمولة مبيعات';

  @override
  String get paymentAndActivationTitle => 'الدفع والتفعيل';

  @override
  String get adminContactLabel => 'مسؤول التفعيل';

  @override
  String get step1ChoosePlan => '1. اختر الباقة:';

  @override
  String get step2PaymentDetails => '2. بيانات الدفع (قم بالتحويل هنا):';

  @override
  String get qrCodePlaceholder => 'QR Code Photo';

  @override
  String get accountNumberLabel => 'رقم الحساب / ID';

  @override
  String get copyIdSuccess => 'تم نسخ المعرف';

  @override
  String get sendActivationInfoButton => 'أرسل معلومات التفعيل';

  @override
  String get afterPaymentInstruction =>
      'بعد إتمام الدفع، اضغط الزر لإرسال اسم متجرك ومعرفه تلقائياً.';

  @override
  String get sharePaymentConfirmTitle => 'إرسال تأكيد الدفع عبر';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get telegramLabel => 'Telegram';

  @override
  String get telegramCopySuccess => 'تم نسخ رسالتك! ألصقها في المحادثة.';

  @override
  String paymentMessageBody(
    Object planName,
    Object price,
    Object storeId,
    Object storeName,
  ) {
    return 'مرحباً، لقد قمت بتحويل المبلغ لتفعيل المتجر.\nيرجى التفعيل:\n\n🏪 *المتجر:* $storeName\n🆔 *المعرف:* $storeId\n📅 *الباقة:* $planName ($price)\n\nشكراً لك!';
  }

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get productsLoadError => 'تعذر تحميل المنتجات';

  @override
  String get productUpdateSuccess => 'تم تحديث المنتج بنجاح';

  @override
  String get productUpdateStatusFail => 'فشل تحديث حالة المنتج';

  @override
  String get offerUpdateFail => 'فشل تحديث العرض';

  @override
  String get productDeleteSuccess => 'تم حذف المنتج بنجاح';

  @override
  String get productDeleteFail => 'فشل حذف المنتج';

  @override
  String get filterTitle => 'الفلترة';

  @override
  String get filterReset => 'إعادة ضبط';

  @override
  String get filterApply => 'تطبيق';

  @override
  String get stockStatusLabel => 'الحالة';

  @override
  String get offersLabel => 'العروض';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterWithOffer => 'مع عرض';

  @override
  String get filterWithoutOffer => 'بدون عرض';

  @override
  String get filterActive => 'متوفر / نشط';

  @override
  String get filterInactive => 'غير متوفر / غير نشط';

  @override
  String get disableProduct => 'تعطيل المنتج';

  @override
  String get enableProduct => 'تفعيل المنتج';

  @override
  String get disableOffer => 'إيقاف العرض';

  @override
  String get enableOffer => 'تفعيل العرض';

  @override
  String get noSearchResults => 'لا توجد نتائج';

  @override
  String get noStoreFound => 'لم يتم العثور على متجر';

  @override
  String get noStoreMsg =>
      'قد تكون بيانات التطبيق قد حُذفت.\nيرجى تسجيل الدخول أو إعداد المتجر من جديد.';

  @override
  String get setupStoreButton => 'إعداد المتجر';

  @override
  String get reloginButton => 'تسجيل الدخول من جديد';

  @override
  String get registerTitle => 'إنشاء متجر';

  @override
  String get completeStoreCreation => 'أكمل إنشاء متجرك';

  @override
  String get enterStoreNamePrompt => 'أدخل اسم المتجر لإكمال التسجيل';

  @override
  String get googleAccountLabel => 'حساب Google';

  @override
  String get trialPeriodInfo => 'تجربة مجانية';

  @override
  String get createStoreButton => 'إنشاء المتجر';

  @override
  String get cancelAndReturnToLogin => 'إلغاء والعودة لتسجيل الدخول';

  @override
  String get registerNewStoreTitle => 'إنشاء متجر جديد';

  @override
  String get registerSubtitle => 'أنشئ متجرك واحصل على تجربة مجانية';

  @override
  String get googleRegisterButton => 'التسجيل بحساب Google';

  @override
  String get googleRegistering => 'جاري التسجيل...';

  @override
  String get storeNameHint => 'مثال: متجر الأصيل';

  @override
  String get storeNameTooShort => 'اسم المتجر قصير جداً (3 أحرف على الأقل)';

  @override
  String get requireEmailVerifyLabel => 'طلب تأكيد البريد من العملاء';

  @override
  String get requireEmailVerifySubtitle => 'العملاء الجدد يحتاجون تأكيد بريدهم';

  @override
  String get createAccountButton => 'إنشاء الحساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get registerFailedMsg => 'فشل إنشاء الحساب. حاول مرة أخرى';

  @override
  String errorOccurred(Object error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetLinkSentTitle => 'تم إرسال رابط إعادة التعيين';

  @override
  String checkEmailForResetMsg(Object username) {
    return 'يرجى التحقق من بريدك الإلكتروني ($username) واتباع الرابط لتغيير كلمة المرور الخاصة بك.';
  }

  @override
  String get backToLoginButton => 'العودة إلى تسجيل الدخول';

  @override
  String get subscriptionInfoTitle => 'تفاصيل الاشتراك';

  @override
  String get activePremiumTitle => 'اشتراك بريميوم فعال';

  @override
  String get activePremiumSubtitle => 'متجرك يعمل بكامل طاقته وبدون قيود';

  @override
  String get trialPeriodTitle => 'الفترة التجريبية';

  @override
  String trialRemaining(Object days) {
    return 'استمتع بـ $days يومًا كاملًا من تجربة المتجر المجانية!';
  }

  @override
  String get freeTrial => 'فترة تجريبية مجانية';

  @override
  String get subscriptionExpiredTitle => 'الاشتراك منتهي';

  @override
  String get subscriptionExpiredSubtitle => 'تم تعليق ميزات المتجر مؤقتاً';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get contactSupport => 'يرجى مراجعة الدعم الفني';

  @override
  String get planDetailsCardTitle => 'معلومات الخطة والتواريخ';

  @override
  String get storeLabel => 'المتجر';

  @override
  String get subscriptionTypeLabel => 'نوع الاشتراك';

  @override
  String get premiumYearly => 'بريميوم (سنوي)';

  @override
  String get trialFree => 'تجريبي / مجاني';

  @override
  String get creationDate => 'تاريخ الإنشاء';

  @override
  String get activatedAt => 'تم التفعيل في';

  @override
  String get subscriptionEndsAt => 'ينتهي الاشتراك في';

  @override
  String get trialStartedAt => 'بدأت التجربة في';

  @override
  String get trialEndsAt => 'تنتهي التجربة في';

  @override
  String get subscriptionEndedAt => 'انتهى الاشتراك في';

  @override
  String get trialEndedAt => 'انتهت التجربة في';

  @override
  String get currentBenefitsTitle => 'ميزات الاشتراك الحالية';

  @override
  String get benefitUnlimitedProducts => 'إضافة وإدارة منتجات غير محدودة';

  @override
  String get benefitHighQualityImages => 'عرض الصور بجودة عالية للعملاء';

  @override
  String get benefitShowPrices => 'ظهور الأسعار والقياسات في الموقع';

  @override
  String get benefitFullControl => 'التحكم الكامل في إعدادات المتجر';

  @override
  String get benefitDirectSupport => 'دعم فني مباشر وسريع';

  @override
  String get restrictionStagesTitle => 'مراحل تقييد المتجر';

  @override
  String get restrictionStage1 => 'إخفاء صور المنتجات من المتجر العام';

  @override
  String get restrictionStage2 => 'إخفاء الأسعار والقياسات وطرق التواصل';

  @override
  String get restrictionStage3 => 'إيقاف لوحة التحكم والمتجر بشكل كامل';

  @override
  String get renewSubscriptionButton => 'تجديد الاشتراك الآن';

  @override
  String get verifyEmailTitle => 'تأكيد البريد الإلكتروني';

  @override
  String get logoutTooltip => 'تسجيل الخروج';

  @override
  String get checkYourEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get sentLinkTo => 'لقد أرسلنا رابط تأكيد إلى:';

  @override
  String get verifyEmailInstructions =>
      'افتح بريدك الإلكتروني واضغط على رابط التأكيد.\nسيتم تحويلك تلقائياً بعد التأكيد.';

  @override
  String get checkNowButton => 'تحقق الآن';

  @override
  String get checkingStatus => 'جاري التحقق...';

  @override
  String get resendButton => 'لم يصلك البريد؟ إعادة الإرسال';

  @override
  String resendCountdown(Object seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get spamFolderHint =>
      'تحقق من مجلد البريد غير المرغوب فيه (Spam) إذا لم تجد الرسالة.';

  @override
  String get emailVerifiedSuccess => 'تم تأكيد البريد بنجاح!';

  @override
  String get verificationLinkSent => 'تم إرسال رابط التأكيد مرة أخرى';

  @override
  String verificationLinkSendFail(Object error) {
    return 'فشل إرسال الرابط: $error';
  }

  @override
  String get defaultEmailPlaceholder => 'بريدك الإلكتروني';

  @override
  String get drawerStoreFallback => 'متجرك';

  @override
  String supportEmailSubject(Object id, Object name) {
    return 'رسالة دعم فني من - $name \n (ID: $id)';
  }

  @override
  String supportEmailBody(Object id, Object name) {
    return '\nمعلومات المتجر:\nالاسم: $name\nالمعرف: $id \n---\n';
  }

  @override
  String get supportCenterTitle => 'مركز الدعم والمساعدة';

  @override
  String get supportCenterMsg =>
      'نحن هنا لمساعدتك! يسعدنا دائماً سماع استفساراتك أو اقتراحاتك لتطوير التطبيق.';

  @override
  String get contactEmailLabel => 'البريد الإلكتروني للتواصل:';

  @override
  String get emailCopiedMsg => 'تم نسخ البريد الإلكتروني';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get sendNowButton => 'تواصل معنا';

  @override
  String get drawerProfile => 'الملف الشخصي';

  @override
  String get drawerTheme => 'المظهر';

  @override
  String get drawerSupport => 'الدعم الفني';

  @override
  String get drawerAdvancedStats => 'إحصائيات متقدمة';

  @override
  String get drawerAbout => 'عن التطبيق';

  @override
  String get drawerRate => 'قيم التطبيق';

  @override
  String get drawerHelpfulInfo => 'نصائح مفيدة';

  @override
  String fieldsMissing(String fields) {
    return 'مطلوب: $fields';
  }

  @override
  String get updateAvailableTitle => 'تحديث جديد متاح';

  @override
  String get updateAvailableMsg =>
      'يتوفر إصدار جديد من التطبيق. قم بالتحديث للحصول على أحدث الميزات والتحسينات.';

  @override
  String get updateNowButton => 'تحديث الآن';

  @override
  String versionLabel(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get upgradeBannerText => 'قم بترقية حسابك للوصول لجميع الميزات';

  @override
  String get aboutAppDesc =>
      'تطبيق متطور لإدارة المتاجر الإلكترونية بكل سهولة.';

  @override
  String get advancedStatsTitle => 'إحصائيات متقدمة';

  @override
  String get advancedStatsMsg =>
      'هذه الصفحة متاحة فقط لمشتركي البريميوم. سيتم تفعيلها قريباً.';

  @override
  String get okButton => 'حسناً';

  @override
  String get rateAppTitle => 'ما رأيك في التطبيق؟';

  @override
  String get rateAppMsg =>
      'تقييمك يساعدنا على تحسين الخدمة وتطوير ميزات جديدة.';

  @override
  String get rateAppHint => 'أخبرنا كيف يمكننا التحسن؟';

  @override
  String get rateAppGooglePlayMsg =>
      'يسعدنا أن التطبيق نال إعجابك! هل تود تقييمنا على متجر تطبيقات Google؟';

  @override
  String get sendButton => 'إرسال';

  @override
  String get ratingThanksMsg => 'شكراً لملاحظاتك، سنعمل على تحسين التطبيق!';

  @override
  String get loadingStatus => 'جاري التحميل...';

  @override
  String get premiumStatus => 'بريميوم ✨';

  @override
  String trialStatusDays(Object days) {
    return 'تجريبية ($days يوم)';
  }

  @override
  String get trialStatus => 'تجريبية';

  @override
  String get expiredStatus => 'منتهية';

  @override
  String get menuTooltip => 'القائمة';

  @override
  String get filterTooltip => 'فلتر';

  @override
  String get loadingMessage => 'جاري التحميل...';

  @override
  String get appName => 'إدارة المنتجات';

  @override
  String get appSubtitle => 'الديب';

  @override
  String get sessionExpiredMsg =>
      'انتهت مهلة تفعيل الحساب. يرجى التسجيل من جديد.';

  @override
  String get accountNotRegisteredMsg =>
      'الحساب غير مسجل. يرجى إنشاء متجر جديد.';

  @override
  String get paymentSuccessMsg => 'تم الدفع بنجاح!';

  @override
  String get uploadPreparing => 'جاري تحضير الصورة...';

  @override
  String get uploadStoreIdMissing => 'معرّف المتجر غير موجود';

  @override
  String uploadingProgress(Object progress) {
    return 'جاري رفع الصورة... $progress%';
  }

  @override
  String get uploadProcessing => 'جاري معالجة الصورة...';

  @override
  String get uploadDone => 'تم ✅';

  @override
  String get validationEnterPriceValid => 'الرجاء إدخال سعر صحيح';

  @override
  String get validationSelectCategory => 'الرجاء اختيار فئة';

  @override
  String get saveProductError => 'فشل حفظ المنتج';

  @override
  String get alreadySaving => 'جاري الحفظ بالفعل';

  @override
  String get defaultStoreName => 'متجري';

  @override
  String inviteText(Object storeName, Object url) {
    return 'مرحباً بكم في متجر \"$storeName\"! 🛍️✨\n\nيسعدنا دعوتكم لزيارة متجرنا وتصفح أحدث المنتجات والطلب مباشرة عبر الرابط التالي:\n$url\n\nننتظر زيارتكم! 😊';
  }

  @override
  String get defaultCategoryOthers => 'اخرى';

  @override
  String get languageLabel => 'لغة التطبيق';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorPermissionDenied =>
      'ليس لديك صلاحية الوصول، يرجى التأكد من تسجيل الحساب أولاً';

  @override
  String get errorEmailInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get errorInvalidEmail => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل';

  @override
  String get errorUserNotFound => 'بيانات الدخول غير صحيحة';

  @override
  String get errorNetwork => 'خطأ في الاتصال بالإنترنت';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع. حاول مرة أخرى';

  @override
  String get errorNoStoreFound =>
      'عذراً، لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';

  @override
  String get errorAccountExpired =>
      'انتهت مهلة تفعيل الحساب. يرجى التسجيل من جديد.';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get noProductsFound => 'لا توجد أي منتجات';

  @override
  String get dashboardLoadError => 'فشل في تحميل لوحة التحكم';

  @override
  String get dashboardUpdateError => 'فشل في تحديث لوحة التحكم';

  @override
  String get logoutConfirmTitle => 'تأكيد تسجيل الخروج';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get storeLangLabel => 'لغة المتجر';

  @override
  String get storeLangHelper =>
      'اختر اللغة التي سيظهر بها متجرك للعملاء عند اول زيارة للمتجر';

  @override
  String get congratulationsTitle => 'مبروك! 🎉';

  @override
  String get storeReadyMsg => 'لقد أصبح رابط متجرك جاهزاً الآن!';

  @override
  String get yourStoreLinkLabel => 'رابط متجرك';

  @override
  String get goToHomeButton => 'الذهاب للصفحة الرئيسية';

  @override
  String get step3TransferInfo => '3. معلومات التحويل:';

  @override
  String get transferAccountNameLabel => 'اسم صاحب الحساب / المُحوِّل';

  @override
  String get transferAccountNameHint => 'حساب شام كاش';

  @override
  String get transferAccountNameRequired => 'يرجى إدخال اسم صاحب الحساب';

  @override
  String get transferAccountNameHelper =>
      'أدخل الاسم الذي قمت بالتحويل منه لنتمكن من التحقق من الدفع';

  @override
  String get confirmPaymentButton => 'تأكيد الدفع وطلب التفعيل';

  @override
  String get submittingRequest => 'جاري إرسال الطلب...';

  @override
  String get activationRequestInstruction =>
      'بعد التحويل، أدخل اسم الحساب واضغط الزر لإرسال طلب التفعيل.';

  @override
  String get orContactViaMessenger => 'أو تواصل عبر واتساب / تليجرام';

  @override
  String get activationRequestSentTitle => 'تم إرسال الطلب!';

  @override
  String get activationRequestSentMsg =>
      'شكراً لك! تم استلام طلب التفعيل وسيتم مراجعته قريباً. سنقوم بتفعيل متجرك فور التحقق من الدفع.';

  @override
  String get activationRequestError =>
      'حدث خطأ أثناء إرسال الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get paymentMethodElectronic => 'شام كاش';

  @override
  String get paymentSyriaInfoBox =>
      'يرجى إرسال المبلغ وملء النموذج. سنقوم بتفعيل متجرك فور التحقق.';

  @override
  String get paymentSupportTitle => 'هل تواجه مشكلة في التفعيل؟';

  @override
  String get paymentSupportAction => 'التواصل مع الدعم';

  @override
  String get errorGoogleNoUser =>
      'فشل تسجيل الدخول عبر Google. يرجى المحاولة مرة أخرى.';

  @override
  String get errorGooglePopupBlocked =>
      'تم حظر نافذة تسجيل الدخول المنبثقة. يرجى السماح بالنوافذ المنبثقة أو استخدام طريقة إعادة التوجيه.';

  @override
  String get pcs1 => 'قطعة واحدة';

  @override
  String get pcs2 => 'قطعتين';

  @override
  String pcs3to10(Object count) {
    return '$count قطع';
  }

  @override
  String pcsOver10(Object count) {
    return '$count قطعة';
  }

  @override
  String get securitySectionTitle => 'الأمان';

  @override
  String get securitySectionSubtitle => 'كلمة المرور وأمان الحساب';

  @override
  String get setupCompleteMessage => 'متجرك جاهز للنشر.';

  @override
  String get publishButton => 'نشر';

  @override
  String get licensesButton => 'التراخيص';

  @override
  String get privacyConsentTitle => 'حماية البيانات';

  @override
  String get privacyConsentMessage =>
      'نستخدم (Google) للمصادقة وتخزين البيانات. يتم معالجة عنوان IP الخاص بك ومعرف المستخدم بواسطة خدمات Google. باستخدام هذا التطبيق، فإنك توافق على سياسة الخصوصية الخاصة بنا.';

  @override
  String get privacyAcceptButton => 'موافق';

  @override
  String get privacyDeclineButton => 'رفض';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyDeclineMessage =>
      'لا يمكن استخدام التطبيق بدون الموافقة على معالجة البيانات.';

  @override
  String pricingForMonths(int months) {
    return 'لمدة $months أشهر';
  }

  @override
  String pricingTotal(String price) {
    return 'الإجمالي: $price';
  }

  @override
  String pricingOriginalPrice(String price) {
    return 'بدلاً من $price';
  }

  @override
  String pricingSaveAmount(String amount) {
    return 'توفر $amount';
  }

  @override
  String pricingSaveTotalAmount(String amount) {
    return 'إجمالي التوفير: $amount';
  }

  @override
  String get pricingBestValue => 'أفضل قيمة';

  @override
  String get pricingPopular => 'الأكثر شعبية';

  @override
  String get pricingLimitedOffer => 'عرض لفترة محدودة';

  @override
  String get pricingMonthlyLabel => 'شهري';

  @override
  String get pricingYearlyLabel => 'سنوي';

  @override
  String get pricingBiannualLabel => 'نصف سنوي';

  @override
  String get pricingQuarterlyLabel => 'ربع سنوي';

  @override
  String get pricingOneMonth => 'شهر واحد';

  @override
  String pricingMonthsCount(int count) {
    return '$count أشهر';
  }

  @override
  String pricingBilledAs(String total) {
    return 'يُفوتر بـ $total';
  }

  @override
  String get productLimitReached =>
      'لقد وصلت إلى حد المنتجات. قم بترقية اشتراكك لنشر المزيد من المنتجات.';

  @override
  String get paymentTitle => 'اختر خطتك';

  @override
  String get bestValueLabel => 'الأكثر توفيراً';

  @override
  String get perMonth => '/ شهر';

  @override
  String get totalAtCheckout => 'سيتم عرض المبلغ الإجمالي في صفحة الدفع';

  @override
  String savePercent(Object percent) {
    return 'خصم $percent';
  }

  @override
  String get yearlyPlanTitle => 'الاشتراك السنوي';

  @override
  String get monthlyPlanTitle => 'الاشتراك الشهري';

  @override
  String get pricingPerMonth => 'شهريًا';

  @override
  String get pricingBilledSixMonths => 'يتم الدفع كل 6 أشهر';

  @override
  String get pricingBilledYearly => 'يتم الدفع سنويًا';

  @override
  String get pricingMostPopular => 'الأكثر شيوعًا';

  @override
  String pricingSavePercent(int percent) {
    return 'وفّر %$percent';
  }

  @override
  String get pricingFallbackEurInfo =>
      'الدفع بالدولار الأمريكي (العملة المحلية غير متوفرة)';

  @override
  String get pricingCurrencyLabel => 'العملة:';

  @override
  String get common_ok => 'تمام';

  @override
  String get common_later => 'لاحقاً';

  @override
  String get paywall_suspended_title => '⚠️ المتجر موقوف مؤقتاً';

  @override
  String get paywall_suspended_body =>
      'تم إيقاف المتجر مؤقتاً.\nإذا كنت تعتقد أن ذلك خطأ، تواصل مع الدعم وسنساعدك بسرعة.';

  @override
  String get paywall_trial_welcome_title => '🎁 أهلاً بك! التجربة مفعّلة';

  @override
  String get paywall_trial_welcome_body =>
      'ابدأ بإضافة منتجاتك ومشاركة رابط متجرك مع الزبائن.\nنصيحة: أضف 5–10 منتجات كبداية ليظهر متجرك بشكل رائع.';

  @override
  String get paywall_expired_s1_title => 'انتهت التجربة المجانية';

  @override
  String get paywall_expired_s1_body =>
      'متجرك ما زال ظاهرًا للزبائن، لكن الأسعار والمقاسات مخفية مؤقتاً.\n\nفعّل الاشتراك لتعود جميع المزايا فوراً.';

  @override
  String get paywall_expired_s2_title => 'الصور متوقفة مؤقتاً';

  @override
  String get paywall_expired_s2_body =>
      'متجرك ما زال ظاهرًا للزبائن، لكن صور المنتجات مخفية مؤقتاً.\n\nفعّل الاشتراك لتعود الصور وباقي المزايا فوراً.';

  @override
  String get paywall_expired_s3_title => 'المتجر غير نشط حالياً';

  @override
  String get paywall_expired_s3_body =>
      'تم تقييد بعض الميزات مؤقتاً بعد انتهاء التجربة.\n\nفعّل الاشتراك لاستمرار العمل وعرض المتجر بشكل كامل.';

  @override
  String get paywall_cta_activate_now => 'تفعيل الآن';

  @override
  String get paywall_cta_activate_store => 'تفعيل المتجر';

  @override
  String get paywall_features_header => 'بالتفعيل ستحصل على:';

  @override
  String get feature_show_prices => 'إظهار الأسعار والمقاسات والخيارات';

  @override
  String get feature_show_images => 'إظهار صور المنتجات';

  @override
  String get feature_edit_products => 'إضافة وتعديل المنتجات';

  @override
  String get feature_faster_support => 'دعم أسرع عند الحاجة';

  @override
  String get trial_popup_title => 'مرحباً بك في التجربة 🎉';

  @override
  String get trial_popup_body =>
      'يمكنك الآن تجربة جميع المزايا:\n• إضافة المنتجات\n• مشاركة رابط متجرك\n• عرض المتجر للزبائن';

  @override
  String trial_days_remaining_msg(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متبقي $count أيام في التجربة.',
      many: 'متبقي $count يوماً في التجربة.',
      two: 'متبقي يومين في التجربة.',
      one: 'متبقي يوم واحد في التجربة.',
      zero: 'اليوم آخر يوم في التجربة.',
    );
    return '$_temp0';
  }

  @override
  String get locationPickerTitle => 'تحديد الموقع';

  @override
  String get saveLabel => 'حفظ';

  @override
  String get tapMapHint => 'يرجى النقر على الخريطة لتحديد موقعك.';

  @override
  String get selectLocationOnMap => 'تحديد الموقع على الخريطة';

  @override
  String get imageSourceUpload => 'رفع صورة';

  @override
  String get imageSourceLink => 'رابط';

  @override
  String get imageUrlLabel => 'رابط الصورة';

  @override
  String get imageUrlHint => 'الصق رابط صورة مباشر (https://...jpg/png/webp).';

  @override
  String get pasteImageLink => 'الصق رابط الصورة لعرض المعاينة';

  @override
  String offerBadgePercent(Object percent) {
    return '$percent%';
  }

  @override
  String bundleOverlay(Object currency, Object price, Object qtyText) {
    return '$currency$price • $qtyText';
  }

  @override
  String bundleDetailPayOnly(Object payQty, Object qtyText) {
    return 'ادفع فقط $payQty واحصل على $qtyText';
  }

  @override
  String bundleDetail(Object price, Object qtyText) {
    return '$price مقابل $qtyText';
  }

  @override
  String freeQtyBadge(Object freeQtyText) {
    return '$freeQtyText مجانًا';
  }

  @override
  String get bulkBadge => 'خصم كمية';

  @override
  String bulkOverlay(Object qty, Object qtyText) {
    return 'ابتداءً من $qty $qtyText';
  }

  @override
  String get pendingRequestTitle => 'الطلب قيد المعالجة';

  @override
  String get pendingRequestMessage =>
      'لقد أرسلت طلبًا بالفعل. يرجى الانتظار حتى يقوم المسؤول بتأكيده.';

  @override
  String get regularPriceLabel => 'السعر الاصلي';

  @override
  String get discountedPriceLabel => 'السعر بعد الخصم';

  @override
  String get effectiveUnitPriceLabel => 'سعر القطعة';

  @override
  String get effectiveDiscountLabel => 'الخصم';

  @override
  String get logoHint => 'الشعار اختياري — بدونُه نعرض اسم المتجر.';

  @override
  String get changeLogo => 'تغيير الشعار';

  @override
  String get deleteLogo => 'حذف الشعار';

  @override
  String get deleteLogoConfirm => 'هل أنت متأكد من حذف الشعار؟';

  @override
  String get showNameWithLogoLabel => 'عرض الاسم بجانب الشعار في المتجر؟';

  @override
  String get showNameWithLogoHint => '';

  @override
  String get uploadError => 'فشل الرفع';

  @override
  String get unsavedChangesTitle => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesMessage =>
      'لديك تغييرات غير محفوظة. هل تريد حقاً المغادرة؟ ستفقد جميع التغييرات.';

  @override
  String get discardButton => 'تجاهل';

  @override
  String get stayButton => 'البقاء';

  @override
  String get addressDescriptionToggle => 'إضافة وصف إضافي للعنوان';

  @override
  String get addressDescriptionLabel => 'وصف العنوان (اختياري)';

  @override
  String get addressDescriptionHint =>
      'مثال: بجانب المخبز، الطابق الثاني يسار...';

  @override
  String get storeNameTooLong => 'اسم المتجر يجب ألا يتجاوز 40 حرفاً';

  @override
  String get recommendedCategoryLabel => 'الفئة المقترحة';

  @override
  String get xlsProductId => 'معرّف المنتج';

  @override
  String get xlsName => 'الاسم';

  @override
  String get xlsCategory => 'الفئة';

  @override
  String get xlsQty => 'الكمية';

  @override
  String get xlsUnit => 'الوحدة';

  @override
  String get xlsPurchasePrice => 'سعر الشراء';

  @override
  String get xlsPrice => 'السعر (للوحدة)';

  @override
  String get xlsVat => 'ضريبة (%)';

  @override
  String get xlsGrossPrice => 'السعر الإجمالي';

  @override
  String get xlsStock => 'المخزون';

  @override
  String get xlsSupplier => 'المورّد';

  @override
  String get xlsActive => 'الحالة (نشط)';

  @override
  String get xlsOfferType => 'نوع العرض';

  @override
  String get xlsCreatedAt => 'تاريخ الإنشاء';

  @override
  String get xlsNote => 'ملاحظة';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get xlsExportButton => 'تصدير Excel';

  @override
  String get xlsExportSuccess => 'تم تحميل التصدير بنجاح';

  @override
  String get xlsExportError => 'فشل التصدير';

  @override
  String get xlsExportDialogTitle => 'تصدير المنتجات';

  @override
  String get xlsExportDialogMsg =>
      'هل تريد تحميل جميع المنتجات كملف Excel؟ يمكنك استخدامه للجرد.';

  @override
  String get xlsExportDialogConfirm => 'تحميل';

  @override
  String get descLangAr => 'AR';

  @override
  String get descLangDe => 'DE';

  @override
  String get descLangEn => 'EN';

  @override
  String get descLangTr => 'TR';

  @override
  String get autoTranslateButton => 'ترجمة تلقائية';

  @override
  String get autoTranslateUsed => 'تمت الترجمة بالفعل';

  @override
  String get autoTranslateSuccess => 'تمت ترجمة الوصف تلقائياً';

  @override
  String get autoTranslateError => 'فشلت الترجمة التلقائية';

  @override
  String get autoTranslateBudgetExceeded => 'تم استنفاد حصة الترجمة';

  @override
  String get descriptionHintAr => 'الوصف بالعربية';

  @override
  String get descriptionHintDe => 'الوصف بالألمانية';

  @override
  String get descriptionHintEn => 'الوصف بالإنجليزية';

  @override
  String get descriptionHintTr => 'الوصف بالتركية';

  @override
  String get autoTranslateOnCreateTitle => 'هل تريد ترجمة الوصف تلقائيا؟';

  @override
  String get autoTranslateOnCreateHint =>
      'ادخل فقط لغة واحدة وسيتم ترجمة اللغات الاخرى تلقائيا';

  @override
  String get pageDescLabelAr => 'وصف المتجر بالعربية';

  @override
  String get pageDescLabelDe => 'وصف المتجر بالألمانية';

  @override
  String get pageDescLabelEn => 'وصف المتجر بالإنجليزية';

  @override
  String get pageDescLabelTr => 'وصف المتجر بالتركية';

  @override
  String get logoUploadInProgressMsg => 'جاري رفع الشعار، يرجى الانتظار...';

  @override
  String get productPolicyMismatchTitle => 'تنبيه';

  @override
  String get productPolicyMismatchBody =>
      'هذا المنتج لا يتوافق مع سياسات المنصّة.';

  @override
  String get productPolicyMismatchSubtext =>
      'إذا كنت تظن أن هذا خطأ، تواصل معنا.';

  @override
  String get productPolicyMismatchCta => 'التواصل مع الدعم';

  @override
  String get pricingSummaryTitle => 'ملخّص الدفع';

  @override
  String get pricingSummaryPlanLabel => 'الخطة';

  @override
  String get pricingSummaryMonthlyLabel => 'يعادل شهريًا';

  @override
  String get pricingSummaryTotalLabel => 'المجموع للدفع الآن';

  @override
  String get pricingCheckoutTitle => 'ملخّص الدفع';

  @override
  String get pricingCheckoutPlanLabel => 'الخطة';

  @override
  String get pricingCheckoutOriginalLabel => 'السعر الأصلي قبل العرض';

  @override
  String get pricingCheckoutOfferLabel => 'تطبيق العرض';

  @override
  String get pricingCheckoutTotalLabel => 'المجموع';

  @override
  String pricingCheckoutDiscountValue(Object amount, Object percent) {
    return 'خصم  $percent  (%$amount)';
  }

  @override
  String get pricingActivationYearly => 'تفعيل المتجر لسنة كاملة';

  @override
  String get pricingActivationSixMonths => 'تفعيل المتجر لمدة 6 أشهر';

  @override
  String get alreadyRatedTitle => 'شكرًا لتقييمك!';

  @override
  String get alreadyRatedMsg =>
      'لقد قيّمت التطبيق بالفعل. هل ترغب في تحديث تقييمك على متجر Google Play؟';

  @override
  String get alreadyRatedHint => 'رأيك يساعدنا على تحسين التطبيق باستمرار.';

  @override
  String get goToPlayStore => 'الانتقال إلى متجر Play';

  @override
  String get updateRating => 'تحديث التقييم';

  @override
  String get contactWhatsAppLabel => 'دعم واتساب';

  @override
  String whatsappNotAvailable(Object phone) {
    return 'واتساب غير متاح. تم نسخ الرقم: $phone';
  }

  @override
  String get whatsappError => 'حدث خطأ أثناء فتح واتساب';

  @override
  String get refPriceMenuTitle => 'التسعير المرجعي والصرف';

  @override
  String get refPriceDialogTitle => 'تسعير المنتجات المرجعي';

  @override
  String get refPriceDialogDesc =>
      'أدخل أسعار بضائعك بعملة مرجعية (مثلاً بالدولار) وسيقوم النظام بتحويلها وعرضها للزبائن بالعملة المحلية تلقائياً بناءً على سعر الصرف الذي تحدده.';

  @override
  String get refPriceEnable => 'تفعيل التسعير المرجعي';

  @override
  String get refCurrencyLabel => 'العملة المرجعية';

  @override
  String get refRateLabel => 'سعر الصرف';

  @override
  String refPriceExample(Object base, Object finalPrice, Object localCurrency) {
    return 'مثال: إذا أدخلت سعر منتج بـ $base، سيظهر للزبون بسعر: $finalPrice $localCurrency';
  }

  @override
  String refPriceHelperText(String finalPrice, String localCurrency) {
    return 'في المتجر: $finalPrice $localCurrency';
  }

  @override
  String get refCurrencyHiddenHint =>
      'العملة المرجعية غير مرئية للزبائن في متجرك. يتم استخدامها فقط كأساس داخلي لحساب أسعارك بالعملة المحلية.';

  @override
  String get currencyUsd => '\$  دولار';

  @override
  String get currencyEur => '€  يورو';

  @override
  String get currencyTry => '₺  ليرة تركية';

  @override
  String get currencyLabelSYP => 'ل.س  ليرة سورية (SYP)';

  @override
  String get currencyLabelAED => 'د.إ  درهم إماراتي (AED)';

  @override
  String get currencyLabelBHD => 'د.ب  دينار بحريني (BHD)';

  @override
  String get currencyLabelDZD => 'د.ج  دينار جزائري (DZD)';

  @override
  String get currencyLabelEGP => 'ج.م  جنيه مصري (EGP)';

  @override
  String get currencyLabelIQD => 'ع.د  دينار عراقي (IQD)';

  @override
  String get currencyLabelJOD => 'د.أ  دينار أردني (JOD)';

  @override
  String get currencyLabelKWD => 'د.ك  دينار كويتي (KWD)';

  @override
  String get currencyLabelLBP => 'ل.ل  ليرة لبنانية (LBP)';

  @override
  String get currencyLabelLYD => 'د.ل  دينار ليبي (LYD)';

  @override
  String get currencyLabelMAD => 'د.م.  درهم مغربي (MAD)';

  @override
  String get currencyLabelOMR => 'ر.ع.  ريال عماني (OMR)';

  @override
  String get currencyLabelQAR => 'ر.ق  ريال قطري (QAR)';

  @override
  String get currencyLabelSAR => '﷼  ريال سعودي (SAR)';

  @override
  String get currencyLabelSDG => 'ج.س  جنيه سوداني (SDG)';

  @override
  String get currencyLabelDJF => 'Fdj  فرنك جيبوتي (DJF)';

  @override
  String get currencyLabelTND => 'د.ت  دينار تونسي (TND)';

  @override
  String get currencyLabelYER => 'ر.ي  ريال يمني (YER)';

  @override
  String get currencyLabelMRU => 'UM  أوقية موريتانية (MRU)';

  @override
  String get currencyLabelSOS => 'Sh  شلن صومالي (SOS)';

  @override
  String get currencyLabelKMF => 'CF  فرنك جزر القمر (KMF)';

  @override
  String get currencyLabelAUD => 'A\$  دولار أسترالي (AUD)';

  @override
  String get currencyLabelBRL => 'R\$  ريال برازيلي (BRL)';

  @override
  String get currencyLabelCAD => 'C\$  دولار كندي (CAD)';

  @override
  String get currencyLabelCHF => 'CHF  فرنك سويسري (CHF)';

  @override
  String get currencyLabelCNY => '¥  يوان صيني (CNY)';

  @override
  String get currencyLabelEUR => '€  يورو (EUR)';

  @override
  String get currencyLabelGBP => '£  جنيه إسترليني (GBP)';

  @override
  String get currencyLabelJPY => '¥  ين ياباني (JPY)';

  @override
  String get currencyLabelRUB => '₽  روبل روسي (RUB)';

  @override
  String get currencyLabelSEK => 'kr  كرونة سويدية (SEK)';

  @override
  String get currencyLabelTRY => '₺  ليرة تركية (TRY)';

  @override
  String get currencyLabelUSD => '\$  دولار  (USD)';

  @override
  String get customTemplateNewTitle => 'قالب جديد';

  @override
  String get customTemplateEditTitle => 'تعديل القالب';

  @override
  String get customTemplateTitleHint => 'العنوان (مثل: تخفيضات نهاية الأسبوع)';

  @override
  String get customTemplateMessageHint => 'الرسالة';

  @override
  String get customTemplateDefaultTab => 'الافتراضي';

  @override
  String get customTemplateMyTab => 'قوالبي';

  @override
  String get customTemplateCreateNew => 'إنشاء جديد';

  @override
  String get customTemplateEmpty => 'لم تقم بإنشاء أي قوالب مخصصة بعد.';

  @override
  String get stopCategoryOffersConfirmTitle => 'إيقاف العروض؟';

  @override
  String get stopCategoryOffersConfirmMessage =>
      'هل تريد حقاً إيقاف جميع العروض لهذه الفئة؟';

  @override
  String get stopCategoryOffersConfirmYes => 'نعم، إيقاف';

  @override
  String get stopCategoryOffersConfirmNo => 'لا، إلغاء';

  @override
  String get activeOffersBadge => 'عروض نشطة';

  @override
  String get addressPrecisionHint =>
      '📍: يتم حفظ موقعك عبر الإحداثيات لضمان الدقة، حتى لو بدا اسم الشارع غير دقيق.';

  @override
  String get logoUploading => 'جارٍ الرفع…';

  @override
  String get logoProcessing => 'جارٍ المعالجة…';

  @override
  String get logoDeleting => 'جارٍ الحذف…';

  @override
  String get logoUpdatedToast => 'تم تحديث الشعار';

  @override
  String get logoDeletedToast => 'تم حذف الشعار';

  @override
  String get deleteLogoTitle => 'حذف الشعار';

  @override
  String get productPolicyEmailSubject => 'مراجعة المنتج';

  @override
  String get productPolicyEmailBodyIntro =>
      'أعتقد أن هذا الحظر تم عن طريق الخطأ.';

  @override
  String contactEmailLine(Object email) {
    return 'البريد الإلكتروني: $email';
  }

  @override
  String get contactEmailCopied => 'تم نسخ عنوان البريد الإلكتروني';

  @override
  String get drawerAnalytics => 'إحصائيات المتجر';

  @override
  String get analyticsTitle => 'الإحصائيات';

  @override
  String get analyticsRange7 => 'آخر 7 أيام';

  @override
  String get analyticsRange30 => 'آخر 30 يوم';

  @override
  String get analyticsRange90 => 'آخر 90 يوم';

  @override
  String get analyticsEmpty => 'لا توجد إحصائيات بعد.';

  @override
  String get analyticsCardVisits => 'الزيارات';

  @override
  String get analyticsCardWhatsapp => 'نقرات واتساب';

  @override
  String get analyticsCardProductViews => 'نقر على المنتج';

  @override
  String get analyticsCardAddToCart => 'إضافة للسلة';

  @override
  String get analyticsCardCheckout => 'نية الشراء';

  @override
  String get analyticsChartVisits => 'الزيارات يوميًا';

  @override
  String get analyticsChartWhatsapp => 'نقرات واتساب يوميًا';

  @override
  String get analyticsTableTitle => 'الأيام الأخيرة';

  @override
  String get refreshButton => 'تحديث';

  @override
  String get analyticsFilterTitle => 'فلترة';

  @override
  String get analyticsFilterFrom => 'من';

  @override
  String get analyticsFilterTo => 'إلى';

  @override
  String get analyticsPeakTitle => 'أعلى يوم';

  @override
  String get analyticsAxisDays => 'أيام الشهر';

  @override
  String get analyticsAxisCount => '';

  @override
  String get analyticsMonthLabel => 'الشهر';

  @override
  String get month01 => 'كانون الثاني';

  @override
  String get month02 => 'شباط';

  @override
  String get month03 => 'آذار';

  @override
  String get month04 => 'نيسان';

  @override
  String get month05 => 'أيار';

  @override
  String get month06 => 'حزيران';

  @override
  String get month07 => 'تموز';

  @override
  String get month08 => 'آب';

  @override
  String get month09 => 'أيلول';

  @override
  String get month10 => 'تشرين الأول';

  @override
  String get month11 => 'تشرين الثاني';

  @override
  String get month12 => 'كانون الأول';

  @override
  String get installAppAppleTitle => 'تثبيت التطبيق (iOS)';

  @override
  String get installAppAppleStep1 =>
      '1. اضغط على أيقونة المشاركة أسفل متصفح سفاري (مربع بسهم).';

  @override
  String get installAppAppleStep2 =>
      '2. قم بالتمرير لأسفل واختر \'إضافة إلى الشاشة الرئيسية\'.';

  @override
  String get installAppAppleStep3 =>
      '3. قم بالتأكيد بالضغط على \'إضافة\' في الزاوية العلوية.';

  @override
  String get gotItButton => 'تمام';

  @override
  String analyticsPeakVisits(int count) {
    return '$count زيارات';
  }

  @override
  String analyticsPeakWhatsapp(int count) {
    return '$count نقرات';
  }
}
