// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ürün Yönetimi';

  @override
  String get login => 'Giriş Yap';

  @override
  String get sessionExpired => 'Oturum süresi doldu. Lütfen tekrar doğrulayın.';

  @override
  String get noStore => 'Hesap kayıtlı değil. Lütfen bir mağaza oluşturun.';

  @override
  String get appearanceTitle => 'Görünüm';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get contactAndAddressTitle => 'İletişim & Adres';

  @override
  String get phoneNumberLabel => 'Telefon Numarası*';

  @override
  String get whatsappSameAsPhone => 'WhatsApp telefonla aynı';

  @override
  String get whatsappNumberLabel => 'WhatsApp Numarası*';

  @override
  String get countryLabel => 'Ülke';

  @override
  String get selectCountry => 'Ülke Seçin';

  @override
  String get addressLabel => 'Adres';

  @override
  String get addressHint => 'Sokak, İlçe, Şehir...';

  @override
  String get useCurrentLocationTooltip => 'Mevcut konumu kullan';

  @override
  String get securityTitle => 'Güvenlik';

  @override
  String get loginEmailLabel => 'Giriş E-postası';

  @override
  String get googleAuthInfo =>
      'Google ile giriş yaptınız. Doğrudan e-posta girişi için şifre belirleyebilirsiniz.';

  @override
  String get passwordResetSent =>
      'Şifre sıfırlama bağlantısı e-postanıza gönderildi';

  @override
  String get sendingStatus => 'Gönderiliyor...';

  @override
  String get sendResetLinkButton => 'Sıfırlama bağlantısı gönder';

  @override
  String get currentPasswordLabel => 'Mevcut Şifre';

  @override
  String get newPasswordLabel => 'Yeni Şifre';

  @override
  String get confirmPasswordLabel => 'Şifreyi Onayla';

  @override
  String get passwordChangedSuccess => 'Şifre başarıyla değiştirildi';

  @override
  String get changePasswordButton => 'Şifreyi Değiştir';

  @override
  String get forgotPasswordButton => 'Şifremi Unuttum?';

  @override
  String get storeFallbackName => 'Mağazan';

  @override
  String get noEmail => 'E-posta belirtilmedi';

  @override
  String statusTrialDays(Object days) {
    return 'Deneme • $days gün';
  }

  @override
  String get statusTrial => 'Deneme';

  @override
  String get statusActive => 'Aktif';

  @override
  String get statusExpired => 'Süresi Doldu';

  @override
  String get statusSuspended => 'Askıya Alındı';

  @override
  String get statusUnknown => 'Bilinmiyor';

  @override
  String get shippingTitle => 'Teslimat';

  @override
  String get shippingEnabled => 'Teslimat Mevcut';

  @override
  String get shippingEnabledSubtitle => 'Müşteriler için teslimat hizmetini aç';

  @override
  String get shippingCostLabel => 'Teslimat Ücreti';

  @override
  String get shippingCostHint => '0.00';

  @override
  String get socialLinksTitle => 'Bağlantılar & Sosyal';

  @override
  String get socialTiktok => 'TikTok';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get supportEmailLabel => 'Destek E-postası';

  @override
  String get supportEmailHint => 'email@ornek.com';

  @override
  String get storeInfoTitle => 'Mağaza Bilgileri';

  @override
  String get storeNameLabel => 'Mağaza Adı';

  @override
  String get storeDescLabel => 'Mağaza Açıklaması';

  @override
  String get storeDescHint => 'Yüksek kalite ve uygun fiyatlar';

  @override
  String get storeDescHelper =>
      'Bu açıklama ana sayfada mağaza adının altında görünür.';

  @override
  String createdAtDate(Object date) {
    return 'Oluşturulma: $date';
  }

  @override
  String get currencyLabel => 'Mağaza Para Birimi*';

  @override
  String get workingHoursTitle => 'Çalışma Saatleri';

  @override
  String get monday => 'Pazartesi';

  @override
  String get tuesday => 'Salı';

  @override
  String get wednesday => 'Çarşamba';

  @override
  String get thursday => 'Perşembe';

  @override
  String get friday => 'Cuma';

  @override
  String get saturday => 'Cumartesi';

  @override
  String get sunday => 'Pazar';

  @override
  String get profileTitle => 'Profil';

  @override
  String get appearanceSectionTitle => 'Görünüm';

  @override
  String get appearanceSectionSubtitle => 'Uygulama görünümünü özelleştir';

  @override
  String get storeInfoSectionTitle => 'Mağaza Bilgisi';

  @override
  String get storeInfoSectionSubtitle => 'İsim, Para Birimi, Açıklama';

  @override
  String get contactSectionTitle => 'İletişim';

  @override
  String get contactSectionSubtitle => 'Telefon, Adres, Sosyal Medya';

  @override
  String get otherSettingsSectionTitle => 'Diğer Ayarlar';

  @override
  String get otherSettingsSectionSubtitle => 'Saatler, Teslimat, Güvenlik';

  @override
  String get saveChangesButton => 'Değişiklikleri Kaydet';

  @override
  String get savingButton => 'Kaydediliyor...';

  @override
  String get logoutButton => 'Çıkış Yap';

  @override
  String get saveSuccessMsg => 'Değişiklikler kaydedildi';

  @override
  String get saveErrorMsg => 'Kaydetme hatası';

  @override
  String get setupStoreTitle => 'Mağaza Kurulumu';

  @override
  String get stepIdentity => 'Kimlik';

  @override
  String get stepContact => 'İletişim';

  @override
  String get stepDelivery => 'Teslimat';

  @override
  String get stepHours => 'Saatler';

  @override
  String get stepFinish => 'Bitiş';

  @override
  String get step1Title => 'Temel bilgilerle başlayalım';

  @override
  String get step1Subtitle => 'Mağazan için bir isim ve logo seç';

  @override
  String get step2Title => 'Sana nasıl ulaşılır?';

  @override
  String get step2Subtitle => 'Müşteriler için telefon ve adres gir';

  @override
  String get step3Title => 'Teslimat Hizmeti';

  @override
  String get step3Subtitle => 'Müşterilerine teslimat yapıyor musun?';

  @override
  String get enableDeliveryLabel => 'Teslimatı Etkinleştir';

  @override
  String get deliveryEnabled => 'Hizmet Etkin';

  @override
  String get deliveryDisabled => 'Hizmet Devre Dışı';

  @override
  String get fixedDeliveryPriceLabel => 'Sabit Teslimat Ücreti';

  @override
  String get deliveryPriceHelper =>
      'Sipariş başına fiyat belirlemek için boş bırak';

  @override
  String get step4Title => 'Mağazan ne zaman açık?';

  @override
  String get step4Subtitle => 'Bu adımı atlayıp daha sonra ekleyebilirsin';

  @override
  String get step5Title => 'Tebrikler! Mağaza kurulumunu tamamladınız.';

  @override
  String get step5Subtitle =>
      'Mağaza kurulumunu tamamladınız. Daha sonra profilinizden düzenleyebilirsiniz.';

  @override
  String get step5SubtitleWeb =>
      'iPhone kullanıcıları için: Daha iyi bir deneyim için aşağıdaki paylaş düğmesine dokunun ve \'Ana Ekrana Ekle\'yi seçin.';

  @override
  String get shortDescriptionLabel => 'Kısa Mağaza Açıklaması (İsteğe bağlı)';

  @override
  String get optionalBadge => 'İsteğe bağlı';

  @override
  String get skipButton => 'Atla';

  @override
  String get nextButton => 'İleri';

  @override
  String get finishSetupButton => 'Kurulumu Bitir';

  @override
  String get validationEnterStoreName => 'Lütfen mağaza adını girin';

  @override
  String get validationEnterPhone => 'Lütfen telefon numarasını girin';

  @override
  String get logoutConfirmMsg => 'Çıkış yapmak istediğine emin misin?';

  @override
  String get logoutConfirmButton => 'Çıkış Yap';

  @override
  String locationFetchError(Object error) {
    return 'Konum alma hatası: $error';
  }

  @override
  String get fillAllFieldsError => 'Lütfen tüm alanları doldurun';

  @override
  String get passwordsNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordTooShort => 'Şifre çok kısa (min. 6 karakter)';

  @override
  String generalError(Object error) {
    return 'Hata: $error';
  }

  @override
  String get storeNameRequired => 'Mağaza adı gerekli';

  @override
  String get noEditPermission => 'Düzenleme izniniz yok';

  @override
  String get addProductTitle => 'Ürün Ekle';

  @override
  String get editProductTitle => 'Ürünü Düzenle';

  @override
  String get requiredField => 'Gerekli';

  @override
  String get productNameLabel => 'Ürün Adı';

  @override
  String get priceLabel => 'Fiyat';

  @override
  String get newCategoryLabel => 'Yeni Kategori';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get addNewCategory => 'Yeni Ekle';

  @override
  String get sizeLabel => 'Boyut';

  @override
  String get unitLabel => 'Birim';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get descQuality => 'Yüksek kalite & harika tat';

  @override
  String get descFresh => 'Taze & Günlük';

  @override
  String get descBestseller => 'Çok Satan';

  @override
  String get descLimited => 'Sınırlı Teklif';

  @override
  String get descHandmade => 'Lüks El Yapımı';

  @override
  String get descNatural => '%100 Doğal';

  @override
  String get productAvailable => 'Ürün Mevcut';

  @override
  String get visibleToCustomers => 'Müşterilere görünür';

  @override
  String get hiddenFromCustomers => 'Müşterilerden gizli';

  @override
  String get specialOfferAvailable => 'Özel Teklif';

  @override
  String get specialOfferSubtitle =>
      'İndirim veya toptan teklifleri etkinleştir';

  @override
  String get offerTypeLabel => 'Teklif Türü';

  @override
  String get offerTypePercent => 'Yüzde %';

  @override
  String get offerTypeBundle => 'Paket Teklifi';

  @override
  String get offerTypeBulk => 'Toptan Fiyat';

  @override
  String get percentageLabel => 'Yüzde (%)';

  @override
  String get quantityLabel => 'Miktar';

  @override
  String get totalPriceLabel => 'Toplam Fiyat';

  @override
  String get quantityStartLabel => 'Miktar (başlangıç)';

  @override
  String get pricePerPieceLabel => 'Adet fiyatı';

  @override
  String get offerDurationLabel => 'Teklif Süresi';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get productPublishedMsg => 'Ürün yayınlandı';

  @override
  String get uploading => 'Yükleniyor...';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get errorStatus => 'Hata';

  @override
  String get productImageLabel => 'Ürün Resmi';

  @override
  String get tapToUpload => 'Resim yüklemek için dokun';

  @override
  String get optionalSuffix => '(İsteğe bağlı)';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'g';

  @override
  String get unitL => 'L';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPcs => 'adet';

  @override
  String get deleteCategoryTitle => 'Kategoriyi Sil';

  @override
  String deleteCategoryMsg(Object name) {
    return '\"$name\" silinsin mi? Ürünler \"Diğerleri\"ne taşınacak.';
  }

  @override
  String get categoriesLoadError => 'Kategoriler yüklenemedi';

  @override
  String get categoryRenameTitle => 'Kategoriyi Düzenle';

  @override
  String get categoryRenameLabel => 'Yeni Kategori Adı';

  @override
  String get categoryRenameSuccess => 'Kategori yeniden adlandırıldı';

  @override
  String get categoryRenameFail => 'Yeniden adlandırma başarısız';

  @override
  String get categoryRenameError => 'Yeniden adlandırma hatası';

  @override
  String deleteCategoryConfirmMsg(Object moveTo, Object name) {
    return 'Tüm ürünler \"$name\" kategorisinden \"$moveTo\" kategorisine taşınacak. Emin misin?';
  }

  @override
  String get categoryDeleteSuccess => 'Kategori başarıyla silindi';

  @override
  String get categoryDeleteFail => 'Kategori silinemedi';

  @override
  String get categoryDeleteError => 'Kategori silme hatası';

  @override
  String productsCount(Object count) {
    return '$count Ürün';
  }

  @override
  String get viewProductsAction => 'Ürünleri Gör';

  @override
  String get viewProductsSubtitle => 'Bu kategorideki ürün listesini aç';

  @override
  String get applyCategoryOfferAction => 'Kategoriye Teklif Uygula';

  @override
  String get applyCategoryOfferSubtitle => 'Tüm ürünler için yüzde indirimi';

  @override
  String get stopCategoryOffersAction => 'Kategori Tekliflerini Durdur';

  @override
  String get stopCategoryOffersSubtitle =>
      'Bu kategorideki tüm teklifleri devre dışı bırak';

  @override
  String get categoryFullOfferTitle => 'Tam Kategori Teklifi';

  @override
  String applyToCategorySubtitle(Object category) {
    return '\"$category\" kategorisine uygula';
  }

  @override
  String get percentageHint => 'Örnek: 15';

  @override
  String get offerValidityLabel => 'Teklif Geçerliliği';

  @override
  String get invalidPercentageError => 'Geçerli bir yüzde girin';

  @override
  String get applyOfferButton => 'Teklifi Uygula';

  @override
  String categoryOfferAppliedMsg(Object category) {
    return 'Teklif \"$category\" kategorisine uygulandı';
  }

  @override
  String get categoryOfferApplyFail => 'Teklif uygulanamadı';

  @override
  String categoryOffersDisabledMsg(Object category) {
    return '\"$category\" kategorisi için teklifler durduruldu';
  }

  @override
  String get categoryOffersDisableFail => 'Teklifler durdurulamadı';

  @override
  String get manageCategories => 'Kategorileri Yönet';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String categoriesCountLabel(Object count) {
    return '$count Kategori';
  }

  @override
  String get noCategoriesTitle => 'Henüz kategori yok';

  @override
  String get noCategoriesSubtitle =>
      'Ürünlerini düzenlemek için yeni kategoriler ekle';

  @override
  String offerUntilDate(Object date) {
    return '$date’e dek';
  }

  @override
  String discountPercent(Object percent) {
    return '%$percent İndirim';
  }

  @override
  String bundleOfferLabel(Object currency, Object price, Object qty) {
    return '$qty adet $price $currency';
  }

  @override
  String get offerLabel => 'Teklif';

  @override
  String get availableStatus => ' Mevcut';

  @override
  String get unavailableStatus => 'Mevcut Değil';

  @override
  String get updateFail => 'Güncelleme başarısız';

  @override
  String get deleteProductTitle => 'Ürünü Sil';

  @override
  String deleteProductConfirmMsg(Object name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get deleteSuccess => 'Başarıyla silindi';

  @override
  String get deleteFail => 'Silme başarısız';

  @override
  String get noProducts => 'Ürün bulunamadı';

  @override
  String get customerMessageTitle => 'Müşteri Mesajı';

  @override
  String get templateDiscountTitle => 'Özel İndirim';

  @override
  String get templateDiscountText =>
      '🔥 Kısa bir süre için tüm ürünlerde özel %20 indirim! Kaçırmayın.';

  @override
  String get templateWelcomeTitle => 'Hoş Geldiniz';

  @override
  String get templateWelcomeText =>
      'Mağazamıza hoş geldiniz! Mutlu ve keyifli alışverişler dileriz. ✨';

  @override
  String get templateNewTitle => 'Yeni Gelenler';

  @override
  String get templateNewText =>
      'Yeni ve seçkin bir koleksiyon geldi! Mağazadaki en yeni ürünlere hemen göz atın. 🆕';

  @override
  String get templateDeliveryTitle => 'Ücretsiz Teslimat';

  @override
  String get templateDeliveryText =>
      'Hemen alışveriş yapın, 50 Euro üzeri siparişlerde ücretsiz teslimat kazanın! 🚚';

  @override
  String get templateOccasionTitle => 'Fırsat';

  @override
  String get templateOccasionText =>
      'İyi Bayramlar! Özel tekliflerimizin tadını çıkarın. 🌙';

  @override
  String get loadDataError => 'Veri yüklenemedi';

  @override
  String get messagePublishedSuccess => 'Mesaj başarıyla yayınlandı ✅';

  @override
  String get saveFailed => 'Kaydetme başarısız, tekrar deneyin';

  @override
  String get connectionError => 'Bağlantı hatası';

  @override
  String get messageDeleted => 'Mesaj silindi 🗑';

  @override
  String get deleteMessageTitle => 'Mesajı Sil';

  @override
  String get deleteMessageConfirm =>
      'Mesajı silmek istediğine emin misin? Artık müşterilere görünmeyecek.';

  @override
  String get chooseTemplateTitle => 'Bir şablon seç';

  @override
  String get previewTitle => 'Müşteri Önizlemesi';

  @override
  String get editMessageTitle => 'Mesajı Düzenle';

  @override
  String get templatesButton => 'Şablonlar';

  @override
  String get displayDurationTitle => 'Görüntüleme Süresi';

  @override
  String get previewPlaceholder => 'Mesajın burada görünecek...';

  @override
  String get messageHint => 'Örn: Tüm ürünlerde %20 indirim 🌙';

  @override
  String get engageTextHint => 'Satışları artırmak için ilgi çekici metin gir';

  @override
  String get durationAlways => 'Her Zaman';

  @override
  String get durationDay => '1 Gün';

  @override
  String get duration3Days => '3 Gün';

  @override
  String get durationWeek => '1 Hafta';

  @override
  String get durationMonth => '1 Ay';

  @override
  String get saveAndPublishButton => 'Kaydet ve Yayınla';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get restorePasswordHeadline => 'Şifreyi Sıfırla';

  @override
  String get restorePasswordDesc =>
      'Kayıtlı e-postanı gir, sana yeni şifre belirlemen için bir link gönderelim.';

  @override
  String get enterEmailValidation => 'Lütfen e-posta girin';

  @override
  String get invalidEmailFormat => 'Geçersiz e-posta formatı';

  @override
  String get resetLinkSentMsg => 'Şifre sıfırlama linki e-postana gönderildi.';

  @override
  String get emailNotRegistered => 'Bu e-posta kayıtlı değil.';

  @override
  String get generalSendError =>
      'Şu an gönderilemedi. Lütfen e-posta adresini kontrol et.';

  @override
  String get sendLinkButton => 'Link Gönder';

  @override
  String get backToLogin => 'Girişe Dön';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldin!';

  @override
  String welcomeStoreName(Object storeName) {
    return 'Hoş geldin, $storeName';
  }

  @override
  String get validationEnterAddress => 'Lütfen mağaza adresini girin';

  @override
  String get dashboardSubtitle => 'İşte mağazanın bugünkü kısa özeti';

  @override
  String get publicStoreLink => 'Mağaza Linki';

  @override
  String get noLinkYet => 'Henüz link yok';

  @override
  String get copyLinkSuccess => 'Link kopyalandı!';

  @override
  String get shareStoreInvite => 'Mağaza Daveti Paylaş';

  @override
  String get customerMessagePlaceholder =>
      'Mesaj ayarlanmadı. Eklemek için dokun.';

  @override
  String get liveStatsTitle => 'Canlı İstatistikler';

  @override
  String get statsTotalProducts => 'Ürünler';

  @override
  String get statsAvailable => ' Mevcut';

  @override
  String get statsUnavailable => 'Mevcut Değil';

  @override
  String get statsOffers => 'Teklifler';

  @override
  String get statsCategoryOffers => 'Kat. Teklifleri';

  @override
  String get statsNoImage => 'Resimsiz';

  @override
  String get statsLargestCategory => 'En Büyük Kat.';

  @override
  String get filterAllProducts => 'Tüm Ürünler';

  @override
  String get filterAvailable => 'Mevcut Ürünler';

  @override
  String get filterUnavailable => 'Mevcut Olmayan Ürünler';

  @override
  String get filterActiveOffers => 'Aktif Teklifler';

  @override
  String get filterNoImage => 'Resimsiz Ürünler';

  @override
  String filterCategoryPrefix(Object category) {
    return 'Kategori: $category';
  }

  @override
  String noProductsFoundTitle(Object title) {
    return 'Ürün yok: $title';
  }

  @override
  String get categoryOffersTitle => 'Tam Kategori Teklifleri';

  @override
  String get categoryOffersSubtitle =>
      'Tüm ürünlerin teklifte olduğu kategoriler';

  @override
  String get noCategoryOffers => 'Tam teklifli kategori yok';

  @override
  String get stopOfferAction => 'Durdur';

  @override
  String get stopCategoryOfferSuccess => 'Kategori teklifleri durduruldu';

  @override
  String get stopCategoryOfferConfirm =>
      'Emin misin? Bu kategorideki tüm teklif türleri durdurulacak.';

  @override
  String get expirationAlertTitle => 'Süre Dolum Uyarısı';

  @override
  String expirationAlertMsg(Object days) {
    return 'Merhaba! Mağaza aboneliğin $days gün içinde sona erecek. Kesintisiz hizmet için lütfen şimdi yenile.';
  }

  @override
  String get renewNowButton => 'Şimdi Yenile';

  @override
  String get laterButton => 'Daha Sonra';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navProducts => 'Ürünler';

  @override
  String get navCategories => 'Kategoriler';

  @override
  String get navStore => 'Mağaza';

  @override
  String get activateButton => 'Etkinleştir';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get loginSubtitle => 'Mağazana erişmek için hesap detaylarını gir';

  @override
  String get loginEmailOrPassError => 'Hatalı e-postayla veya şifre';

  @override
  String get noStoreTitle => 'Mağaza Bulunamadı';

  @override
  String get noStoreMessage =>
      'Bu hesabı kullanarak yeni bir mağaza oluşturmak ister misin?';

  @override
  String get cancel => 'İptal';

  @override
  String get createStore => 'Mağaza Oluştur';

  @override
  String get loginNoPermission => 'Erişim reddedildi';

  @override
  String get googleLoginFailed => 'Google girişi başarısız';

  @override
  String get unexpectedError => 'Üzgünüz, beklenmedik bir hata oluştu.';

  @override
  String get googleSigningIn => 'Giriş yapılıyor...';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get orSeparator => 'VEYA';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get emailRequired => 'E-posta gerekli';

  @override
  String get emailInvalid => 'Geçersiz e-posta formatı';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get signInButton => 'Giriş Yap';

  @override
  String get noAccount => 'Hesabın yok mu?';

  @override
  String get createNewStore => 'Yeni mağaza oluştur';

  @override
  String get activationSuccessTitle => 'Aktivasyon Başarılı!';

  @override
  String get activationSuccessMsg =>
      'Teşekkürler! Mağazan başarıyla etkinleştirildi.';

  @override
  String get startNowButton => 'Şimdi Başla';

  @override
  String get loadingErrorPrefix => 'Hata: ';

  @override
  String get choosePlanTitle => 'Planını Seç';

  @override
  String get noPlansAvailable => 'Şu anda uygun plan yok';

  @override
  String get choosePlanSubtitle => 'Sana uygun abonelik planını seç';

  @override
  String get savePercentage => '%20 Tasarruf Et';

  @override
  String get paymentLinkError => 'Sunucu ödeme linki döndürmedi';

  @override
  String get paymentPrepError =>
      'Ödeme hazırlanırken hata oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String payAndActivate(Object price) {
    return '$price Öde & Etkinleştir';
  }

  @override
  String get featureUnlimitedProducts => 'Geniş Envanter (400 ürüne kadar)';

  @override
  String get featurePremiumSupport => 'Premium Destek';

  @override
  String get featureAdvancedStats => 'Gelişmiş İstatistikler';

  @override
  String get featureNoCommission => 'Satış Komisyonu Yok';

  @override
  String get paymentAndActivationTitle => 'Ödeme & Aktivasyon';

  @override
  String get adminContactLabel => 'Aktivasyon Yöneticisi';

  @override
  String get step1ChoosePlan => '1. Plan Seç:';

  @override
  String get step2PaymentDetails => '2. Ödeme Detayları (Buraya transfer et):';

  @override
  String get qrCodePlaceholder => 'QR Kod Resmi';

  @override
  String get accountNumberLabel => 'Hesap Numarası / ID';

  @override
  String get copyIdSuccess => 'ID Kopyalandı';

  @override
  String get sendActivationInfoButton => 'Aktivasyon Bilgisi Gönder';

  @override
  String get afterPaymentInstruction =>
      'Ödemeden sonra, mağaza adını ve ID\'ni otomatik göndermek için butona dokun.';

  @override
  String get sharePaymentConfirmTitle => 'Ödeme onayını şuradan gönder';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get telegramLabel => 'Telegram';

  @override
  String get telegramCopySuccess => 'Mesaj kopyalandı! Sohbete yapıştırın.';

  @override
  String paymentMessageBody(
    Object planName,
    Object price,
    Object storeId,
    Object storeName,
  ) {
    return 'Merhaba, mağaza aktivasyonu için tutarı transfer ettim.\nLütfen etkinleştirin:\n\n🏪 *Mağaza:* $storeName\n🆔 *ID:* $storeId\n📅 *Plan:* $planName ($price)\n\nTeşekkürler!';
  }

  @override
  String get productsTitle => 'Ürünler';

  @override
  String get manageProducts => 'Ürünleri Yönet';

  @override
  String get productsLoadError => 'Ürünler yüklenemedi';

  @override
  String get productUpdateSuccess => 'Ürün başarıyla güncellendi';

  @override
  String get productUpdateStatusFail => 'Ürün durumu güncellenemedi';

  @override
  String get offerUpdateFail => 'Teklif güncellenemedi';

  @override
  String get productDeleteSuccess => 'Ürün başarıyla silindi';

  @override
  String get productDeleteFail => 'Ürün silinemedi';

  @override
  String get filterTitle => 'Filtre';

  @override
  String get filterReset => 'Sıfırla';

  @override
  String get filterApply => 'Uygula';

  @override
  String get stockStatusLabel => 'Durum';

  @override
  String get offersLabel => 'Teklifler';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterWithOffer => 'Teklifli';

  @override
  String get filterWithoutOffer => 'Teklifsiz';

  @override
  String get filterActive => 'Mevcut / Aktif';

  @override
  String get filterInactive => 'Mevcut Değil / Pasif';

  @override
  String get disableProduct => 'Ürünü Devre Dışı Bırak';

  @override
  String get enableProduct => 'Ürünü Etkinleştir';

  @override
  String get disableOffer => 'Teklifi Devre Dışı Bırak';

  @override
  String get enableOffer => 'Teklifi Etkinleştir';

  @override
  String get noSearchResults => 'Sonuç bulunamadı';

  @override
  String get noStoreFound => 'Mağaza bulunamadı';

  @override
  String get noStoreMsg =>
      'Uygulama verileri eksik olabilir.\nLütfen giriş yapın veya mağazayı tekrar kurun.';

  @override
  String get setupStoreButton => 'Mağaza Kur';

  @override
  String get reloginButton => 'Tekrar giriş yap';

  @override
  String get registerTitle => 'Mağaza Oluştur';

  @override
  String get completeStoreCreation => 'Mağaza Oluşturmayı Tamamla';

  @override
  String get enterStoreNamePrompt => 'Kayıdı tamamlamak için mağaza adı girin';

  @override
  String get googleAccountLabel => 'Google Hesabı';

  @override
  String get trialPeriodInfo => 'Ücretsiz deneme';

  @override
  String get createStoreButton => 'Mağaza Oluştur';

  @override
  String get cancelAndReturnToLogin => 'İptal et ve girişe dön';

  @override
  String get registerNewStoreTitle => 'Yeni Mağaza Oluştur';

  @override
  String get registerSubtitle => 'Mağazanızı oluşturun ve ücretsiz deneme alın';

  @override
  String get googleRegisterButton => 'Google ile kaydol';

  @override
  String get googleRegistering => 'Kaydediliyor...';

  @override
  String get storeNameHint => 'Örn: Al-Aseel Mağazası';

  @override
  String get storeNameTooShort => 'Mağaza adı çok kısa (min. 3 karakter)';

  @override
  String get requireEmailVerifyLabel =>
      'Müşterilerden e-posta doğrulaması iste';

  @override
  String get requireEmailVerifySubtitle =>
      'Yeni müşterilerin e-postalarını doğrulaması gerekir';

  @override
  String get createAccountButton => 'Hesap Oluştur';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get loginLink => 'Giriş Yap';

  @override
  String get registerFailedMsg =>
      'Hesap oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String errorOccurred(Object error) {
    return 'Hata oluştu: $error';
  }

  @override
  String get resetPasswordTitle => 'Şifreyi Sıfırla';

  @override
  String get resetLinkSentTitle => 'Sıfırlama Linki Gönderildi';

  @override
  String checkEmailForResetMsg(Object username) {
    return 'Lütfen e-postanı ($username) kontrol et ve şifreni değiştirmek için linki takip et.';
  }

  @override
  String get backToLoginButton => 'Girişe Dön';

  @override
  String get subscriptionInfoTitle => 'Abonelik Detayları';

  @override
  String get activePremiumTitle => 'Aktif Premium Abonelik';

  @override
  String get activePremiumSubtitle =>
      'Mağazan kısıtlama olmadan tam faaliyette';

  @override
  String get trialPeriodTitle => 'Deneme Süresi';

  @override
  String trialRemaining(Object days) {
    return 'Deneme süresinde $days gün kaldı';
  }

  @override
  String get freeTrial => 'Ücretsiz Deneme Süresi';

  @override
  String get subscriptionExpiredTitle => 'Abonelik Süresi Doldu';

  @override
  String get subscriptionExpiredSubtitle =>
      'Mağaza özellikleri geçici olarak askıya alındı';

  @override
  String get accountStatus => 'Hesap Durumu';

  @override
  String get contactSupport => 'Lütfen destek ile iletişime geçin';

  @override
  String get planDetailsCardTitle => 'Plan Detayları & Tarihler';

  @override
  String get storeLabel => 'Mağaza';

  @override
  String get subscriptionTypeLabel => 'Abonelik Türü';

  @override
  String get premiumYearly => 'Premium (Yıllık)';

  @override
  String get trialFree => 'Deneme / Ücretsiz';

  @override
  String get creationDate => 'Oluşturulma Tarihi';

  @override
  String get activatedAt => 'Etkinleştirilme';

  @override
  String get subscriptionEndsAt => 'Abonelik Bitişi';

  @override
  String get trialStartedAt => 'Deneme Başlangıcı';

  @override
  String get trialEndsAt => 'Deneme Bitişi';

  @override
  String get subscriptionEndedAt => 'Abonelik Bitişi';

  @override
  String get trialEndedAt => 'Deneme Bitişi';

  @override
  String get currentBenefitsTitle => 'Mevcut Abonelik Avantajları';

  @override
  String get benefitUnlimitedProducts => 'Sınırsız ürün ekle ve yönet';

  @override
  String get benefitHighQualityImages =>
      'Müşteriler için yüksek kaliteli resim gösterimi';

  @override
  String get benefitShowPrices => 'Web sitesinde fiyat ve boyut görünürlüğü';

  @override
  String get benefitFullControl => 'Mağaza ayarları üzerinde tam kontrol';

  @override
  String get benefitDirectSupport => 'Doğrudan ve hızlı destek';

  @override
  String get restrictionStagesTitle => 'Mağaza Kısıtlama Aşamaları';

  @override
  String get restrictionStage1 =>
      'Ürün resimlerini herkese açık mağazadan gizle';

  @override
  String get restrictionStage2 =>
      'Fiyatları, boyutları ve iletişim bilgilerini gizle';

  @override
  String get restrictionStage3 => 'Panel ve mağazanın tamamen askıya alınması';

  @override
  String get renewSubscriptionButton => 'Aboneliği Şimdi Yenile';

  @override
  String get verifyEmailTitle => 'E-postayı Doğrula';

  @override
  String get logoutTooltip => 'Çıkış Yap';

  @override
  String get checkYourEmailTitle => 'E-postanı Kontrol Et';

  @override
  String get sentLinkTo => 'Şuraya bir onay linki gönderdik:';

  @override
  String get verifyEmailInstructions =>
      'E-postanı aç ve onay linkine tıkla.\nDoğrulamadan sonra otomatik olarak yönlendirileceksin.';

  @override
  String get checkNowButton => 'Şimdi Kontrol Et';

  @override
  String get checkingStatus => 'Kontrol ediliyor...';

  @override
  String get resendButton => 'E-posta gelmedi mi? Tekrar Gönder';

  @override
  String resendCountdown(Object seconds) {
    return '${seconds}sn içinde tekrar gönder';
  }

  @override
  String get spamFolderHint =>
      'E-postayı görmüyorsan Spam klasörünü kontrol et.';

  @override
  String get emailVerifiedSuccess => 'E-posta başarıyla doğrulandı!';

  @override
  String get verificationLinkSent => 'Onay linki tekrar gönderildi';

  @override
  String verificationLinkSendFail(Object error) {
    return 'Link gönderilemedi: $error';
  }

  @override
  String get defaultEmailPlaceholder => 'E-postan';

  @override
  String get drawerStoreFallback => 'Mağazan';

  @override
  String supportEmailSubject(Object id, Object name) {
    return 'Destek Mesajı - $name \n (ID: $id)';
  }

  @override
  String supportEmailBody(Object id, Object name) {
    return '\nMağaza Bilgisi:\nİsim: $name\nID: $id \n---\n';
  }

  @override
  String get supportCenterTitle => 'Destek Merkezi';

  @override
  String get supportCenterMsg =>
      'Yardımcı olmak için buradayız! Uygulamayı geliştirmek için soru veya önerilerini duymaktan memnuniyet duyarız.';

  @override
  String get contactEmailLabel => 'İletişim E-postası:';

  @override
  String get emailCopiedMsg => 'E-posta kopyalandı';

  @override
  String get closeButton => 'Kapat';

  @override
  String get sendNowButton => 'Şimdi Gönder';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get drawerTheme => 'Görünüm';

  @override
  String get drawerSupport => 'Destek';

  @override
  String get drawerAdvancedStats => 'Gelişmiş İstatistikler';

  @override
  String get drawerAbout => 'Uygulama Hakkında';

  @override
  String get drawerRate => 'Uygulamayı Oyla';

  @override
  String get drawerHelpfulInfo => 'Faydalı İpuçları';

  @override
  String fieldsMissing(String fields) {
    return 'Eksik: $fields';
  }

  @override
  String get updateAvailableTitle => 'Güncelleme Mevcut';

  @override
  String get updateAvailableMsg =>
      'Uygulamanın yeni bir sürümü mevcut. En son özellikler ve iyileştirmeler için şimdi güncelleyin.';

  @override
  String get updateNowButton => 'Şimdi Güncelle';

  @override
  String versionLabel(Object version) {
    return 'Sürüm $version';
  }

  @override
  String get upgradeBannerText =>
      'Tüm özelliklere erişmek için hesabını yükselt';

  @override
  String get aboutAppDesc =>
      'Online mağazaları kolayca yönetmek için gelişmiş uygulama.';

  @override
  String get advancedStatsTitle => 'Gelişmiş İstatistikler';

  @override
  String get advancedStatsMsg =>
      'Bu sayfa sadece premium aboneler içindir. Çok yakında.';

  @override
  String get okButton => 'Tamam';

  @override
  String get rateAppTitle => 'Uygulama hakkında ne düşünüyorsun?';

  @override
  String get rateAppMsg =>
      'Puanlaman hizmeti iyileştirmemize ve yeni özellikler geliştirmemize yardımcı olur.';

  @override
  String get rateAppHint => 'Nasıl geliştirebiliriz, bize söyle?';

  @override
  String get rateAppGooglePlayMsg =>
      'Es freut uns, dass Ihnen die App gefällt! Möchten Sie uns im Google Play Store bewerten?';

  @override
  String get sendButton => 'Gönder';

  @override
  String get ratingThanksMsg =>
      'Geri bildirimin için teşekkürler, uygulamayı geliştirmek için çalışacağız!';

  @override
  String get loadingStatus => 'Yükleniyor...';

  @override
  String get premiumStatus => 'Premium ✨';

  @override
  String trialStatusDays(Object days) {
    return 'Deneme ($days gün)';
  }

  @override
  String get trialStatus => 'Deneme';

  @override
  String get expiredStatus => 'Süresi Doldu';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get filterTooltip => 'Filtre';

  @override
  String get loadingMessage => 'Yükleniyor...';

  @override
  String get appName => 'Ürün Yönetimi';

  @override
  String get appSubtitle => 'الديب';

  @override
  String get sessionExpiredMsg =>
      'Oturum süresi doldu. Lütfen tekrar kaydolun.';

  @override
  String get accountNotRegisteredMsg =>
      'Account not registered. Please create a new store.';

  @override
  String get paymentSuccessMsg => 'Ödeme başarılı!';

  @override
  String get uploadPreparing => 'Resim hazırlanıyor...';

  @override
  String get uploadStoreIdMissing => 'Mağaza ID eksik';

  @override
  String uploadingProgress(Object progress) {
    return 'Yükleniyor... %$progress';
  }

  @override
  String get uploadProcessing => 'Resim işleniyor...';

  @override
  String get uploadDone => 'Bitti ✅';

  @override
  String get validationEnterPriceValid => 'Lütfen geçerli bir fiyat girin';

  @override
  String get validationSelectCategory => 'Lütfen bir kategori seçin';

  @override
  String get saveProductError => 'Ürün kaydedilemedi';

  @override
  String get alreadySaving => 'Zaten kaydediliyor';

  @override
  String get defaultStoreName => 'Mağazam';

  @override
  String inviteText(Object storeName, Object url) {
    return '\"$storeName\" mağazasına hoş geldiniz! 🛍️✨\n\nSizi mağazamızı ziyaret etmeye, en yeni ürünlere göz atmaya ve aşağıdaki linkten doğrudan sipariş vermeye davet etmekten mutluluk duyuyoruz:\n$url\n\nSizi görmek için sabırsızlanıyoruz! 😊';
  }

  @override
  String get defaultCategoryOthers => 'Diğerleri';

  @override
  String get languageLabel => 'Uygulama Dili';

  @override
  String get languageArabic => 'Arapça';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get errorPermissionDenied =>
      'İzin reddedildi. Lütfen önce giriş yapın.';

  @override
  String get errorEmailInUse => 'E-postayı zaten kullanımda';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta formatı';

  @override
  String get errorWeakPassword => 'Şifre çok zayıf. En az 6 karakter kullanın';

  @override
  String get errorUserNotFound => 'Geçersiz kimlik bilgileri';

  @override
  String get errorNetwork => 'Ağ hatası';

  @override
  String get errorUnknown => 'Beklenmedik hata. Lütfen tekrar deneyin';

  @override
  String get errorNoStoreFound => 'Üzgünüz, bu e-posta için hesap bulunamadı.';

  @override
  String get errorAccountExpired =>
      'Hesap aktivasyon süresi doldu. Lütfen tekrar kaydolun.';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get noProductsFound => 'Ürün bulunamadı';

  @override
  String get dashboardLoadError => 'Panel yüklenemedi';

  @override
  String get dashboardUpdateError => 'Panel güncellenemedi';

  @override
  String get logoutConfirmTitle => 'Çıkışı Onayla';

  @override
  String get cancelButton => 'İptal';

  @override
  String get storeLangLabel => 'Web Sitesi Dili';

  @override
  String get storeLangHelper => 'Mağazanın müşterilere görüneceği dili seç';

  @override
  String get congratulationsTitle => 'Tebrikler! 🎉';

  @override
  String get storeReadyMsg => 'Mağaza linkin hazır!';

  @override
  String get yourStoreLinkLabel => 'Mağaza linkin';

  @override
  String get goToHomeButton => 'Ana Sayfaya Git';

  @override
  String get step3TransferInfo => '3. Transfer Bilgileri:';

  @override
  String get transferAccountNameLabel => 'Gönderen Adı / Hesap Sahibi';

  @override
  String get transferAccountNameHint => 'Örnek: Ahmet Yılmaz';

  @override
  String get transferAccountNameRequired =>
      'Lütfen hesap sahibinin adını girin';

  @override
  String get transferAccountNameHelper =>
      'Ödemeyi doğrulayabilmemiz için transfer yaptığın ismi gir';

  @override
  String get confirmPaymentButton => 'Ödemeyi Onayla & Aktivasyon İste';

  @override
  String get submittingRequest => 'İstek gönderiliyor...';

  @override
  String get activationRequestInstruction =>
      'Transferden sonra, hesap adını gir ve aktivasyon isteğini göndermek için butona dokun.';

  @override
  String get orContactViaMessenger =>
      'Veya WhatsApp / Telegram ile iletişime geç';

  @override
  String get activationRequestSentTitle => 'İstek Gönderildi!';

  @override
  String get activationRequestSentMsg =>
      'Teşekkürler! Aktivasyon isteğin alındı ve kısa süre içinde incelenecek. Ödeme doğrulandığında mağazanı etkinleştireceğiz.';

  @override
  String get activationRequestError =>
      'İstek gönderilirken hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get paymentMethodElectronic => 'شام كاش';

  @override
  String get paymentSyriaInfoBox =>
      'يرجى إرسال المبلغ وملء النموذج. سنقوم بتفعيل متجرك فور التحقق.';

  @override
  String get paymentSupportTitle => 'هل تواجه مشكلة في الدفع؟';

  @override
  String get paymentSupportAction => 'التواصل مع الدعم';

  @override
  String get errorGoogleNoUser =>
      'Google ile giriş başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get errorGooglePopupBlocked =>
      'Giriş açılır penceresi engellendi. Lütfen pop-up\'lara izin verin veya yönlendirme ile giriş yapın.';

  @override
  String get pcs1 => '1 adet';

  @override
  String get pcs2 => '2 adet';

  @override
  String pcs3to10(Object count) {
    return '$count adet';
  }

  @override
  String pcsOver10(Object count) {
    return '$count adet';
  }

  @override
  String get securitySectionTitle => 'Güvenlik';

  @override
  String get securitySectionSubtitle => 'Şifre ve Hesap Güvenliği';

  @override
  String get setupCompleteMessage => 'Mağazan yayınlanmaya hazır.';

  @override
  String get publishButton => 'Yayınla';

  @override
  String get licensesButton => 'Lisanslar';

  @override
  String get privacyConsentTitle => 'Gizlilik Bildirimi';

  @override
  String get privacyConsentMessage =>
      'Kimlik doğrulama ve veri depolama için (Google) kullanıyoruz. IP adresiniz ve kullanıcı kimliğiniz Google servisleri tarafından işlenir. Bu uygulamayı kullanarak gizlilik politikamızı kabul etmiş olursunuz.';

  @override
  String get privacyAcceptButton => 'Kabul Et';

  @override
  String get privacyDeclineButton => 'Reddet';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyDeclineMessage =>
      'Veri işleme izni olmadan uygulama kullanılamaz.';

  @override
  String pricingForMonths(int months) {
    return '$months ay için';
  }

  @override
  String pricingTotal(String price) {
    return 'Toplam: $price';
  }

  @override
  String pricingOriginalPrice(String price) {
    return 'Eskiden $price';
  }

  @override
  String pricingSaveAmount(String amount) {
    return '$amount Kazanç';
  }

  @override
  String pricingSaveTotalAmount(String amount) {
    return 'Toplam kazanç: $amount';
  }

  @override
  String get pricingBestValue => 'En İyi Değer';

  @override
  String get pricingPopular => 'Popüler';

  @override
  String get pricingLimitedOffer => 'Sınırlı Süre Teklifi';

  @override
  String get pricingMonthlyLabel => 'Aylık';

  @override
  String get pricingYearlyLabel => 'Yıllık';

  @override
  String get pricingBiannualLabel => '6 Aylık';

  @override
  String get pricingQuarterlyLabel => '3 Aylık';

  @override
  String get pricingOneMonth => '1 ay';

  @override
  String pricingMonthsCount(int count) {
    return '$count ay';
  }

  @override
  String pricingBilledAs(String total) {
    return '$total olarak faturalanır';
  }

  @override
  String get productLimitReached =>
      'Ürün limitine ulaştınız. Daha fazla ürün yayınlamak için aboneliğinizi yükseltin.';

  @override
  String get paymentTitle => 'Büyümenizi Seçin';

  @override
  String get bestValueLabel => 'TAVSİYE EDİLEN';

  @override
  String get perMonth => '/ ay';

  @override
  String get totalAtCheckout =>
      'Toplam ödeme Stripe\'da güvenli bir şekilde gösterilecektir';

  @override
  String savePercent(Object percent) {
    return '$percent% Tasarruf edin';
  }

  @override
  String get yearlyPlanTitle => 'Yıllık Abonelik';

  @override
  String get monthlyPlanTitle => 'Aylık Abonelik';

  @override
  String get pricingPerMonth => 'aylık';

  @override
  String get pricingBilledSixMonths => '6 ayda bir faturalandırılır';

  @override
  String get pricingBilledYearly => 'yıllık faturalandırılır';

  @override
  String get pricingMostPopular => 'En popüler';

  @override
  String pricingSavePercent(int percent) {
    return '$percent tasarruf et';
  }

  @override
  String get pricingFallbackEurInfo =>
      'USD ile ödeme (yerel para birimi kullanılamıyor)';

  @override
  String get pricingCurrencyLabel => 'Para birimi:';

  @override
  String get common_ok => 'Tamam';

  @override
  String get common_later => 'Sonra';

  @override
  String get paywall_suspended_title => '⚠️ Mağaza Geçici Olarak Durduruldu';

  @override
  String get paywall_suspended_body =>
      'Mağaza geçici olarak devre dışı bırakıldı.\nBunun bir hata olduğunu düşünüyorsanız, lütfen destek ekibiyle iletişime geçin.';

  @override
  String get paywall_trial_welcome_title => '🎁 Hoş Geldiniz! Deneme Aktif';

  @override
  String get paywall_trial_welcome_body =>
      'Ürünlerinizi eklemeye ve mağaza bağlantınızı paylaşmaya başlayın.\nİpucu: Mağazanızın harika görünmesi için başlangıçta 5–10 ürün ekleyin.';

  @override
  String get paywall_expired_s1_title => 'Ücretsiz Deneme Süresi Doldu';

  @override
  String get paywall_expired_s1_body =>
      'Mağazanız hala görünüyor, ancak fiyatlar ve seçenekler geçici olarak gizlendi.\n\nTüm özellikleri geri getirmek için aboneliğinizi etkinleştirin.';

  @override
  String get paywall_expired_s2_title => 'Görseller Durduruldu';

  @override
  String get paywall_expired_s2_body =>
      'Mağazanız hala görünüyor, ancak ürün görselleri geçici olarak gizlendi.\n\nGörselleri ve diğer özellikleri hemen geri getirmek için aboneliğinizi etkinleştirin.';

  @override
  String get paywall_expired_s3_title => 'Mağaza Şu Anda Aktif Değil';

  @override
  String get paywall_expired_s3_body =>
      'Deneme süresinden sonra bazı özellikler kısıtlandı.\n\nÇalışmaya devam etmek ve mağazayı tam olarak görüntülemek için aboneliğinizi etkinleştirin.';

  @override
  String get paywall_cta_activate_now => 'Şimdi Etkinleştir';

  @override
  String get paywall_cta_activate_store => 'Mağazayı Etkinleştir';

  @override
  String get paywall_features_header =>
      'Etkinleştirdiğinizde şunlara sahip olacaksınız:';

  @override
  String get feature_show_prices =>
      'Fiyatları, bedenleri ve seçenekleri göster';

  @override
  String get feature_show_images => 'Ürün görsellerini göster';

  @override
  String get feature_edit_products => 'Ürün ekle ve düzenle';

  @override
  String get feature_faster_support => 'İhtiyaç duyduğunda daha hızlı destek';

  @override
  String get trial_popup_title => 'Deneme Süresine Hoş Geldiniz! 🎉';

  @override
  String get trial_popup_body =>
      'Şimdi tüm özellikleri deneyebilirsiniz:\n• Ürün ekleme\n• Mağaza bağlantısını paylaşma\n• Mağazayı müşterilere gösterme';

  @override
  String trial_days_remaining_msg(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deneme süresinde $count gün kaldı.',
      one: 'Deneme süresinde 1 gün kaldı.',
      zero: 'Bugün deneme süresinin son günü.',
    );
    return '$_temp0';
  }

  @override
  String get locationPickerTitle => 'Konum Seç';

  @override
  String get saveLabel => 'Kaydet';

  @override
  String get tapMapHint =>
      'Konumunuzu belirlemek için lütfen haritaya dokunun.';

  @override
  String get selectLocationOnMap => 'Haritada konum seç';

  @override
  String get imageSourceUpload => 'Yükle';

  @override
  String get imageSourceLink => 'Bağlantı';

  @override
  String get imageUrlLabel => 'Görsel bağlantısı';

  @override
  String get imageUrlHint =>
      'Doğrudan görsel URL’si yapıştırın (https://...jpg/png/webp).';

  @override
  String get pasteImageLink => 'Önizleme için görsel bağlantısı yapıştırın';

  @override
  String offerBadgePercent(Object percent) {
    return '%$percent';
  }

  @override
  String bundleOverlay(Object currency, Object price, Object qtyText) {
    return '$currency$price • $qtyText';
  }

  @override
  String bundleDetailPayOnly(Object payQty, Object qtyText) {
    return 'Sadece $payQty öde, $qtyText al';
  }

  @override
  String bundleDetail(Object price, Object qtyText) {
    return '$qtyText için $price';
  }

  @override
  String freeQtyBadge(Object freeQtyText) {
    return 'ÜCRETSİZ $freeQtyText';
  }

  @override
  String get bulkBadge => 'Toplu';

  @override
  String bulkOverlay(Object qty, Object qtyText) {
    return '$qty $qtyText ve üzeri';
  }

  @override
  String get pendingRequestTitle => 'İstek İşleniyor';

  @override
  String get pendingRequestMessage =>
      'Zaten bir istek gönderdiniz. Lütfen yönetici onaylayana kadar bekleyin.';

  @override
  String get regularPriceLabel => 'Normal fiyat';

  @override
  String get discountedPriceLabel => 'İndirimli fiyat';

  @override
  String get effectiveUnitPriceLabel => 'Birim fiyatı';

  @override
  String get effectiveDiscountLabel => 'İndirim';

  @override
  String get logoHint => 'Logo yoksa mağaza adı gösterilecek';

  @override
  String get changeLogo => 'Logoyu değiştir';

  @override
  String get deleteLogo => 'Logoyu sil';

  @override
  String get deleteLogoConfirm => 'Logoyu silmek istediğinizden emin misiniz?';

  @override
  String get showNameWithLogoLabel => 'Logo ile adı göster';

  @override
  String get showNameWithLogoHint => 'Ad menüde logonun yanında görünür';

  @override
  String get uploadError => 'Yükleme başarısız';

  @override
  String get unsavedChangesTitle => 'Kaydedilmemiş Değişiklikler';

  @override
  String get unsavedChangesMessage =>
      'Kaydedilmemiş değişiklikleriniz var. Gerçekten çıkmak istiyor musunuz? Tüm değişiklikler kaybolacak.';

  @override
  String get discardButton => 'Vazgeç';

  @override
  String get stayButton => 'Kal';

  @override
  String get addressDescriptionToggle => 'Ek adres açıklaması ekle';

  @override
  String get addressDescriptionLabel => 'Adres açıklaması (isteğe bağlı)';

  @override
  String get addressDescriptionHint => 'Örn. Fırının yanında, 2. kat sol...';

  @override
  String get storeNameTooLong => 'Mağaza adı en fazla 40 karakter olabilir';

  @override
  String get recommendedCategoryLabel => 'Önerilen Kategori';

  @override
  String get xlsProductId => 'Ürün Kimliği';

  @override
  String get xlsName => 'Ad';

  @override
  String get xlsCategory => 'Kategori';

  @override
  String get xlsQty => 'Miktar';

  @override
  String get xlsUnit => 'Birim';

  @override
  String get xlsPurchasePrice => 'Alış Fiyatı';

  @override
  String get xlsPrice => 'Fiyat (Birim)';

  @override
  String get xlsVat => 'KDV (%)';

  @override
  String get xlsGrossPrice => 'Brüt Fiyat';

  @override
  String get xlsStock => 'Stok';

  @override
  String get xlsSupplier => 'Tedarikçi';

  @override
  String get xlsActive => 'Durum (aktif)';

  @override
  String get xlsOfferType => 'Teklif Türü';

  @override
  String get xlsCreatedAt => 'Oluşturulma Tarihi';

  @override
  String get xlsNote => 'Not';

  @override
  String get commonYes => 'Evet';

  @override
  String get commonNo => 'Hayır';

  @override
  String get xlsExportButton => 'Excel Dışa Aktar';

  @override
  String get xlsExportSuccess => 'Dışa aktarma başarıyla indirildi';

  @override
  String get xlsExportError => 'Dışa aktarma başarısız';

  @override
  String get xlsExportDialogTitle => 'Ürünleri dışa aktar';

  @override
  String get xlsExportDialogMsg =>
      'Tüm ürünleri Excel dosyası olarak indirmek ister misiniz? Muhasebe için kullanabilirsiniz.';

  @override
  String get xlsExportDialogConfirm => 'İndir';

  @override
  String get descLangAr => 'AR';

  @override
  String get descLangDe => 'DE';

  @override
  String get descLangEn => 'EN';

  @override
  String get descLangTr => 'TR';

  @override
  String get autoTranslateButton => 'Otomatik Çevir';

  @override
  String get autoTranslateUsed => 'Zaten çevrildi';

  @override
  String get autoTranslateSuccess => 'Açıklama otomatik olarak çevrildi';

  @override
  String get autoTranslateError => 'Otomatik çeviri başarısız';

  @override
  String get autoTranslateBudgetExceeded => 'Çeviri kotası tükendi';

  @override
  String get descriptionHintAr => 'Arapça açıklama';

  @override
  String get descriptionHintDe => 'Almanca açıklama';

  @override
  String get descriptionHintEn => 'İngilizce açıklama';

  @override
  String get descriptionHintTr => 'Türkçe açıklama';

  @override
  String get autoTranslateOnCreateTitle =>
      'Metni otomatik olarak çevirmek ister misiniz?';

  @override
  String get autoTranslateOnCreateHint =>
      'Yalnızca bir dili girin; diğer diller otomatik olarak çevrilecektir.';

  @override
  String get pageDescLabelAr => 'Arapça mağaza açıklaması';

  @override
  String get pageDescLabelDe => 'Almanca mağaza açıklaması';

  @override
  String get pageDescLabelEn => 'İngilizce mağaza açıklaması';

  @override
  String get pageDescLabelTr => 'Türkçe mağaza açıklaması';

  @override
  String get logoUploadInProgressMsg => 'Logo yükleniyor, lütfen bekleyin...';

  @override
  String get productPolicyMismatchTitle => 'Uyarı';

  @override
  String get productPolicyMismatchBody =>
      'Bu ürün platform politikalarına uygun değil.';

  @override
  String get productPolicyMismatchSubtext =>
      'Bunun bir hata olduğunu düşünüyorsan, bizimle iletişime geç.';

  @override
  String get productPolicyMismatchCta => 'Desteğe ulaş';

  @override
  String get pricingSummaryTitle => 'Ödeme özeti';

  @override
  String get pricingSummaryPlanLabel => 'Plan';

  @override
  String get pricingSummaryMonthlyLabel => 'Aylık karşılığı';

  @override
  String get pricingSummaryTotalLabel => 'Şimdi ödenecek toplam';

  @override
  String get pricingCheckoutTitle => 'Ödeme özeti';

  @override
  String get pricingCheckoutPlanLabel => 'Plan';

  @override
  String get pricingCheckoutOriginalLabel => 'İndirim öncesi fiyat';

  @override
  String get pricingCheckoutOfferLabel => 'İndirim uygulandı';

  @override
  String get pricingCheckoutTotalLabel => 'Toplam';

  @override
  String pricingCheckoutDiscountValue(Object amount, Object percent) {
    return 'indirim $percent  (%$amount)';
  }

  @override
  String get pricingActivationYearly => 'Mağazayı 1 yıl etkinleştir';

  @override
  String get pricingActivationSixMonths => 'Mağazayı 6 ay etkinleştir';

  @override
  String get alreadyRatedTitle => 'Değerlendirmeniz için teşekkürler!';

  @override
  String get alreadyRatedMsg =>
      'Uygulamayı zaten değerlendirdiniz. Google Play Store\'daki değerlendirmenizi güncellemek mi yoksa yeni bir yorum bırakmak mı istersiniz?';

  @override
  String get alreadyRatedHint =>
      'Görüşünüz, uygulamayı sürekli geliştirmemize yardımcı olur.';

  @override
  String get goToPlayStore => 'Play Store\'a git';

  @override
  String get updateRating => 'Değerlendirmeyi güncelle';

  @override
  String get contactWhatsAppLabel => 'WhatsApp Destek';

  @override
  String whatsappNotAvailable(Object phone) {
    return 'WhatsApp kullanılamıyor. Numara kopyalandı: $phone';
  }

  @override
  String get whatsappError => 'WhatsApp açılırken bir hata oluştu';

  @override
  String get refPriceMenuTitle => 'Referans Fiyatlandırma ve Kur';

  @override
  String get refPriceDialogTitle => 'Ürünler için Referans Fiyatlandırma';

  @override
  String get refPriceDialogDesc =>
      'Ürün fiyatlarını referans bir para birimiyle (ör. USD) girin. Sistem, belirlediğiniz döviz kuruna göre otomatik olarak dönüştürür ve müşterilere yerel para biriminde gösterir.';

  @override
  String get refPriceEnable => 'Referans fiyatlandırmayı etkinleştir';

  @override
  String get refCurrencyLabel => 'Referans para birimi (giriş için)';

  @override
  String get refRateLabel => 'Döviz kuru';

  @override
  String refPriceExample(Object base, Object finalPrice, Object localCurrency) {
    return 'Örnek: Bir ürün fiyatını $base cinsinden girerseniz, müşteri şu şekilde görür: $finalPrice $localCurrency';
  }

  @override
  String refPriceHelperText(String finalPrice, String localCurrency) {
    return 'müşteri için: $finalPrice $localCurrency';
  }

  @override
  String get refCurrencyHiddenHint =>
      'Referans para birimi mağazanızda müşterilere görünmez. Yalnızca fiyat hesaplamalarınız için dahili bir temel olarak kullanılır.';

  @override
  String get currencyUsd => '\$  ABD Doları';

  @override
  String get currencyEur => '€  Euro';

  @override
  String get currencyTry => '₺  Türk Lirası';

  @override
  String get currencyLabelSYP => 'ل.س  Suriye Lirası (SYP)';

  @override
  String get currencyLabelAED => 'د.إ  BAE Dirhemi (AED)';

  @override
  String get currencyLabelBHD => 'د.ب  Bahreyn Dinarı (BHD)';

  @override
  String get currencyLabelDZD => 'د.ج  Cezayir Dinarı (DZD)';

  @override
  String get currencyLabelEGP => 'ج.م  Mısır Lirası (EGP)';

  @override
  String get currencyLabelIQD => 'ع.د  Irak Dinarı (IQD)';

  @override
  String get currencyLabelJOD => 'د.أ  Ürdün Dinarı (JOD)';

  @override
  String get currencyLabelKWD => 'د.ك  Kuveyt Dinarı (KWD)';

  @override
  String get currencyLabelLBP => 'ل.ل  Lübnan Lirası (LBP)';

  @override
  String get currencyLabelLYD => 'د.ل  Libya Dinarı (LYD)';

  @override
  String get currencyLabelMAD => 'د.م.  Fas Dirhemi (MAD)';

  @override
  String get currencyLabelOMR => 'ر.ع.  Umman Riyali (OMR)';

  @override
  String get currencyLabelQAR => 'ر.ق  Katar Riyali (QAR)';

  @override
  String get currencyLabelSAR => '﷼  Suudi Arabistan Riyali (SAR)';

  @override
  String get currencyLabelSDG => 'ج.س  Sudan Lirası (SDG)';

  @override
  String get currencyLabelDJF => 'Fdj  Cibuti Frangı (DJF)';

  @override
  String get currencyLabelTND => 'د.ت  Tunus Dinarı (TND)';

  @override
  String get currencyLabelYER => 'ر.ي  Yemen Riyali (YER)';

  @override
  String get currencyLabelMRU => 'UM  Moritanya Ugiyası (MRU)';

  @override
  String get currencyLabelSOS => 'Sh  Somali Şilini (SOS)';

  @override
  String get currencyLabelKMF => 'CF  Komor Frangı (KMF)';

  @override
  String get currencyLabelAUD => 'A\$  Avustralya Doları (AUD)';

  @override
  String get currencyLabelBRL => 'R\$  Brezilya Reali (BRL)';

  @override
  String get currencyLabelCAD => 'C\$  Kanada Doları (CAD)';

  @override
  String get currencyLabelCHF => 'CHF  İsviçre Frangı (CHF)';

  @override
  String get currencyLabelCNY => '¥  Çin Yuanı (CNY)';

  @override
  String get currencyLabelEUR => '€  Euro (EUR)';

  @override
  String get currencyLabelGBP => '£  İngiliz Sterlini (GBP)';

  @override
  String get currencyLabelJPY => '¥  Japon Yeni (JPY)';

  @override
  String get currencyLabelRUB => '₽  Rus Rublesi (RUB)';

  @override
  String get currencyLabelSEK => 'kr  İsveç Kronu (SEK)';

  @override
  String get currencyLabelTRY => '₺  Türk Lirası (TRY)';

  @override
  String get currencyLabelUSD => '\$  ABD Doları (USD)';

  @override
  String get customTemplateNewTitle => 'Yeni Şablon';

  @override
  String get customTemplateEditTitle => 'Şablonu Düzenle';

  @override
  String get customTemplateTitleHint => 'Başlık (Örn: Hafta Sonu İndirimi)';

  @override
  String get customTemplateMessageHint => 'Mesaj';

  @override
  String get customTemplateDefaultTab => 'Standart';

  @override
  String get customTemplateMyTab => 'Şablonlarım';

  @override
  String get customTemplateCreateNew => 'Yeni Oluştur';

  @override
  String get customTemplateEmpty => 'Henüz özel bir şablon oluşturmadınız.';

  @override
  String get stopCategoryOffersConfirmTitle => 'Teklifleri Durdur?';

  @override
  String get stopCategoryOffersConfirmMessage =>
      'Bu kategori için tüm teklifleri kapatmak istediğinize emin misiniz?';

  @override
  String get stopCategoryOffersConfirmYes => 'Evet, kapat';

  @override
  String get stopCategoryOffersConfirmNo => 'Hayır, iptal';

  @override
  String get activeOffersBadge => 'Aktif Fırsatlar';

  @override
  String get addressPrecisionHint =>
      'Adres metni tam doğru görünmese bile, kesin konum harita üzerinden kaydedilir.';

  @override
  String get logoUploading => 'Yükleniyor…';

  @override
  String get logoProcessing => 'İşleniyor…';

  @override
  String get logoDeleting => 'Siliniyor…';

  @override
  String get logoUpdatedToast => 'Logo güncellendi';

  @override
  String get logoDeletedToast => 'Logo silindi';

  @override
  String get deleteLogoTitle => 'Logoyu sil';

  @override
  String get productPolicyEmailSubject => 'Ürün İncelemesi';

  @override
  String get productPolicyEmailBodyIntro =>
      'Bu kısıtlamanın bir hata olduğunu düşünüyorum.';

  @override
  String contactEmailLine(Object email) {
    return 'E-posta: $email';
  }

  @override
  String get contactEmailCopied => 'E-posta adresi kopyalandı';

  @override
  String get drawerAnalytics => 'Mağaza Analitiği';

  @override
  String get analyticsTitle => 'Analitik';

  @override
  String get analyticsRange7 => 'Son 7 gün';

  @override
  String get analyticsRange30 => 'Son 30 gün';

  @override
  String get analyticsRange90 => 'Son 90 gün';

  @override
  String get analyticsEmpty => 'Henüz analiz verisi yok.';

  @override
  String get analyticsCardVisits => 'Ziyaretler';

  @override
  String get analyticsCardWhatsapp => 'WhatsApp tıklamaları';

  @override
  String get analyticsCardProductViews => 'Ürün görüntülemeleri';

  @override
  String get analyticsCardAddToCart => 'Sepete ekleme';

  @override
  String get analyticsCardCheckout => 'Ödeme niyeti';

  @override
  String get analyticsChartVisits => 'Günlük ziyaretler';

  @override
  String get analyticsChartWhatsapp => 'Günlük WhatsApp tıklamaları';

  @override
  String get analyticsTableTitle => 'Son günler';

  @override
  String get refreshButton => 'Yenile';

  @override
  String get analyticsFilterTitle => 'Filtre';

  @override
  String get analyticsFilterFrom => 'Başlangıç';

  @override
  String get analyticsFilterTo => 'Bitiş';

  @override
  String get analyticsPeakTitle => 'En yüksek gün';

  @override
  String get analyticsAxisDays => 'Günler';

  @override
  String get analyticsAxisCount => 'Sayı';

  @override
  String get analyticsMonthLabel => 'Ay';

  @override
  String get month01 => 'Ocak';

  @override
  String get month02 => 'Şubat';

  @override
  String get month03 => 'Mart';

  @override
  String get month04 => 'Nisan';

  @override
  String get month05 => 'Mayıs';

  @override
  String get month06 => 'Haziran';

  @override
  String get month07 => 'Temmuz';

  @override
  String get month08 => 'Ağustos';

  @override
  String get month09 => 'Eylül';

  @override
  String get month10 => 'Ekim';

  @override
  String get month11 => 'Kasım';

  @override
  String get month12 => 'Aralık';
}
