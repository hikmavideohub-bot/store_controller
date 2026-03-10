// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Produktmanagement';

  @override
  String get login => 'Anmelden';

  @override
  String get sessionExpired => 'Sitzung abgelaufen. Bitte erneut verifizieren.';

  @override
  String get noStore =>
      'Konto nicht registriert. Bitte erstellen Sie einen Shop.';

  @override
  String get appearanceTitle => 'Erscheinungsbild';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get contactAndAddressTitle => 'Kontakt & Adresse';

  @override
  String get phoneNumberLabel => 'Telefonnummer*';

  @override
  String get whatsappSameAsPhone => 'WhatsApp entspricht Telefonnummer';

  @override
  String get whatsappNumberLabel => 'WhatsApp Nummer*';

  @override
  String get countryLabel => 'Land';

  @override
  String get selectCountry => 'Land auswählen';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get addressHint => 'Straße, Bezirk, Stadt...';

  @override
  String get useCurrentLocationTooltip => 'Aktuellen Standort verwenden';

  @override
  String get securityTitle => 'Sicherheit';

  @override
  String get loginEmailLabel => 'Anmelde-E-Mail';

  @override
  String get googleAuthInfo =>
      'Sie sind über Google angemeldet. Sie können ein Passwort festlegen, um die direkte E-Mail-Anmeldung zu aktivieren.';

  @override
  String get passwordResetSent =>
      'Link zum Zurücksetzen des Passworts an Ihre E-Mail gesendet';

  @override
  String get sendingStatus => 'Wird gesendet...';

  @override
  String get sendResetLinkButton => 'Link zum Zurücksetzen senden';

  @override
  String get currentPasswordLabel => 'Aktuelles Passwort';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get passwordChangedSuccess => 'Passwort erfolgreich geändert';

  @override
  String get changePasswordButton => 'Passwort ändern';

  @override
  String get forgotPasswordButton => 'Passwort vergessen?';

  @override
  String get storeFallbackName => 'Ihr Shop';

  @override
  String get noEmail => 'Keine E-Mail angegeben';

  @override
  String statusTrialDays(Object days) {
    return 'Testversion • $days Tage';
  }

  @override
  String get statusTrial => 'Testversion';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusExpired => 'Abgelaufen';

  @override
  String get statusSuspended => 'Gesperrt';

  @override
  String get statusUnknown => 'Unbekannt';

  @override
  String get shippingTitle => 'Lieferung';

  @override
  String get shippingEnabled => 'Lieferung verfügbar';

  @override
  String get shippingEnabledSubtitle => 'Lieferservice für Kunden aktivieren';

  @override
  String get shippingCostLabel => 'Lieferkosten';

  @override
  String get shippingCostHint => '0,00';

  @override
  String get socialLinksTitle => 'Links & Soziales';

  @override
  String get socialTiktok => 'TikTok';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get supportEmailLabel => 'Support-E-Mail';

  @override
  String get supportEmailHint => 'email@beispiel.de';

  @override
  String get storeInfoTitle => 'Shop-Informationen';

  @override
  String get storeNameLabel => 'Shop-Name';

  @override
  String get storeDescLabel => 'Shop-Beschreibung';

  @override
  String get storeDescHint => 'Hohe Qualität und faire Preise';

  @override
  String get storeDescHelper =>
      'Diese Beschreibung erscheint unter dem Shop-Namen auf der Startseite.';

  @override
  String createdAtDate(Object date) {
    return 'Erstellt: $date';
  }

  @override
  String get currencyLabel => 'Währung*';

  @override
  String get workingHoursTitle => 'Öffnungszeiten';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get profileTitle => 'Profil';

  @override
  String get appearanceSectionTitle => 'Erscheinungsbild';

  @override
  String get appearanceSectionSubtitle => 'App-Design anpassen';

  @override
  String get storeInfoSectionTitle => 'Shop-Info';

  @override
  String get storeInfoSectionSubtitle => 'Name, Währung, Beschreibung';

  @override
  String get contactSectionTitle => 'Kontakt';

  @override
  String get contactSectionSubtitle => 'Telefon, Adresse, Social Links';

  @override
  String get otherSettingsSectionTitle => 'Andere Einstellungen';

  @override
  String get otherSettingsSectionSubtitle =>
      'Öffnungszeiten, Lieferung, Sicherheit';

  @override
  String get saveChangesButton => 'Änderungen speichern';

  @override
  String get savingButton => 'Speichern...';

  @override
  String get logoutButton => 'Abmelden';

  @override
  String get saveSuccessMsg => 'Änderungen gespeichert';

  @override
  String get saveErrorMsg => 'Fehler beim Speichern';

  @override
  String get setupStoreTitle => 'Shop einrichten';

  @override
  String get stepIdentity => 'Identität';

  @override
  String get stepContact => 'Kontakt';

  @override
  String get stepDelivery => 'Lieferung';

  @override
  String get stepHours => 'Zeiten';

  @override
  String get stepFinish => 'Fertig';

  @override
  String get step1Title => 'Fangen wir mit den Grundlagen an';

  @override
  String get step1Subtitle =>
      'Wählen Sie einen Namen und ein Logo für Ihren Shop';

  @override
  String get step2Title => 'Wie kann man Sie kontaktieren?';

  @override
  String get step2Subtitle =>
      'Geben Sie Telefonnummer und Adresse für Kunden ein';

  @override
  String get step3Title => 'Lieferservice';

  @override
  String get step3Subtitle => 'Bieten Sie Lieferung für Ihre Kunden an?';

  @override
  String get enableDeliveryLabel => 'Lieferung aktivieren';

  @override
  String get deliveryEnabled => 'Service aktiviert';

  @override
  String get deliveryDisabled => 'Service deaktiviert';

  @override
  String get fixedDeliveryPriceLabel => 'Fester Lieferpreis';

  @override
  String get deliveryPriceHelper =>
      'Leer lassen, um Preis später pro Bestellung festzulegen';

  @override
  String get step4Title => 'Wann ist Ihr Shop geöffnet?';

  @override
  String get step4Subtitle =>
      'Sie können diesen Schritt überspringen und später hinzufügen';

  @override
  String get step5Title => 'Letzter Schritt!';

  @override
  String get step5Subtitle => 'Fügen Sie Social-Media-Links hinzu (Optional)';

  @override
  String get shortDescriptionLabel => 'Kurzbeschreibung des Shops (Optional)';

  @override
  String get optionalBadge => 'Optional';

  @override
  String get skipButton => 'Überspringen';

  @override
  String get nextButton => 'Weiter';

  @override
  String get finishSetupButton => 'Einrichtung abschließen';

  @override
  String get validationEnterStoreName => 'Bitte geben Sie den Shop-Namen ein';

  @override
  String get validationEnterPhone => 'Bitte geben Sie eine Telefonnummer ein';

  @override
  String get logoutConfirmMsg =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get logoutConfirmButton => 'Abmelden';

  @override
  String locationFetchError(Object error) {
    return 'Fehler beim Abrufen des Standorts: $error';
  }

  @override
  String get fillAllFieldsError => 'Bitte füllen Sie alle Felder aus';

  @override
  String get passwordsNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordTooShort => 'Passwort ist zu kurz (mind. 6 Zeichen)';

  @override
  String generalError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get storeNameRequired => 'Shop-Name ist erforderlich';

  @override
  String get noEditPermission => 'Sie haben keine Berechtigung zum Bearbeiten';

  @override
  String get addProductTitle => 'Produkt hinzufügen';

  @override
  String get editProductTitle => 'Produkt bearbeiten';

  @override
  String get requiredField => 'Erforderlich';

  @override
  String get productNameLabel => 'Produktname';

  @override
  String get priceLabel => 'Preis';

  @override
  String get newCategoryLabel => 'Neue Kategorie';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get addNewCategory => 'Neu hinzufügen';

  @override
  String get sizeLabel => 'Größe';

  @override
  String get unitLabel => 'Einheit';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get descQuality => 'Hohe Qualität & toller Geschmack';

  @override
  String get descFresh => 'Frisch & Täglich';

  @override
  String get descBestseller => 'Unser Bestseller';

  @override
  String get descLimited => 'Begrenztes Angebot';

  @override
  String get descHandmade => 'Luxuriöse Handarbeit';

  @override
  String get descNatural => '100% Natürlich';

  @override
  String get productAvailable => 'Produkt verfügbar';

  @override
  String get visibleToCustomers => 'Für Kunden sichtbar';

  @override
  String get hiddenFromCustomers => 'Vor Kunden verborgen';

  @override
  String get specialOfferAvailable => 'Sonderangebot';

  @override
  String get specialOfferSubtitle =>
      'Rabatte oder Großhandelsangebote aktivieren';

  @override
  String get offerTypeLabel => 'Angebotstyp';

  @override
  String get offerTypePercent => 'Prozentsatz %';

  @override
  String get offerTypeBundle => 'Bundle-Angebot';

  @override
  String get offerTypeBulk => 'Mengenstaffelpreis';

  @override
  String get percentageLabel => 'Prozentsatz (%)';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get totalPriceLabel => 'Gesamtpreis';

  @override
  String get quantityStartLabel => 'Menge (ab)';

  @override
  String get pricePerPieceLabel => 'Preis pro Stück';

  @override
  String get offerDurationLabel => 'Angebotsdauer';

  @override
  String get saveButton => 'Speichern';

  @override
  String get productPublishedMsg => 'Produkt veröffentlicht';

  @override
  String get uploading => 'Wird hochgeladen...';

  @override
  String get processing => 'Wird verarbeitet...';

  @override
  String get errorStatus => 'Fehler';

  @override
  String get productImageLabel => 'Produktbild';

  @override
  String get tapToUpload => 'Tippen zum Hochladen';

  @override
  String get optionalSuffix => '(Optional)';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'g';

  @override
  String get unitL => 'l';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPcs => 'Stk.';

  @override
  String get deleteCategoryTitle => 'Kategorie löschen';

  @override
  String deleteCategoryMsg(Object name) {
    return 'Möchten Sie \"$name\" löschen? Produkte werden nach \"Andere\" verschoben.';
  }

  @override
  String get categoriesLoadError => 'Kategorien konnten nicht geladen werden';

  @override
  String get categoryRenameTitle => 'Kategorie bearbeiten';

  @override
  String get categoryRenameLabel => 'Neuer Kategoriename';

  @override
  String get categoryRenameSuccess => 'Kategorie erfolgreich umbenannt';

  @override
  String get categoryRenameFail => 'Kategorie konnte nicht umbenannt werden';

  @override
  String get categoryRenameError => 'Fehler beim Umbenennen der Kategorie';

  @override
  String deleteCategoryConfirmMsg(Object moveTo, Object name) {
    return 'Alle Produkte werden von \"$name\" nach \"$moveTo\" verschoben. Sind Sie sicher?';
  }

  @override
  String get categoryDeleteSuccess => 'Kategorie erfolgreich gelöscht';

  @override
  String get categoryDeleteFail => 'Kategorie konnte nicht gelöscht werden';

  @override
  String get categoryDeleteError => 'Fehler beim Löschen der Kategorie';

  @override
  String productsCount(Object count) {
    return '$count Produkte';
  }

  @override
  String get viewProductsAction => 'Produkte anzeigen';

  @override
  String get viewProductsSubtitle => 'Produktliste für diese Kategorie öffnen';

  @override
  String get applyCategoryOfferAction => 'Angebot auf Kategorie anwenden';

  @override
  String get applyCategoryOfferSubtitle =>
      'Prozentualer Rabatt für alle Produkte';

  @override
  String get stopCategoryOffersAction => 'Kategorie-Angebote stoppen';

  @override
  String get stopCategoryOffersSubtitle =>
      'Alle Angebote in dieser Kategorie deaktivieren';

  @override
  String get categoryFullOfferTitle => 'Vollständiges Kategorie-Angebot';

  @override
  String applyToCategorySubtitle(Object category) {
    return 'Auf \"$category\" anwenden';
  }

  @override
  String get percentageHint => 'Beispiel: 15';

  @override
  String get offerValidityLabel => 'Angebotsgültigkeit';

  @override
  String get invalidPercentageError => 'Gültigen Prozentsatz eingeben';

  @override
  String get applyOfferButton => 'Angebot anwenden';

  @override
  String categoryOfferAppliedMsg(Object category) {
    return 'Angebot auf Kategorie \"$category\" angewendet';
  }

  @override
  String get categoryOfferApplyFail => 'Anwenden des Angebots fehlgeschlagen';

  @override
  String categoryOffersDisabledMsg(Object category) {
    return 'Angebote für Kategorie \"$category\" gestoppt';
  }

  @override
  String get categoryOffersDisableFail => 'Stoppen der Angebote fehlgeschlagen';

  @override
  String get manageCategories => 'Kategorien verwalten';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String categoriesCountLabel(Object count) {
    return '$count Kategorien';
  }

  @override
  String get noCategoriesTitle => 'Noch keine Kategorien';

  @override
  String get noCategoriesSubtitle =>
      'Fügen Sie neue Kategorien hinzu, um Ihre Produkte zu organisieren';

  @override
  String offerUntilDate(Object date) {
    return 'Bis $date';
  }

  @override
  String discountPercent(Object percent) {
    return '$percent% Rabatt';
  }

  @override
  String bundleOfferLabel(Object currency, Object price, Object qty) {
    return '$qty für $price $currency';
  }

  @override
  String get offerLabel => 'Angebot';

  @override
  String get availableStatus => ' Verfügbar';

  @override
  String get unavailableStatus => 'Nicht verfügbar';

  @override
  String get updateFail => 'Aktualisierung fehlgeschlagen';

  @override
  String get deleteProductTitle => 'Produkt löschen';

  @override
  String deleteProductConfirmMsg(Object name) {
    return 'Möchten Sie \"$name\" löschen?';
  }

  @override
  String get deleteSuccess => 'Erfolgreich gelöscht';

  @override
  String get deleteFail => 'Löschen fehlgeschlagen';

  @override
  String get noProducts => 'Keine Produkte gefunden';

  @override
  String get customerMessageTitle => 'Shop-Nachricht';

  @override
  String get templateDiscountTitle => 'Sonderrabatt';

  @override
  String get templateDiscountText =>
      '🔥 Spezieller 20% Rabatt auf alle Produkte für kurze Zeit! Nicht verpassen.';

  @override
  String get templateWelcomeTitle => 'Willkommen';

  @override
  String get templateWelcomeText =>
      'Willkommen in unserem Shop! Wir wünschen Ihnen ein frohes Einkaufserlebnis. ✨';

  @override
  String get templateNewTitle => 'Neuheiten';

  @override
  String get templateNewText =>
      'Eine neue Kollektion ist eingetroffen! Stöbern Sie jetzt durch die neuesten Produkte. 🆕';

  @override
  String get templateDeliveryTitle => 'Kostenlose Lieferung';

  @override
  String get templateDeliveryText =>
      'Bestellen Sie jetzt und erhalten Sie kostenlose Lieferung für Bestellungen über 50 Euro! 🚚';

  @override
  String get templateOccasionTitle => 'Anlass';

  @override
  String get templateOccasionText =>
      'Frohe Feiertage! Genießen Sie unsere exklusiven Angebote. 🌙';

  @override
  String get loadDataError => 'Daten konnten nicht geladen werden';

  @override
  String get messagePublishedSuccess =>
      'Nachricht erfolgreich veröffentlicht ✅';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen, bitte erneut versuchen';

  @override
  String get connectionError => 'Verbindungsfehler';

  @override
  String get messageDeleted => 'Nachricht gelöscht 🗑';

  @override
  String get deleteMessageTitle => 'Nachricht löschen';

  @override
  String get deleteMessageConfirm =>
      'Sind Sie sicher, dass Sie die Nachricht löschen möchten? Sie wird Kunden nicht mehr angezeigt.';

  @override
  String get chooseTemplateTitle => 'Vorlage wählen';

  @override
  String get previewTitle => 'Kundenvorschau';

  @override
  String get editMessageTitle => 'Nachricht bearbeiten';

  @override
  String get templatesButton => 'Vorlagen';

  @override
  String get displayDurationTitle => 'Anzeigedauer';

  @override
  String get previewPlaceholder => 'Ihre Nachricht erscheint hier...';

  @override
  String get messageHint => 'Z.B.: 20% Rabatt auf alle Produkte 🌙';

  @override
  String get engageTextHint =>
      'Geben Sie ansprechenden Text ein, um den Umsatz zu steigern';

  @override
  String get durationAlways => 'Immer';

  @override
  String get durationDay => '1 Tag';

  @override
  String get duration3Days => '3 Tage';

  @override
  String get durationWeek => '1 Woche';

  @override
  String get durationMonth => '1 Monat';

  @override
  String get saveAndPublishButton => 'Speichern und Veröffentlichen';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get restorePasswordHeadline => 'Passwort zurücksetzen';

  @override
  String get restorePasswordDesc =>
      'Geben Sie Ihre registrierte E-Mail ein, um einen Link zum Zurücksetzen zu erhalten.';

  @override
  String get enterEmailValidation => 'Bitte E-Mail eingeben';

  @override
  String get invalidEmailFormat => 'Ungültiges E-Mail-Format';

  @override
  String get resetLinkSentMsg =>
      'Link zum Zurücksetzen des Passworts wurde an Ihre E-Mail gesendet.';

  @override
  String get emailNotRegistered => 'Diese E-Mail ist nicht registriert.';

  @override
  String get generalSendError =>
      'Konnte nicht gesendet werden. Bitte überprüfen Sie die E-Mail-Adresse.';

  @override
  String get sendLinkButton => 'Link senden';

  @override
  String get backToLogin => 'Zurück zum Login';

  @override
  String get homeTitle => 'Startseite';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get dashboardSubtitle =>
      'Hier ist eine kurze Zusammenfassung Ihres Shops heute';

  @override
  String get publicStoreLink => 'Öffentlicher Shop-Link';

  @override
  String get noLinkYet => 'Noch kein Link';

  @override
  String get copyLinkSuccess => 'Link kopiert!';

  @override
  String get shareStoreInvite => 'Shop-Einladung teilen';

  @override
  String get customerMessagePlaceholder =>
      'Noch keine Nachricht eingestellt. Tippen zum Hinzufügen.';

  @override
  String get liveStatsTitle => 'Live-Statistiken';

  @override
  String get statsTotalProducts => 'Produkte';

  @override
  String get statsAvailable => ' Verfügbar';

  @override
  String get statsUnavailable => 'Nicht verfügbar';

  @override
  String get statsOffers => 'Angebote';

  @override
  String get statsCategoryOffers => 'Kat. Angebote';

  @override
  String get statsNoImage => 'Kein Bild';

  @override
  String get statsLargestCategory => 'Größte Kat.';

  @override
  String get filterAllProducts => 'Alle Produkte';

  @override
  String get filterAvailable => 'Verfügbare Produkte';

  @override
  String get filterUnavailable => 'Nicht verfügbare Produkte';

  @override
  String get filterActiveOffers => 'Aktive Angebote';

  @override
  String get filterNoImage => 'Produkte ohne Bild';

  @override
  String filterCategoryPrefix(Object category) {
    return 'Kategorie: $category';
  }

  @override
  String noProductsFoundTitle(Object title) {
    return 'Keine Produkte: $title';
  }

  @override
  String get categoryOffersTitle => 'Vollständige Kategorie-Angebote';

  @override
  String get categoryOffersSubtitle =>
      'Kategorien, in denen alle Produkte im Angebot sind';

  @override
  String get noCategoryOffers => 'Keine Kategorien mit vollständigen Angeboten';

  @override
  String get stopOfferAction => 'Stopp';

  @override
  String get stopCategoryOfferSuccess => 'Kategorie-Angebote gestoppt';

  @override
  String get expirationAlertTitle => 'Ablaufwarnung';

  @override
  String expirationAlertMsg(Object days) {
    return 'Hallo! Ihr Shop-Abonnement läuft in $days Tagen ab. Bitte erneuern Sie es jetzt, um Unterbrechungen zu vermeiden.';
  }

  @override
  String get renewNowButton => 'Jetzt erneuern';

  @override
  String get laterButton => 'Später';

  @override
  String get navHome => 'Start';

  @override
  String get navProducts => 'Produkte';

  @override
  String get navCategories => 'Kategorien';

  @override
  String get navStore => 'Shop';

  @override
  String get activateButton => 'Aktivieren';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginSubtitle =>
      'Geben Sie Ihre Kontodaten ein, um auf Ihren Shop zuzugreifen';

  @override
  String get loginEmailOrPassError => 'Falsche E-Mail oder Passwort';

  @override
  String get noStoreTitle => 'Kein Shop gefunden';

  @override
  String get noStoreMessage =>
      'Möchten Sie mit diesem Konto einen neuen Shop erstellen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get createStore => 'Shop erstellen';

  @override
  String get loginNoPermission => 'Zugriff verweigert';

  @override
  String get googleLoginFailed => 'Google-Anmeldung fehlgeschlagen';

  @override
  String get unexpectedError =>
      'Entschuldigung, ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get googleSigningIn => 'Anmelden...';

  @override
  String get googleSignIn => 'Mit Google anmelden';

  @override
  String get orSeparator => 'ODER';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get emailHint => 'beispiel@email.de';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get emailInvalid => 'Ungültiges E-Mail-Format';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get signInButton => 'Anmelden';

  @override
  String get noAccount => 'Kein Konto?';

  @override
  String get createNewStore => 'Neuen Shop erstellen';

  @override
  String get activationSuccessTitle => 'Aktivierung erfolgreich!';

  @override
  String get activationSuccessMsg =>
      'Danke! Ihr Shop wurde erfolgreich aktiviert.';

  @override
  String get startNowButton => 'Jetzt starten';

  @override
  String get loadingErrorPrefix => 'Fehler: ';

  @override
  String get choosePlanTitle => 'Wählen Sie Ihren Plan';

  @override
  String get noPlansAvailable => 'Derzeit keine Pläne verfügbar';

  @override
  String get choosePlanSubtitle => 'Wählen Sie den passenden Abonnementplan';

  @override
  String get savePercentage => '20% sparen';

  @override
  String get paymentLinkError => 'Server hat keinen Zahlungslink zurückgegeben';

  @override
  String get paymentPrepError =>
      'Fehler bei der Vorbereitung der Zahlung. Bitte versuchen Sie es später erneut.';

  @override
  String payAndActivate(Object price) {
    return '$price zahlen & aktivieren';
  }

  @override
  String get featureUnlimitedProducts => 'Unbegrenzte Produkte';

  @override
  String get featurePremiumSupport => 'Premium-Support';

  @override
  String get featureAdvancedStats => 'Erweiterte Statistiken';

  @override
  String get featureNoCommission => 'Keine Verkaufsgebühr';

  @override
  String get paymentAndActivationTitle => 'Zahlung & Aktivierung';

  @override
  String get adminContactLabel => 'Aktivierungsmanager';

  @override
  String get step1ChoosePlan => '1. Plan wählen:';

  @override
  String get step2PaymentDetails => '2. Zahlungsdetails (Hier überweisen):';

  @override
  String get qrCodePlaceholder => 'QR-Code Foto';

  @override
  String get accountNumberLabel => 'Kontonummer / ID';

  @override
  String get copyIdSuccess => 'ID kopiert';

  @override
  String get sendActivationInfoButton => 'Aktivierungsinfo senden';

  @override
  String get afterPaymentInstruction =>
      'Nach der Zahlung tippen Sie auf den Button, um Shop-Name und ID automatisch zu senden.';

  @override
  String get sharePaymentConfirmTitle => 'Zahlungsbestätigung senden über';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get telegramLabel => 'Telegram';

  @override
  String get telegramCopySuccess => 'Nachricht kopiert! In den Chat einfügen.';

  @override
  String paymentMessageBody(
    Object planName,
    Object price,
    Object storeId,
    Object storeName,
  ) {
    return 'Hallo, ich habe den Betrag zur Aktivierung des Shops überwiesen.\nBitte aktivieren:\n\n🏪 *Shop:* $storeName\n🆔 *ID:* $storeId\n📅 *Plan:* $planName ($price)\n\nDanke!';
  }

  @override
  String get productsTitle => 'Produkte';

  @override
  String get manageProducts => 'Produkte verwalten';

  @override
  String get productsLoadError => 'Produkte konnten nicht geladen werden';

  @override
  String get productUpdateSuccess => 'Produkt erfolgreich aktualisiert';

  @override
  String get productUpdateStatusFail =>
      'Produktstatus konnte nicht aktualisiert werden';

  @override
  String get offerUpdateFail => 'Angebot konnte nicht aktualisiert werden';

  @override
  String get productDeleteSuccess => 'Produkt erfolgreich gelöscht';

  @override
  String get productDeleteFail => 'Produkt konnte nicht gelöscht werden';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterReset => 'Zurücksetzen';

  @override
  String get filterApply => 'Anwenden';

  @override
  String get stockStatusLabel => 'Status';

  @override
  String get offersLabel => 'Angebote';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterWithOffer => 'Mit Angebot';

  @override
  String get filterWithoutOffer => 'Ohne Angebot';

  @override
  String get filterActive => 'Verfügbar / Aktiv';

  @override
  String get filterInactive => 'Nicht verfügbar / Inaktiv';

  @override
  String get disableProduct => 'Produkt deaktivieren';

  @override
  String get enableProduct => 'Produkt aktivieren';

  @override
  String get disableOffer => 'Angebot deaktivieren';

  @override
  String get enableOffer => 'Angebot aktivieren';

  @override
  String get noSearchResults => 'Keine Ergebnisse gefunden';

  @override
  String get noStoreFound => 'Kein Shop gefunden';

  @override
  String get noStoreMsg =>
      'App-Daten fehlen möglicherweise.\nBitte melden Sie sich an oder richten Sie den Shop erneut ein.';

  @override
  String get setupStoreButton => 'Shop einrichten';

  @override
  String get reloginButton => 'Erneut anmelden';

  @override
  String get registerTitle => 'Shop erstellen';

  @override
  String get completeStoreCreation => 'Shop-Erstellung abschließen';

  @override
  String get enterStoreNamePrompt =>
      'Shop-Namen eingeben, um Registrierung abzuschließen';

  @override
  String get googleAccountLabel => 'Google-Konto';

  @override
  String get trialPeriodInfo => 'Kostenlose Testversion';

  @override
  String get createStoreButton => 'Shop erstellen';

  @override
  String get cancelAndReturnToLogin => 'Abbrechen und zum Login zurückkehren';

  @override
  String get registerNewStoreTitle => 'Neuen Shop erstellen';

  @override
  String get registerSubtitle =>
      'Erstellen Sie Ihren Shop und erhalten Sie eine kostenlose Testversion';

  @override
  String get googleRegisterButton => 'Mit Google registrieren';

  @override
  String get googleRegistering => 'Registrierung läuft...';

  @override
  String get storeNameHint => 'Beispiel: Mein Shop';

  @override
  String get storeNameTooShort => 'Shop-Name ist zu kurz (mind. 3 Zeichen)';

  @override
  String get requireEmailVerifyLabel =>
      'E-Mail-Bestätigung von Kunden verlangen';

  @override
  String get requireEmailVerifySubtitle =>
      'Neue Kunden müssen ihre E-Mail bestätigen';

  @override
  String get createAccountButton => 'Konto erstellen';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get loginLink => 'Anmelden';

  @override
  String get registerFailedMsg =>
      'Kontoerstellung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String errorOccurred(Object error) {
    return 'Fehler aufgetreten: $error';
  }

  @override
  String get resetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get resetLinkSentTitle => 'Zurücksetzungs-Link gesendet';

  @override
  String checkEmailForResetMsg(Object username) {
    return 'Bitte überprüfen Sie Ihre E-Mail ($username) und folgen Sie dem Link, um Ihr Passwort zu ändern.';
  }

  @override
  String get backToLoginButton => 'Zurück zum Login';

  @override
  String get subscriptionInfoTitle => 'Abonnement-Details';

  @override
  String get activePremiumTitle => 'Aktives Premium-Abonnement';

  @override
  String get activePremiumSubtitle =>
      'Ihr Shop ist ohne Einschränkungen voll funktionsfähig';

  @override
  String get trialPeriodTitle => 'Testzeitraum';

  @override
  String trialRemaining(Object days) {
    return 'Noch $days Tage im Testzeitraum';
  }

  @override
  String get freeTrial => 'Kostenloser Testzeitraum';

  @override
  String get subscriptionExpiredTitle => 'Abonnement abgelaufen';

  @override
  String get subscriptionExpiredSubtitle =>
      'Shop-Funktionen sind vorübergehend ausgesetzt';

  @override
  String get accountStatus => 'Kontostatus';

  @override
  String get contactSupport => 'Bitte kontaktieren Sie den Support';

  @override
  String get planDetailsCardTitle => 'Plandetails & Daten';

  @override
  String get storeLabel => 'Shop';

  @override
  String get subscriptionTypeLabel => 'Abonnement-Typ';

  @override
  String get premiumYearly => 'Premium (Jährlich)';

  @override
  String get trialFree => 'Test / Kostenlos';

  @override
  String get creationDate => 'Erstellungsdatum';

  @override
  String get activatedAt => 'Aktiviert am';

  @override
  String get subscriptionEndsAt => 'Abonnement endet am';

  @override
  String get trialStartedAt => 'Test gestartet am';

  @override
  String get trialEndsAt => 'Test endet am';

  @override
  String get subscriptionEndedAt => 'Abonnement endete am';

  @override
  String get trialEndedAt => 'Test endete am';

  @override
  String get currentBenefitsTitle => 'Aktuelle Abo-Vorteile';

  @override
  String get benefitUnlimitedProducts =>
      'Unbegrenzte Produkte hinzufügen und verwalten';

  @override
  String get benefitHighQualityImages => 'Hochwertige Bildanzeige für Kunden';

  @override
  String get benefitShowPrices => 'Preise und Größen auf der Website sichtbar';

  @override
  String get benefitFullControl => 'Volle Kontrolle über Shop-Einstellungen';

  @override
  String get benefitDirectSupport => 'Direkter und schneller Support';

  @override
  String get restrictionStagesTitle => 'Shop-Einschränkungsstufen';

  @override
  String get restrictionStage1 =>
      'Produktbilder im öffentlichen Shop ausblenden';

  @override
  String get restrictionStage2 => 'Preise, Größen und Kontaktinfos ausblenden';

  @override
  String get restrictionStage3 =>
      'Vollständige Sperrung von Dashboard und Shop';

  @override
  String get renewSubscriptionButton => 'Abonnement jetzt erneuern';

  @override
  String get verifyEmailTitle => 'E-Mail bestätigen';

  @override
  String get logoutTooltip => 'Abmelden';

  @override
  String get checkYourEmailTitle => 'Prüfen Sie Ihre E-Mails';

  @override
  String get sentLinkTo => 'Wir haben einen Bestätigungslink gesendet an:';

  @override
  String get verifyEmailInstructions =>
      'Öffnen Sie Ihre E-Mail und klicken Sie auf den Bestätigungslink.\nSie werden nach der Bestätigung automatisch weitergeleitet.';

  @override
  String get checkNowButton => 'Jetzt prüfen';

  @override
  String get checkingStatus => 'Prüfe...';

  @override
  String get resendButton => 'Keine E-Mail erhalten? Erneut senden';

  @override
  String resendCountdown(Object seconds) {
    return 'Erneut senden in ${seconds}s';
  }

  @override
  String get spamFolderHint =>
      'Prüfen Sie Ihren Spam-Ordner, wenn Sie die E-Mail nicht sehen.';

  @override
  String get emailVerifiedSuccess => 'E-Mail erfolgreich bestätigt!';

  @override
  String get verificationLinkSent => 'Bestätigungslink erneut gesendet';

  @override
  String verificationLinkSendFail(Object error) {
    return 'Fehler beim Senden des Links: $error';
  }

  @override
  String get defaultEmailPlaceholder => 'Ihre E-Mail';

  @override
  String get drawerStoreFallback => 'Ihr Shop';

  @override
  String supportEmailSubject(Object id, Object name) {
    return 'Support-Nachricht von - $name \n (ID: $id)';
  }

  @override
  String supportEmailBody(Object id, Object name) {
    return '\nShop-Info:\nName: $name\nID: $id \n---\n';
  }

  @override
  String get supportCenterTitle => 'Support-Center';

  @override
  String get supportCenterMsg =>
      'Wir sind hier, um zu helfen! Wir freuen uns immer über Ihre Anfragen oder Vorschläge zur Verbesserung der App.';

  @override
  String get contactEmailLabel => 'Kontakt-E-Mail:';

  @override
  String get emailCopiedMsg => 'E-Mail kopiert';

  @override
  String get closeButton => 'Schließen';

  @override
  String get sendNowButton => 'Jetzt senden';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get drawerTheme => 'Erscheinungsbild';

  @override
  String get drawerSupport => 'Support';

  @override
  String get drawerAdvancedStats => 'Erweiterte Statistiken';

  @override
  String get drawerAbout => 'Über die App';

  @override
  String get drawerRate => 'App bewerten';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get upgradeBannerText =>
      'Konto upgraden für Zugriff auf alle Funktionen';

  @override
  String get aboutAppDesc =>
      'Fortschrittliche Anwendung zur einfachen Verwaltung von Online-Shops.';

  @override
  String get advancedStatsTitle => 'Erweiterte Statistiken';

  @override
  String get advancedStatsMsg =>
      'Diese Seite ist nur für Premium-Abonnenten verfügbar. Demnächst verfügbar.';

  @override
  String get okButton => 'OK';

  @override
  String get rateAppTitle => 'Wie finden Sie die App?';

  @override
  String get rateAppMsg =>
      'Ihre Bewertung hilft uns, den Service zu verbessern und neue Funktionen zu entwickeln.';

  @override
  String get rateAppHint => 'Sagen Sie uns, wie wir uns verbessern können?';

  @override
  String get rateAppGooglePlayMsg =>
      'Es freut uns, dass Ihnen die App gefällt! Möchten Sie uns im Google Play Store bewerten?';

  @override
  String get sendButton => 'Senden';

  @override
  String get ratingThanksMsg =>
      'Danke für Ihr Feedback, wir arbeiten an der Verbesserung der App!';

  @override
  String get loadingStatus => 'Laden...';

  @override
  String get premiumStatus => 'Premium ✨';

  @override
  String trialStatusDays(Object days) {
    return 'Test ($days Tage)';
  }

  @override
  String get trialStatus => 'Test';

  @override
  String get expiredStatus => 'Abgelaufen';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get loadingMessage => 'Laden...';

  @override
  String get appName => 'Produktmanagement';

  @override
  String get appSubtitle => 'Al-Deeb';

  @override
  String get sessionExpiredMsg =>
      'Sitzung abgelaufen. Bitte registrieren Sie sich erneut.';

  @override
  String get accountNotRegisteredMsg =>
      'Konto nicht registriert. Bitte erstellen Sie einen neuen Shop.';

  @override
  String get paymentSuccessMsg => 'Zahlung erfolgreich!';

  @override
  String get uploadPreparing => 'Bild wird vorbereitet...';

  @override
  String get uploadStoreIdMissing => 'Shop-ID fehlt';

  @override
  String uploadingProgress(Object progress) {
    return 'Hochladen... $progress%';
  }

  @override
  String get uploadProcessing => 'Bild wird verarbeitet...';

  @override
  String get uploadDone => 'Fertig ✅';

  @override
  String get validationEnterPriceValid => 'Bitte einen gültigen Preis eingeben';

  @override
  String get validationSelectCategory => 'Bitte eine Kategorie auswählen';

  @override
  String get saveProductError => 'Produkt konnte nicht gespeichert werden';

  @override
  String get alreadySaving => 'Wird bereits gespeichert';

  @override
  String get defaultStoreName => 'Mein Shop';

  @override
  String inviteText(Object storeName, Object url) {
    return 'Willkommen bei \"$storeName\"! 🛍️✨\n\nWir freuen uns, Sie einzuladen, unseren Shop zu besuchen, die neuesten Produkte zu durchstöbern und direkt über folgenden Link zu bestellen:\n$url\n\nWir freuen uns auf Sie! 😊';
  }

  @override
  String get defaultCategoryOthers => 'Andere';

  @override
  String get languageLabel => 'App-Sprache';

  @override
  String get languageArabic => 'Arabisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get errorPermissionDenied =>
      'Zugriff verweigert. Bitte melden Sie sich zuerst an.';

  @override
  String get errorEmailInUse => 'E-Mail wird bereits verwendet';

  @override
  String get errorInvalidEmail => 'Ungültiges E-Mail-Format';

  @override
  String get errorWeakPassword =>
      'Passwort zu schwach. Verwenden Sie mindestens 6 Zeichen';

  @override
  String get errorUserNotFound => 'Ungültige Anmeldedaten';

  @override
  String get errorNetwork => 'Netzwerkfehler';

  @override
  String get errorUnknown =>
      'Unerwarteter Fehler. Bitte versuchen Sie es erneut';

  @override
  String get errorNoStoreFound =>
      'Entschuldigung, kein Konto für diese E-Mail gefunden.';

  @override
  String get errorAccountExpired =>
      'Kontoaktivierung abgelaufen. Bitte registrieren Sie sich erneut.';
}
