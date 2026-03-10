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
  String get whatsappSameAsPhone => 'WhatsApp telefon numarasıyla aynı';

  @override
  String get whatsappNumberLabel => 'WhatsApp Numarası*';

  @override
  String get countryLabel => 'Ülke';

  @override
  String get selectCountry => 'Ülke Seçin';

  @override
  String get addressLabel => 'Adres';

  @override
  String get addressHint => 'Cadde, İlçe, Şehir...';

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
  String get sendResetLinkButton => 'Şifre sıfırlama bağlantısı gönder';

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
  String get storeFallbackName => 'Mağazanız';

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
  String get statusExpired => 'Süresi Dolmuş';

  @override
  String get statusSuspended => 'Askıya Alındı';

  @override
  String get statusUnknown => 'Bilinmiyor';

  @override
  String get shippingTitle => 'Teslimat';

  @override
  String get shippingEnabled => 'Teslimat Mevcut';

  @override
  String get shippingEnabledSubtitle =>
      'Müşteriler için teslimat hizmetini etkinleştir';

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
    return 'Oluşturuldu: $date';
  }

  @override
  String get currencyLabel => 'Kullanılan Para Birimi*';

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
  String get contactSectionSubtitle => 'Telefon, Adres, Sosyal Bağlantılar';

  @override
  String get otherSettingsSectionTitle => 'Diğer Ayarlar';

  @override
  String get otherSettingsSectionSubtitle =>
      'Çalışma Saatleri, Teslimat, Güvenlik';

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
  String get step1Subtitle => 'Mağazanız için bir isim ve logo seçin';

  @override
  String get step2Title => 'Size nasıl ulaşılır?';

  @override
  String get step2Subtitle => 'Müşteriler için telefon numarası ve adres girin';

  @override
  String get step3Title => 'Teslimat Hizmeti';

  @override
  String get step3Subtitle => 'Müşterilerinize teslimat sağlıyor musunuz?';

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
      'Sipariş başına fiyatı daha sonra belirlemek için boş bırakın';

  @override
  String get step4Title => 'Mağazanız ne zaman açık?';

  @override
  String get step4Subtitle => 'Bu adımı atlayıp daha sonra ekleyebilirsiniz';

  @override
  String get step5Title => 'Son Adım!';

  @override
  String get step5Subtitle =>
      'Varsa sosyal medya bağlantılarını ekleyin (İsteğe bağlı)';

  @override
  String get shortDescriptionLabel => 'Kısa Mağaza Açıklaması (İsteğe bağlı)';

  @override
  String get optionalBadge => 'İsteğe bağlı';

  @override
  String get skipButton => 'Atla';

  @override
  String get nextButton => 'İleri';

  @override
  String get finishSetupButton => 'Kurulumu Tamamla';

  @override
  String get validationEnterStoreName => 'Lütfen mağaza adını girin';

  @override
  String get validationEnterPhone => 'Lütfen telefon numarasını girin';

  @override
  String get logoutConfirmMsg => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get logoutConfirmButton => 'Çıkış Yap';

  @override
  String locationFetchError(Object error) {
    return 'Konum alınamadı: $error';
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
  String get storeNameRequired => 'Mağaza adı gereklidir';

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
  String get sizeLabel => 'Boyut/Beden';

  @override
  String get unitLabel => 'Birim';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get descQuality => 'Yüksek kalite & harika lezzet';

  @override
  String get descFresh => 'Taze & Günlük';

  @override
  String get descBestseller => 'En Çok Satan';

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
      'İndirimleri veya toptan teklifleri etkinleştir';

  @override
  String get offerTypeLabel => 'Teklif Türü';

  @override
  String get offerTypePercent => 'Yüzde %';

  @override
  String get offerTypeBundle => 'Paket Teklifi';

  @override
  String get offerTypeBulk => 'Toplu/Kademeli Fiyat';

  @override
  String get percentageLabel => 'Yüzde (%)';

  @override
  String get quantityLabel => 'Adet';

  @override
  String get totalPriceLabel => 'Toplam Fiyat';

  @override
  String get quantityStartLabel => 'Adet (başlangıç)';

  @override
  String get pricePerPieceLabel => 'Adet başı fiyat';

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
  String get productImageLabel => 'Ürün Görseli';

  @override
  String get tapToUpload => 'Görsel yüklemek için dokunun';

  @override
  String get optionalSuffix => '(İsteğe bağlı)';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'gr';

  @override
  String get unitL => 'lt';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPcs => 'adet';

  @override
  String get deleteCategoryTitle => 'Kategoriyi Sil';

  @override
  String deleteCategoryMsg(Object name) {
    return '\"$name\" kategorisini silmek istiyor musunuz? Ürünler \"Diğerleri\"ne taşınacak.';
  }

  @override
  String get categoriesLoadError => 'Kategoriler yüklenemedi';

  @override
  String get categoryRenameTitle => 'Kategoriyi Düzenle';

  @override
  String get categoryRenameLabel => 'Yeni Kategori Adı';

  @override
  String get categoryRenameSuccess => 'Kategori başarıyla yeniden adlandırıldı';

  @override
  String get categoryRenameFail => 'Kategori yeniden adlandırılamadı';

  @override
  String get categoryRenameError => 'Kategori adlandırma hatası';

  @override
  String deleteCategoryConfirmMsg(Object moveTo, Object name) {
    return 'Tüm ürünler \"$name\" kategorisinden \"$moveTo\" kategorisine taşınacak. Emin misiniz?';
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
  String get viewProductsAction => 'Ürünleri Görüntüle';

  @override
  String get viewProductsSubtitle => 'Bu kategori için ürün listesini aç';

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
      'Ürünlerinizi düzenlemek için yeni kategoriler ekleyin';

  @override
  String offerUntilDate(Object date) {
    return '$date tarihine kadar';
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
    return '\"$name\" ürününü silmek istiyor musunuz?';
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
      '🔥 Kısa bir süre için tüm ürünlerde %20 özel indirim! Sakın kaçırmayın.';

  @override
  String get templateWelcomeTitle => 'Hoş Geldiniz';

  @override
  String get templateWelcomeText =>
      'Mağazamıza hoş geldiniz! Mutlu ve keyifli alışverişler dileriz. ✨';

  @override
  String get templateNewTitle => 'Yeni Gelenler';

  @override
  String get templateNewText =>
      'Yeni ve seçkin bir koleksiyon geldi! Mağazadaki en son ürünlere hemen göz atın. 🆕';

  @override
  String get templateDeliveryTitle => 'Ücretsiz Teslimat';

  @override
  String get templateDeliveryText =>
      'Şimdi alışveriş yapın ve 50 Euro üzerindeki siparişlerde ücretsiz teslimat kazanın! 🚚';

  @override
  String get templateOccasionTitle => 'Özel Gün';

  @override
  String get templateOccasionText =>
      'Mutlu Bayramlar! Özel tekliflerimizin tadını çıkarın. 🌙';

  @override
  String get loadDataError => 'Veri yüklenemedi';

  @override
  String get messagePublishedSuccess => 'Mesaj başarıyla yayınlandı ✅';

  @override
  String get saveFailed => 'Kaydedilemedi, lütfen tekrar deneyin';

  @override
  String get connectionError => 'Bağlantı hatası';

  @override
  String get messageDeleted => 'Mesaj silindi 🗑';

  @override
  String get deleteMessageTitle => 'Mesajı Sil';

  @override
  String get deleteMessageConfirm =>
      'Mesajı silmek istediğinizden emin misiniz? Artık müşterilere görünmeyecek.';

  @override
  String get chooseTemplateTitle => 'Bir şablon seçin';

  @override
  String get previewTitle => 'Müşteri Önizlemesi';

  @override
  String get editMessageTitle => 'Mesajı Düzenle';

  @override
  String get templatesButton => 'Şablonlar';

  @override
  String get displayDurationTitle => 'Görüntüleme Süresi';

  @override
  String get previewPlaceholder => 'Mesajınız burada görünecek...';

  @override
  String get messageHint => 'Örn: Tüm ürünlerde %20 indirim 🌙';

  @override
  String get engageTextHint =>
      'Satışları artırmak için ilgi çekici metin girin';

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
      'Kayıtlı e-posta adresinizi girin, yeni şifre belirlemeniz için bir bağlantı gönderelim.';

  @override
  String get enterEmailValidation => 'Lütfen e-posta girin';

  @override
  String get invalidEmailFormat => 'Geçersiz e-posta formatı';

  @override
  String get resetLinkSentMsg =>
      'Şifre sıfırlama bağlantısı e-postanıza gönderildi.';

  @override
  String get emailNotRegistered => 'Bu e-posta kayıtlı değil.';

  @override
  String get generalSendError =>
      'Şu anda gönderilemedi. Lütfen e-posta adresini kontrol edin.';

  @override
  String get sendLinkButton => 'Bağlantı Gönder';

  @override
  String get backToLogin => 'Girişe Dön';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz!';

  @override
  String get dashboardSubtitle => 'Mağazanızın bugünkü kısa özeti';

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
      'Henüz mesaj ayarlanmadı. Eklemek için dokunun.';

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
  String get statsNoImage => 'Görsel Yok';

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
  String get filterNoImage => 'Görselsiz Ürünler';

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
  String get expirationAlertTitle => 'Süre Dolum Uyarısı';

  @override
  String expirationAlertMsg(Object days) {
    return 'Merhaba! Mağaza aboneliğiniz $days gün içinde sona erecek. Kesintisiz hizmet için lütfen şimdi yenileyin.';
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
  String get activateButton => 'Aktifleştir';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get loginSubtitle =>
      'Mağazanıza erişmek için hesap bilgilerinizi girin';

  @override
  String get loginEmailOrPassError => 'Hatalı e-posta veya şifre';

  @override
  String get noStoreTitle => 'Mağaza Bulunamadı';

  @override
  String get noStoreMessage =>
      'Bu hesabı kullanarak yeni bir mağaza oluşturmak ister misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get createStore => 'Mağaza Oluştur';

  @override
  String get loginNoPermission => 'Erişim reddedildi';

  @override
  String get googleLoginFailed => 'Google girişi başarısız';

  @override
  String get unexpectedError => 'Üzgünüz, beklenmeyen bir hata oluştu.';

  @override
  String get googleSigningIn => 'Giriş yapılıyor...';

  @override
  String get googleSignIn => 'Google ile giriş yap';

  @override
  String get orSeparator => 'VEYA';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get emailRequired => 'E-posta gereklidir';

  @override
  String get emailInvalid => 'Geçersiz e-posta formatı';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordRequired => 'Şifre gereklidir';

  @override
  String get forgotPassword => 'Şifremi unuttum?';

  @override
  String get signInButton => 'Giriş Yap';

  @override
  String get noAccount => 'Hesabınız yok mu?';

  @override
  String get createNewStore => 'Yeni mağaza oluştur';

  @override
  String get activationSuccessTitle => 'Aktivasyon Başarılı!';

  @override
  String get activationSuccessMsg =>
      'Teşekkürler! Mağazanız başarıyla aktifleştirildi.';

  @override
  String get startNowButton => 'Şimdi Başla';

  @override
  String get loadingErrorPrefix => 'Hata: ';

  @override
  String get choosePlanTitle => 'Planınızı Seçin';

  @override
  String get noPlansAvailable => 'Şu anda uygun plan yok';

  @override
  String get choosePlanSubtitle => 'Size uygun abonelik planını seçin';

  @override
  String get savePercentage => '%20 Tasarruf Et';

  @override
  String get paymentLinkError => 'Sunucu ödeme bağlantısı döndürmedi';

  @override
  String get paymentPrepError =>
      'Ödeme hazırlanırken hata oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String payAndActivate(Object price) {
    return '$price Öde & Aktifleştir';
  }

  @override
  String get featureUnlimitedProducts => 'Sınırsız Ürün';

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
  String get step1ChoosePlan => '1. Plan Seçin:';

  @override
  String get step2PaymentDetails => '2. Ödeme Detayları (Buraya transfer):';

  @override
  String get qrCodePlaceholder => 'QR Kod Fotoğrafı';

  @override
  String get accountNumberLabel => 'Hesap Numarası / ID';

  @override
  String get copyIdSuccess => 'ID Kopyalandı';

  @override
  String get sendActivationInfoButton => 'Aktivasyon Bilgisini Gönder';

  @override
  String get afterPaymentInstruction =>
      'Ödemeden sonra mağaza adınızı ve ID\'nizi otomatik göndermek için butona dokunun.';

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
    return 'Merhaba, mağaza aktivasyonu için tutarı transfer ettim.\nLütfen aktifleştirin:\n\n🏪 *Mağaza:* $storeName\n🆔 *ID:* $storeId\n📅 *Plan:* $planName ($price)\n\nTeşekkürler!';
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
  String get enterStoreNamePrompt => 'Kaydı tamamlamak için mağaza adını girin';

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
  String get storeNameHint => 'Örnek: Elit Mağaza';

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
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

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
  String get resetLinkSentTitle => 'Sıfırlama Bağlantısı Gönderildi';

  @override
  String checkEmailForResetMsg(Object username) {
    return 'Lütfen e-postanızı ($username) kontrol edin ve şifrenizi değiştirmek için bağlantıyı izleyin.';
  }

  @override
  String get backToLoginButton => 'Girişe Dön';

  @override
  String get subscriptionInfoTitle => 'Abonelik Detayları';

  @override
  String get activePremiumTitle => 'Aktif Premium Abonelik';

  @override
  String get activePremiumSubtitle =>
      'Mağazanız kısıtlama olmadan tamamen çalışır durumda';

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
  String get contactSupport => 'Lütfen destekle iletişime geçin';

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
  String get activatedAt => 'Aktifleşme Tarihi';

  @override
  String get subscriptionEndsAt => 'Abonelik Bitiş Tarihi';

  @override
  String get trialStartedAt => 'Deneme Başlangıç Tarihi';

  @override
  String get trialEndsAt => 'Deneme Bitiş Tarihi';

  @override
  String get subscriptionEndedAt => 'Abonelik Bitiş Tarihi';

  @override
  String get trialEndedAt => 'Deneme Bitiş Tarihi';

  @override
  String get currentBenefitsTitle => 'Mevcut Abonelik Avantajları';

  @override
  String get benefitUnlimitedProducts => 'Sınırsız ürün ekle ve yönet';

  @override
  String get benefitHighQualityImages =>
      'Müşteriler için yüksek kaliteli görsel gösterimi';

  @override
  String get benefitShowPrices => 'Web sitesinde fiyatlar ve boyutlar görünür';

  @override
  String get benefitFullControl => 'Mağaza ayarları üzerinde tam kontrol';

  @override
  String get benefitDirectSupport => 'Doğrudan ve hızlı destek';

  @override
  String get restrictionStagesTitle => 'Mağaza Kısıtlama Aşamaları';

  @override
  String get restrictionStage1 =>
      'Ürün görsellerini herkese açık mağazadan gizle';

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
  String get checkYourEmailTitle => 'E-postanızı Kontrol Edin';

  @override
  String get sentLinkTo => 'Onay bağlantısını şuraya gönderdik:';

  @override
  String get verifyEmailInstructions =>
      'E-postanızı açın ve onay bağlantısına tıklayın.\nDoğrulamadan sonra otomatik olarak yönlendirileceksiniz.';

  @override
  String get checkNowButton => 'Şimdi Kontrol Et';

  @override
  String get checkingStatus => 'Kontrol ediliyor...';

  @override
  String get resendButton => 'E-posta almadınız mı? Tekrar Gönder';

  @override
  String resendCountdown(Object seconds) {
    return '${seconds}sn içinde tekrar gönder';
  }

  @override
  String get spamFolderHint =>
      'E-postayı görmüyorsanız Spam klasörünüzü kontrol edin.';

  @override
  String get emailVerifiedSuccess => 'E-posta başarıyla doğrulandı!';

  @override
  String get verificationLinkSent => 'Onay bağlantısı tekrar gönderildi';

  @override
  String verificationLinkSendFail(Object error) {
    return 'Bağlantı gönderilemedi: $error';
  }

  @override
  String get defaultEmailPlaceholder => 'E-postanız';

  @override
  String get drawerStoreFallback => 'Mağazanız';

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
      'Yardımcı olmak için buradayız! Uygulamayı geliştirmek için soru veya önerilerinizi duymaktan her zaman memnuniyet duyarız.';

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
  String versionLabel(Object version) {
    return 'Sürüm $version';
  }

  @override
  String get upgradeBannerText =>
      'Tüm özelliklere erişmek için hesabınızı yükseltin';

  @override
  String get aboutAppDesc =>
      'Çevrimiçi mağazaları kolayca yönetmek için gelişmiş uygulama.';

  @override
  String get advancedStatsTitle => 'Gelişmiş İstatistikler';

  @override
  String get advancedStatsMsg =>
      'Bu sayfa yalnızca premium aboneler içindir. Yakında gelecek.';

  @override
  String get okButton => 'Tamam';

  @override
  String get rateAppTitle => 'Uygulama hakkında ne düşünüyorsunuz?';

  @override
  String get rateAppMsg =>
      'Puanınız hizmeti geliştirmemize ve yeni özellikler üretmemize yardımcı olur.';

  @override
  String get rateAppHint => 'Nasıl geliştirebileceğimizi bize söyleyin?';

  @override
  String get rateAppGooglePlayMsg =>
      'Uygulamayı beğenmenize sevindik! Bizi Google Play Store\'da oylamak ister misiniz?';

  @override
  String get sendButton => 'Gönder';

  @override
  String get ratingThanksMsg =>
      'Geri bildiriminiz için teşekkürler, uygulamayı geliştirmek için çalışacağız!';

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
  String get appSubtitle => 'Yönetici';

  @override
  String get sessionExpiredMsg =>
      'Oturum süresi doldu. Lütfen tekrar kayıt olun.';

  @override
  String get accountNotRegisteredMsg =>
      'Hesap kayıtlı değil. Lütfen yeni bir mağaza oluşturun.';

  @override
  String get paymentSuccessMsg => 'Ödeme başarılı!';

  @override
  String get uploadPreparing => 'Görsel hazırlanıyor...';

  @override
  String get uploadStoreIdMissing => 'Mağaza ID eksik';

  @override
  String uploadingProgress(Object progress) {
    return 'Yükleniyor... %$progress';
  }

  @override
  String get uploadProcessing => 'Görsel işleniyor...';

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
    return '\"$storeName\" mağazasına hoş geldiniz! 🛍️✨\n\nSizi mağazamızı ziyaret etmeye, en yeni ürünlere göz atmaya ve aşağıdaki bağlantı üzerinden doğrudan sipariş vermeye davet etmekten mutluluk duyarız:\n$url\n\nSizi görmeyi dört gözle bekliyoruz! 😊';
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
  String get errorEmailInUse => 'E-posta zaten kullanımda';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta formatı';

  @override
  String get errorWeakPassword => 'Şifre çok zayıf. En az 6 karakter kullanın';

  @override
  String get errorUserNotFound => 'Geçersiz kimlik bilgileri';

  @override
  String get errorNetwork => 'Ağ hatası';

  @override
  String get errorUnknown => 'Beklenmeyen hata. Lütfen tekrar deneyin';

  @override
  String get errorNoStoreFound => 'Üzgünüz, bu e-posta için hesap bulunamadı.';

  @override
  String get errorAccountExpired =>
      'Hesap aktivasyon süresi doldu. Lütfen tekrar kayıt olun.';
}
