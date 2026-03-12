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
  String get currencyLabel => 'Store Währung*';

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
  String get step5Title =>
      'Herzlichen Glückwunsch! Deine Shop-Daten sind eingerichtet.';

  @override
  String get step5Subtitle =>
      'Du hast das Setup abgeschlossen. Du kannst es später in deinem Profil bearbeiten.';

  @override
  String get step5SubtitleWeb =>
      'Für iPhone-Nutzer: Tippe unten auf den Teilen-Button und wähle \'Zum Home-Bildschirm hinzufügen\' für ein besseres Erlebnis.';

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
  String get engageTextHint => 'Text eingeben, um den Verkauf zu steigern';

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
  String welcomeStoreName(Object storeName) {
    return 'Willkommen, $storeName';
  }

  @override
  String get validationEnterAddress =>
      'Bitte geben Sie die Adresse des Geschäfts ein';

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
  String get stopCategoryOfferConfirm =>
      'Bist du sicher? Es werden alle Angebotsarten dieser Kategorie gestoppt.';

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
  String get featureUnlimitedProducts =>
      'Umfangreiches Inventar (bis 400 Prod.)';

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
  String get copyIdSuccess => 'تم نسخ المعرف';

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
  String get drawerHelpfulInfo => 'Hilfreiche Tipps';

  @override
  String fieldsMissing(String fields) {
    return 'Fehlend: $fields';
  }

  @override
  String get updateAvailableTitle => 'Update verfügbar';

  @override
  String get updateAvailableMsg =>
      'Eine neue Version der App ist verfügbar. Aktualisiere jetzt, um die neuesten Funktionen und Verbesserungen zu erhalten.';

  @override
  String get updateNowButton => 'Jetzt aktualisieren';

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

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get noProductsFound => 'Keine Produkte gefunden';

  @override
  String get dashboardLoadError => 'Dashboard konnte nicht geladen werden';

  @override
  String get dashboardUpdateError =>
      'Dashboard konnte nicht aktualisiert werden';

  @override
  String get logoutConfirmTitle => 'Abmeldung bestätigen';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get storeLangLabel => 'Website-Sprache';

  @override
  String get storeLangHelper =>
      'Wählen Sie die Sprache, in der Ihr Shop für Kunden angezeigt wird';

  @override
  String get congratulationsTitle => 'Herzlichen Glückwunsch! 🎉';

  @override
  String get storeReadyMsg => 'Dein Shop-Link ist jetzt bereit!';

  @override
  String get yourStoreLinkLabel => 'Dein Shop-Link';

  @override
  String get goToHomeButton => 'Zur Startseite';

  @override
  String get step3TransferInfo => '3. Überweisungsangaben:';

  @override
  String get transferAccountNameLabel => 'Name des Absenders / Kontoinhabers';

  @override
  String get transferAccountNameHint => 'Beispiel: Max Mustermann';

  @override
  String get transferAccountNameRequired =>
      'Bitte geben Sie den Namen des Kontoinhabers ein';

  @override
  String get transferAccountNameHelper =>
      'Geben Sie den Namen ein, von dem Sie überwiesen haben, damit wir die Zahlung überprüfen können';

  @override
  String get confirmPaymentButton =>
      'Zahlung bestätigen & Aktivierung beantragen';

  @override
  String get submittingRequest => 'Anfrage wird gesendet...';

  @override
  String get activationRequestInstruction =>
      'Nach der Überweisung geben Sie den Kontonamen ein und tippen Sie auf den Button, um Ihre Aktivierungsanfrage zu senden.';

  @override
  String get orContactViaMessenger =>
      'Oder per WhatsApp / Telegram kontaktieren';

  @override
  String get activationRequestSentTitle => 'Anfrage gesendet!';

  @override
  String get activationRequestSentMsg =>
      'Vielen Dank! Ihre Aktivierungsanfrage wurde empfangen und wird in Kürze geprüft. Wir aktivieren Ihren Shop, sobald die Zahlung bestätigt ist.';

  @override
  String get activationRequestError =>
      'Beim Senden der Anfrage ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

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
      'Google-Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get errorGooglePopupBlocked =>
      'Das Anmelde-Popup wurde blockiert. Bitte Pop-ups erlauben oder die Weiterleitung verwenden.';

  @override
  String get pcs1 => '1 Stück';

  @override
  String get pcs2 => '2 Stück';

  @override
  String pcs3to10(Object count) {
    return '$count Stück';
  }

  @override
  String pcsOver10(Object count) {
    return '$count Stück';
  }

  @override
  String get securitySectionTitle => 'Sicherheit';

  @override
  String get securitySectionSubtitle => 'Passwort- und Kontosicherheit';

  @override
  String get setupCompleteMessage =>
      'Dein Shop ist bereit zur Veröffentlichung.';

  @override
  String get publishButton => 'Veröffentlichen';

  @override
  String get licensesButton => 'Lizenzen';

  @override
  String get privacyConsentTitle => 'Datenschutzhinweis';

  @override
  String get privacyConsentMessage =>
      'Wir verwenden (Google) für Authentifizierung und Datenspeicherung. Ihre IP-Adresse und Benutzer-ID werden von Google-Diensten verarbeitet. Durch die Nutzung dieser App stimmen Sie unserer Datenschutzerklärung zu.';

  @override
  String get privacyAcceptButton => 'Akzeptieren';

  @override
  String get privacyDeclineButton => 'Ablehnen';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get privacyDeclineMessage =>
      'Die App kann ohne Zustimmung zur Datenverarbeitung nicht verwendet werden.';

  @override
  String pricingForMonths(int months) {
    return 'für $months Monate';
  }

  @override
  String pricingTotal(String price) {
    return 'Gesamtpreis: $price';
  }

  @override
  String pricingOriginalPrice(String price) {
    return 'Statt $price';
  }

  @override
  String pricingSaveAmount(String amount) {
    return 'Du sparst $amount';
  }

  @override
  String pricingSaveTotalAmount(String amount) {
    return 'Gesamtersparnis: $amount';
  }

  @override
  String get pricingBestValue => 'Bestes Angebot';

  @override
  String get pricingPopular => 'Beliebt';

  @override
  String get pricingLimitedOffer => 'Zeitlich begrenztes Angebot';

  @override
  String get pricingMonthlyLabel => 'Monatlich';

  @override
  String get pricingYearlyLabel => 'Jährlich';

  @override
  String get pricingBiannualLabel => 'Halbjährlich';

  @override
  String get pricingQuarterlyLabel => 'Vierteljährlich';

  @override
  String get pricingOneMonth => '1 Monat';

  @override
  String pricingMonthsCount(int count) {
    return '$count Monate';
  }

  @override
  String pricingBilledAs(String total) {
    return 'Abgerechnet als $total';
  }

  @override
  String get productLimitReached =>
      'Du hast dein Produktlimit erreicht. Erweitere dein Abo, um mehr Produkte zu veröffentlichen.';

  @override
  String get paymentTitle => 'Wählen Sie Ihr Wachstum';

  @override
  String get bestValueLabel => 'EMPFEHLUNG';

  @override
  String get perMonth => '/ Mt.';

  @override
  String get totalAtCheckout => 'Gesamtsumme wird sicher bei Stripe angezeigt';

  @override
  String savePercent(Object percent) {
    return 'Spare $percent%';
  }

  @override
  String get yearlyPlanTitle => 'Yearly Plan';

  @override
  String get monthlyPlanTitle => 'Monthly Plan';

  @override
  String get pricingPerMonth => 'pro Monat';

  @override
  String get pricingBilledSixMonths => 'Abrechnung halbjährlich';

  @override
  String get pricingBilledYearly => 'Abrechnung jährlich';

  @override
  String get pricingMostPopular => 'Am beliebtesten';

  @override
  String pricingSavePercent(int percent) {
    return 'Spare $percent';
  }

  @override
  String get pricingFallbackEurInfo =>
      'Zahlung in USD (lokale Währung nicht verfügbar)';

  @override
  String get pricingCurrencyLabel => 'Währung:';

  @override
  String get common_ok => 'OK';

  @override
  String get common_later => 'Später';

  @override
  String get paywall_suspended_title => '⚠️ Shop vorübergehend gesperrt';

  @override
  String get paywall_suspended_body =>
      'Der Shop wurde vorübergehend deaktiviert.\nFalls Sie glauben, dass dies ein Fehler ist, kontaktieren Sie bitte den Support.';

  @override
  String get paywall_trial_welcome_title =>
      '🎁 Willkommen! Testphase aktiviert';

  @override
  String get paywall_trial_welcome_body =>
      'Fügen Sie Produkte hinzu und teilen Sie Ihren Shop-Link mit Kunden.\nTipp: Fügen Sie zu Beginn 5–10 Produkte hinzu, damit Ihr Shop ansprechend aussieht.';

  @override
  String get paywall_expired_s1_title => 'Testphase beendet';

  @override
  String get paywall_expired_s1_body =>
      'Ihr Shop ist für Kunden weiterhin sichtbar, aber Preise und Größen sind vorübergehend ausgeblendet.\n\nAktivieren Sie Ihr Abo, um alle Funktionen sofort wieder freizuschalten.';

  @override
  String get paywall_expired_s2_title => 'Bilder deaktiviert';

  @override
  String get paywall_expired_s2_body =>
      'Ihr Shop ist weiterhin sichtbar, aber Produktbilder sind vorübergehend ausgeblendet.\n\nAktivieren Sie Ihr Abo, um Bilder und weitere Funktionen sofort wiederherzustellen.';

  @override
  String get paywall_expired_s3_title => 'Shop derzeit inaktiv';

  @override
  String get paywall_expired_s3_body =>
      'Einige Funktionen wurden nach Ablauf der Testphase eingeschränkt.\n\nAktivieren Sie Ihr Abo, um den Shop wieder vollständig zu nutzen.';

  @override
  String get paywall_cta_activate_now => 'Jetzt aktivieren';

  @override
  String get paywall_cta_activate_store => 'Shop aktivieren';

  @override
  String get paywall_features_header => 'Durch die Aktivierung erhalten Sie:';

  @override
  String get feature_show_prices => 'Preise, Größen und Optionen anzeigen';

  @override
  String get feature_show_images => 'Produktbilder anzeigen';

  @override
  String get feature_edit_products => 'Produkte hinzufügen und bearbeiten';

  @override
  String get feature_faster_support => 'Schnelleren Support bei Bedarf';

  @override
  String get trial_popup_title => 'Willkommen zur Testphase! 🎉';

  @override
  String get trial_popup_body =>
      'Sie können jetzt alle Funktionen testen:\n• Produkte hinzufügen\n• Shop-Link teilen\n• Shop für Kunden anzeigen';

  @override
  String trial_days_remaining_msg(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tage in der Testphase verbleibend.',
      one: 'Noch ein Tag in der Testphase verbleibend.',
      zero: 'Heute ist der letzte Tag der Testphase.',
    );
    return '$_temp0';
  }

  @override
  String get locationPickerTitle => 'Standort wählen';

  @override
  String get saveLabel => 'Speichern';

  @override
  String get tapMapHint =>
      'Bitte tippe auf die Karte, um deinen Standort zu setzen.';

  @override
  String get selectLocationOnMap => 'Standort auf Karte wählen';

  @override
  String get imageSourceUpload => 'Hochladen';

  @override
  String get imageSourceLink => 'Link';

  @override
  String get imageUrlLabel => 'Bild-Link';

  @override
  String get imageUrlHint =>
      'Füge einen direkten Bild-Link ein (https://...jpg/png/webp).';

  @override
  String get pasteImageLink =>
      'Füge einen Bild-Link ein, um die Vorschau zu sehen';

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
    return 'Zahle nur $payQty und erhalte $qtyText';
  }

  @override
  String bundleDetail(Object price, Object qtyText) {
    return '$price für $qtyText';
  }

  @override
  String freeQtyBadge(Object freeQtyText) {
    return '$freeQtyText GRATIS';
  }

  @override
  String get bulkBadge => 'Mengenrabatt';

  @override
  String bulkOverlay(Object qty, Object qtyText) {
    return 'Ab $qty $qtyText';
  }

  @override
  String get pendingRequestTitle => 'Anfrage in Bearbeitung';

  @override
  String get pendingRequestMessage =>
      'Sie haben bereits eine Anfrage gesendet. Bitte warten Sie, bis der Administrator diese bestätigt hat.';

  @override
  String get regularPriceLabel => 'Normalpreis';

  @override
  String get discountedPriceLabel => 'Preis nach Rabatt';

  @override
  String get effectiveUnitPriceLabel => 'Stückpreis';

  @override
  String get effectiveDiscountLabel => 'Rabatt';

  @override
  String get logoHint => 'Ohne Logo wird der Shop-Name angezeigt';

  @override
  String get changeLogo => 'Logo ändern';

  @override
  String get deleteLogo => 'Logo löschen';

  @override
  String get deleteLogoConfirm => 'Möchtest du das Logo wirklich löschen?';

  @override
  String get showNameWithLogoLabel => 'Store-Name neben Logo';

  @override
  String get showNameWithLogoHint =>
      'Name wird im Menü neben dem Logo angezeigt';

  @override
  String get uploadError => 'Fehler beim Hochladen';

  @override
  String get unsavedChangesTitle => 'Ungespeicherte Änderungen';

  @override
  String get unsavedChangesMessage =>
      'Du hast ungespeicherte Änderungen. Willst du wirklich abbrechen? Alle Änderungen gehen verloren.';

  @override
  String get discardButton => 'Verwerfen';

  @override
  String get stayButton => 'Bleiben';

  @override
  String get addressDescriptionToggle =>
      'Zusätzliche Adressbeschreibung hinzufügen';

  @override
  String get addressDescriptionLabel => 'Adressbeschreibung (optional)';

  @override
  String get addressDescriptionHint =>
      'z.B. Neben der Bäckerei, 2. Stock links...';

  @override
  String get storeNameTooLong =>
      'Der Shopname darf maximal 40 Zeichen lang sein';

  @override
  String get recommendedCategoryLabel => 'Empfohlene Kategorie';

  @override
  String get xlsProductId => 'Produkt-ID';

  @override
  String get xlsName => 'Name';

  @override
  String get xlsCategory => 'Kategorie';

  @override
  String get xlsQty => 'Menge';

  @override
  String get xlsUnit => 'Einheit';

  @override
  String get xlsPurchasePrice => 'Einkaufspreis (EK)';

  @override
  String get xlsPrice => 'Preis (Einzel)';

  @override
  String get xlsVat => 'MwSt (%)';

  @override
  String get xlsGrossPrice => 'Brutto-Preis';

  @override
  String get xlsStock => 'Bestand';

  @override
  String get xlsSupplier => 'Lieferant';

  @override
  String get xlsActive => 'Status (aktiv)';

  @override
  String get xlsOfferType => 'Angebotsart';

  @override
  String get xlsCreatedAt => 'Erstellt am';

  @override
  String get xlsNote => 'Notiz';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nein';

  @override
  String get xlsExportButton => 'Excel-Export';

  @override
  String get xlsExportSuccess => 'Export erfolgreich heruntergeladen';

  @override
  String get xlsExportError => 'Export fehlgeschlagen';

  @override
  String get xlsExportDialogTitle => 'Produkte exportieren';

  @override
  String get xlsExportDialogMsg =>
      'Möchtest du alle Produkte als Excel-Datei herunterladen? Diese kannst du z. B. für die Buchhaltung verwenden.';

  @override
  String get xlsExportDialogConfirm => 'Herunterladen';

  @override
  String get descLangAr => 'AR';

  @override
  String get descLangDe => 'DE';

  @override
  String get descLangEn => 'EN';

  @override
  String get descLangTr => 'TR';

  @override
  String get autoTranslateButton => 'Auto-Übersetzen';

  @override
  String get autoTranslateUsed => 'Bereits übersetzt';

  @override
  String get autoTranslateSuccess => 'Beschreibung wurde automatisch übersetzt';

  @override
  String get autoTranslateError => 'Automatische Übersetzung fehlgeschlagen';

  @override
  String get autoTranslateBudgetExceeded => 'Übersetzungskontingent erschöpft';

  @override
  String get descriptionHintAr => 'Arabische Beschreibung';

  @override
  String get descriptionHintDe => 'Deutsche Beschreibung';

  @override
  String get descriptionHintEn => 'Englische Beschreibung';

  @override
  String get descriptionHintTr => 'Türkische Beschreibung';

  @override
  String get autoTranslateOnCreateTitle => 'Übersetzung automatisch erzeugen?';

  @override
  String get autoTranslateOnCreateHint =>
      'Gib nur eine Sprache ein – die anderen werden automatisch übersetzt.';

  @override
  String get pageDescLabelAr => 'Beschreibung auf Arabisch';

  @override
  String get pageDescLabelDe => 'Beschreibung auf Deutsch';

  @override
  String get pageDescLabelEn => 'Beschreibung auf Englisch';

  @override
  String get pageDescLabelTr => 'Beschreibung auf Türkisch';

  @override
  String get logoUploadInProgressMsg =>
      'Logo wird hochgeladen, bitte warten...';

  @override
  String get productPolicyMismatchTitle => 'Hinweis';

  @override
  String get productPolicyMismatchBody =>
      'Dieses Produkt entspricht nicht den Richtlinien der Plattform.';

  @override
  String get productPolicyMismatchSubtext =>
      'Wenn du denkst, das ist falsch, kontaktiere uns.';

  @override
  String get productPolicyMismatchCta => 'Support kontaktieren';

  @override
  String get pricingSummaryTitle => 'Zahlungsübersicht';

  @override
  String get pricingSummaryPlanLabel => 'Abo';

  @override
  String get pricingSummaryMonthlyLabel => 'Monatlich (entspricht)';

  @override
  String get pricingSummaryTotalLabel => 'Gesamt (heute fällig)';

  @override
  String get pricingCheckoutTitle => 'Zahlungsübersicht';

  @override
  String get pricingCheckoutPlanLabel => 'Plan';

  @override
  String get pricingCheckoutOriginalLabel => 'Originalpreis vor dem Angebot';

  @override
  String get pricingCheckoutOfferLabel => 'Rabatt angewendet';

  @override
  String get pricingCheckoutTotalLabel => 'Gesamt';

  @override
  String pricingCheckoutDiscountValue(Object amount, Object percent) {
    return 'Rabatt $percent  (%$amount)';
  }

  @override
  String get pricingActivationYearly => 'Store für 1 Jahr aktivieren';

  @override
  String get pricingActivationSixMonths => 'Store für 6 Monate aktivieren';

  @override
  String get alreadyRatedTitle => 'Vielen Dank für Ihre Bewertung!';

  @override
  String get alreadyRatedMsg =>
      'Sie haben die App bereits bewertet. Möchten Sie Ihre Bewertung im Google Play Store aktualisieren oder eine neue Bewertung hinterlassen?';

  @override
  String get alreadyRatedHint =>
      'Ihre Meinung hilft uns, die App kontinuierlich zu verbessern.';

  @override
  String get goToPlayStore => 'Zum Play Store';

  @override
  String get updateRating => 'Bewertung aktualisieren';

  @override
  String get contactWhatsAppLabel => 'WhatsApp-Support';

  @override
  String whatsappNotAvailable(Object phone) {
    return 'WhatsApp nicht verfügbar. Nummer kopiert: $phone';
  }

  @override
  String get whatsappError => 'Fehler beim Öffnen von WhatsApp';

  @override
  String get refPriceMenuTitle => 'Referenzpreis & Wechselkurs';

  @override
  String get refPriceDialogTitle => 'Referenzpreis für Produkte';

  @override
  String get refPriceDialogDesc =>
      'Gib deine Produktpreise in einer Referenzwährung ein (z. B. USD). Das System rechnet sie automatisch um und zeigt sie deinen Kunden in der lokalen Währung an – basierend auf dem von dir festgelegten Wechselkurs.';

  @override
  String get refPriceEnable => 'Referenzpreis aktivieren';

  @override
  String get refCurrencyLabel => 'Referenzwährung (für die Eingabe)';

  @override
  String get refRateLabel => 'Wechselkurs';

  @override
  String refPriceExample(Object base, Object finalPrice, Object localCurrency) {
    return 'Beispiel: Wenn du den Preis eines Produkts in $base eingibst, sieht der Kunde ihn als: $finalPrice $localCurrency';
  }

  @override
  String refPriceHelperText(String finalPrice, String localCurrency) {
    return 'für den Kunden: $finalPrice $localCurrency';
  }

  @override
  String get refCurrencyHiddenHint =>
      'Die Referenzwährung ist in Ihrem Shop nicht sichtbar. Sie dient ausschließlich als interne Basis für Ihre Preisberechnungen.';

  @override
  String get currencyUsd => '\$  US-Dollar';

  @override
  String get currencyEur => '€  Euro';

  @override
  String get currencyTry => '₺  Türkische Lira';

  @override
  String get currencyLabelSYP => 'ل.س  Syrisches Pfund (SYP)';

  @override
  String get currencyLabelAED => 'د.إ  VAE-Dirham (AED)';

  @override
  String get currencyLabelBHD => 'د.ب  Bahrain-Dinar (BHD)';

  @override
  String get currencyLabelDZD => 'د.ج  Algerischer Dinar (DZD)';

  @override
  String get currencyLabelEGP => 'ج.م  Ägyptisches Pfund (EGP)';

  @override
  String get currencyLabelIQD => 'ع.د  Irakischer Dinar (IQD)';

  @override
  String get currencyLabelJOD => 'د.أ  Jordanischer Dinar (JOD)';

  @override
  String get currencyLabelKWD => 'د.ك  Kuwait-Dinar (KWD)';

  @override
  String get currencyLabelLBP => 'ل.ل  Libanesisches Pfund (LBP)';

  @override
  String get currencyLabelLYD => 'د.ل  Libyscher Dinar (LYD)';

  @override
  String get currencyLabelMAD => 'د.م.  Marokkanischer Dirham (MAD)';

  @override
  String get currencyLabelOMR => 'ر.ع.  Omanischer Rial (OMR)';

  @override
  String get currencyLabelQAR => 'ر.ق  Katar-Riyal (QAR)';

  @override
  String get currencyLabelSAR => '﷼  Saudi-Rial (SAR)';

  @override
  String get currencyLabelSDG => 'ج.س  Sudanesisches Pfund (SDG)';

  @override
  String get currencyLabelDJF => 'Fdj  Dschibuti-Franc (DJF)';

  @override
  String get currencyLabelTND => 'د.ت  Tunesischer Dinar (TND)';

  @override
  String get currencyLabelYER => 'ر.ي  Jemen-Rial (YER)';

  @override
  String get currencyLabelMRU => 'UM  Mauretanischer Ouguiya (MRU)';

  @override
  String get currencyLabelSOS => 'Sh  Somalia-Schilling (SOS)';

  @override
  String get currencyLabelKMF => 'CF  Komoren-Franc (KMF)';

  @override
  String get currencyLabelAUD => 'A\$  Australischer Dollar (AUD)';

  @override
  String get currencyLabelBRL => 'R\$  Brasilianischer Real (BRL)';

  @override
  String get currencyLabelCAD => 'C\$  Kanadischer Dollar (CAD)';

  @override
  String get currencyLabelCHF => 'CHF  Schweizer Franken (CHF)';

  @override
  String get currencyLabelCNY => '¥  Renminbi Yuan (CNY)';

  @override
  String get currencyLabelEUR => '€  Euro (EUR)';

  @override
  String get currencyLabelGBP => '£  Britisches Pfund (GBP)';

  @override
  String get currencyLabelJPY => '¥  Japanischer Yen (JPY)';

  @override
  String get currencyLabelRUB => '₽  Russischer Rubel (RUB)';

  @override
  String get currencyLabelSEK => 'kr  Schwedische Krone (SEK)';

  @override
  String get currencyLabelTRY => '₺  Türkische Lira (TRY)';

  @override
  String get currencyLabelUSD => '\$  US-Dollar (USD)';

  @override
  String get customTemplateNewTitle => 'Neue Vorlage';

  @override
  String get customTemplateEditTitle => 'Vorlage bearbeiten';

  @override
  String get customTemplateTitleHint => 'Titel (z.B. Wochenend-Sale)';

  @override
  String get customTemplateMessageHint => 'Nachricht';

  @override
  String get customTemplateDefaultTab => 'Standard';

  @override
  String get customTemplateMyTab => 'Meine Vorlagen';

  @override
  String get customTemplateCreateNew => 'Neu erstellen';

  @override
  String get customTemplateEmpty =>
      'Du hast noch keine eigenen Vorlagen erstellt.';

  @override
  String get stopCategoryOffersConfirmTitle => 'Angebote beenden?';

  @override
  String get stopCategoryOffersConfirmMessage =>
      'Willst du wirklich alle Angebote für diese Kategorie ausschalten?';

  @override
  String get stopCategoryOffersConfirmYes => 'Ja, ausschalten';

  @override
  String get stopCategoryOffersConfirmNo => 'Nein, abbrechen';

  @override
  String get activeOffersBadge => 'Aktive Angebote';

  @override
  String get addressPrecisionHint =>
      'Der exakte Standort wird über die Karte gespeichert, auch wenn die Adresse ungenau erscheint.';

  @override
  String get logoUploading => 'Wird hochgeladen…';

  @override
  String get logoProcessing => 'Wird verarbeitet…';

  @override
  String get logoDeleting => 'Wird gelöscht…';

  @override
  String get logoUpdatedToast => 'Logo aktualisiert';

  @override
  String get logoDeletedToast => 'Logo gelöscht';

  @override
  String get deleteLogoTitle => 'Logo löschen';

  @override
  String get productPolicyEmailSubject => 'Produktprüfung';

  @override
  String get productPolicyEmailBodyIntro =>
      'Ich glaube, diese Sperre ist ein Fehler.';

  @override
  String contactEmailLine(Object email) {
    return 'E-Mail: $email';
  }

  @override
  String get contactEmailCopied => 'E-Mail-Adresse kopiert';

  @override
  String get drawerAnalytics => 'Shop-Statistik';

  @override
  String get analyticsTitle => 'Statistik';

  @override
  String get analyticsRange7 => 'Letzte 7 Tage';

  @override
  String get analyticsRange30 => 'Letzte 30 Tage';

  @override
  String get analyticsRange90 => 'Letzte 90 Tage';

  @override
  String get analyticsEmpty => 'Noch keine Statistik verfügbar.';

  @override
  String get analyticsCardVisits => 'Besuche';

  @override
  String get analyticsCardWhatsapp => 'WhatsApp-Klicks';

  @override
  String get analyticsCardProductViews => 'Produktaufrufe';

  @override
  String get analyticsCardAddToCart => 'In den Warenkorb';

  @override
  String get analyticsCardCheckout => 'Checkout-Interesse';

  @override
  String get analyticsChartVisits => 'Besuche pro Tag';

  @override
  String get analyticsChartWhatsapp => 'WhatsApp-Klicks pro Tag';

  @override
  String get analyticsTableTitle => 'Letzte Tage';

  @override
  String get refreshButton => 'Aktualisieren';

  @override
  String get analyticsFilterTitle => 'Filter';

  @override
  String get analyticsFilterFrom => 'Von';

  @override
  String get analyticsFilterTo => 'Bis';

  @override
  String get analyticsPeakTitle => 'Höchster Tag';

  @override
  String get analyticsAxisDays => 'Tage';

  @override
  String get analyticsAxisCount => 'Anzahl';

  @override
  String get analyticsMonthLabel => 'Monat';

  @override
  String get month01 => 'Januar';

  @override
  String get month02 => 'Februar';

  @override
  String get month03 => 'März';

  @override
  String get month04 => 'April';

  @override
  String get month05 => 'Mai';

  @override
  String get month06 => 'Juni';

  @override
  String get month07 => 'Juli';

  @override
  String get month08 => 'August';

  @override
  String get month09 => 'September';

  @override
  String get month10 => 'Oktober';

  @override
  String get month11 => 'November';

  @override
  String get month12 => 'Dezember';

  @override
  String get installAppAppleTitle => 'App installieren (iOS)';

  @override
  String get installAppAppleStep1 =>
      '1. Tippe unten im Safari auf das Teilen-Symbol (Viereck mit Pfeil).';

  @override
  String get installAppAppleStep2 =>
      '2. Scrolle nach unten und wähle \'Zum Home-Bildschirm\'.';

  @override
  String get installAppAppleStep3 =>
      '3. Bestätige oben rechts mit \'Hinzufügen\'.';

  @override
  String get gotItButton => 'Verstanden';

  @override
  String analyticsPeakVisits(int count) {
    return '$count Besuche';
  }

  @override
  String analyticsPeakWhatsapp(int count) {
    return '$count Klicks';
  }

  @override
  String get activeFilters => 'Filter aktiv';
}
