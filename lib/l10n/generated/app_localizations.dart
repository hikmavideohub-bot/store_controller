import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please verify again.'**
  String get sessionExpired;

  /// No description provided for @noStore.
  ///
  /// In en, this message translates to:
  /// **'Account not registered. Please create a store.'**
  String get noStore;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @contactAndAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & Address'**
  String get contactAndAddressTitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number*'**
  String get phoneNumberLabel;

  /// No description provided for @whatsappSameAsPhone.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp same as phone number'**
  String get whatsappSameAsPhone;

  /// No description provided for @whatsappNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number*'**
  String get whatsappNumberLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, District, City...'**
  String get addressHint;

  /// No description provided for @useCurrentLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocationTooltip;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Login Email'**
  String get loginEmailLabel;

  /// No description provided for @googleAuthInfo.
  ///
  /// In en, this message translates to:
  /// **'You are signed in via Google. You can set a password to enable direct email login.'**
  String get googleAuthInfo;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get passwordResetSent;

  /// No description provided for @sendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingStatus;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send password reset link'**
  String get sendResetLinkButton;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// No description provided for @storeFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Your Store'**
  String get storeFallbackName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email specified'**
  String get noEmail;

  /// No description provided for @statusTrialDays.
  ///
  /// In en, this message translates to:
  /// **'Trial • {days} days'**
  String statusTrialDays(Object days);

  /// No description provided for @statusTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get statusTrial;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @shippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get shippingTitle;

  /// No description provided for @shippingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Delivery Available'**
  String get shippingEnabled;

  /// No description provided for @shippingEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable delivery service for customers'**
  String get shippingEnabledSubtitle;

  /// No description provided for @shippingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Cost'**
  String get shippingCostLabel;

  /// No description provided for @shippingCostHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get shippingCostHint;

  /// No description provided for @socialLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links & Social'**
  String get socialLinksTitle;

  /// No description provided for @socialTiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get socialTiktok;

  /// No description provided for @socialInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get socialInstagram;

  /// No description provided for @socialFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get socialFacebook;

  /// No description provided for @supportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get supportEmailLabel;

  /// No description provided for @supportEmailHint.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get supportEmailHint;

  /// No description provided for @storeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeInfoTitle;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// No description provided for @storeDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get storeDescLabel;

  /// No description provided for @storeDescHint.
  ///
  /// In en, this message translates to:
  /// **'High quality and reasonable prices'**
  String get storeDescHint;

  /// No description provided for @storeDescHelper.
  ///
  /// In en, this message translates to:
  /// **'This description appears below the store name on the home page.'**
  String get storeDescHelper;

  /// No description provided for @createdAtDate.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdAtDate(Object date);

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Currency*'**
  String get currencyLabel;

  /// No description provided for @workingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHoursTitle;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @appearanceSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize app appearance'**
  String get appearanceSectionSubtitle;

  /// No description provided for @storeInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Info'**
  String get storeInfoSectionTitle;

  /// No description provided for @storeInfoSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, Currency, Description'**
  String get storeInfoSectionSubtitle;

  /// No description provided for @contactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactSectionTitle;

  /// No description provided for @contactSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Phone, Address, Social Links'**
  String get contactSectionSubtitle;

  /// No description provided for @otherSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettingsSectionTitle;

  /// No description provided for @otherSettingsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours, Delivery, Security'**
  String get otherSettingsSectionSubtitle;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @savingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutButton;

  /// No description provided for @saveSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get saveSuccessMsg;

  /// No description provided for @saveErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get saveErrorMsg;

  /// No description provided for @setupStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Setup'**
  String get setupStoreTitle;

  /// No description provided for @stepIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get stepIdentity;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get stepContact;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get stepDelivery;

  /// No description provided for @stepHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get stepHours;

  /// No description provided for @stepFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get stepFinish;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with basics'**
  String get step1Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a name and logo for your store'**
  String get step1Subtitle;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'How to contact you?'**
  String get step2Title;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number and address for customers'**
  String get step2Subtitle;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Delivery Service'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Do you provide delivery for your customers?'**
  String get step3Subtitle;

  /// No description provided for @enableDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable Delivery'**
  String get enableDeliveryLabel;

  /// No description provided for @deliveryEnabled.
  ///
  /// In en, this message translates to:
  /// **'Service Enabled'**
  String get deliveryEnabled;

  /// No description provided for @deliveryDisabled.
  ///
  /// In en, this message translates to:
  /// **'Service Disabled'**
  String get deliveryDisabled;

  /// No description provided for @fixedDeliveryPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed Delivery Price'**
  String get fixedDeliveryPriceLabel;

  /// No description provided for @deliveryPriceHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to set price later per order'**
  String get deliveryPriceHelper;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'When is your store open?'**
  String get step4Title;

  /// No description provided for @step4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can skip this step and add it later'**
  String get step4Subtitle;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have completed your store setup.'**
  String get step5Title;

  /// No description provided for @step5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'You have completed your store setup. You can edit it later in your profile.'**
  String get step5Subtitle;

  /// No description provided for @step5SubtitleWeb.
  ///
  /// In en, this message translates to:
  /// **'For iPhone users: Tap the Share button and select \'Add to Home Screen\' for a better experience.'**
  String get step5SubtitleWeb;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Store Description (Optional)'**
  String get shortDescriptionLabel;

  /// No description provided for @optionalBadge.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalBadge;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @finishSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetupButton;

  /// No description provided for @validationEnterStoreName.
  ///
  /// In en, this message translates to:
  /// **'Please enter store name'**
  String get validationEnterStoreName;

  /// No description provided for @validationEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get validationEnterPhone;

  /// No description provided for @logoutConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMsg;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmButton;

  /// No description provided for @locationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching location: {error}'**
  String locationFetchError(Object error);

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFieldsError;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short (min. 6 characters)'**
  String get passwordTooShort;

  /// No description provided for @generalError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String generalError(Object error);

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get storeNameRequired;

  /// No description provided for @noEditPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to edit'**
  String get noEditPermission;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @newCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNewCategory;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descQuality.
  ///
  /// In en, this message translates to:
  /// **'High quality & great taste'**
  String get descQuality;

  /// No description provided for @descFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh & Daily'**
  String get descFresh;

  /// No description provided for @descBestseller.
  ///
  /// In en, this message translates to:
  /// **'Our Bestseller'**
  String get descBestseller;

  /// No description provided for @descLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited Offer'**
  String get descLimited;

  /// No description provided for @descHandmade.
  ///
  /// In en, this message translates to:
  /// **'Luxury Handmade'**
  String get descHandmade;

  /// No description provided for @descNatural.
  ///
  /// In en, this message translates to:
  /// **'100% Natural'**
  String get descNatural;

  /// No description provided for @productAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product Available'**
  String get productAvailable;

  /// No description provided for @visibleToCustomers.
  ///
  /// In en, this message translates to:
  /// **'Visible to customers'**
  String get visibleToCustomers;

  /// No description provided for @hiddenFromCustomers.
  ///
  /// In en, this message translates to:
  /// **'Hidden from customers'**
  String get hiddenFromCustomers;

  /// No description provided for @specialOfferAvailable.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOfferAvailable;

  /// No description provided for @specialOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable discounts or wholesale offers'**
  String get specialOfferSubtitle;

  /// No description provided for @offerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Type'**
  String get offerTypeLabel;

  /// No description provided for @offerTypePercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage %'**
  String get offerTypePercent;

  /// No description provided for @offerTypeBundle.
  ///
  /// In en, this message translates to:
  /// **'Bundle Offer'**
  String get offerTypeBundle;

  /// No description provided for @offerTypeBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk/Tiered Price'**
  String get offerTypeBulk;

  /// No description provided for @percentageLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get percentageLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @totalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPriceLabel;

  /// No description provided for @quantityStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (from)'**
  String get quantityStartLabel;

  /// No description provided for @pricePerPieceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per piece'**
  String get pricePerPieceLabel;

  /// No description provided for @offerDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Duration'**
  String get offerDurationLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @productPublishedMsg.
  ///
  /// In en, this message translates to:
  /// **'Product published'**
  String get productPublishedMsg;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @errorStatus.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorStatus;

  /// No description provided for @productImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImageLabel;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get tapToUpload;

  /// No description provided for @optionalSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optionalSuffix;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitL;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitPcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPcs;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMsg.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{name}\"? Products will be moved to \"Others\".'**
  String deleteCategoryMsg(Object name);

  /// No description provided for @categoriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get categoriesLoadError;

  /// No description provided for @categoryRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryRenameTitle;

  /// No description provided for @categoryRenameLabel.
  ///
  /// In en, this message translates to:
  /// **'New Category Name'**
  String get categoryRenameLabel;

  /// No description provided for @categoryRenameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category renamed successfully'**
  String get categoryRenameSuccess;

  /// No description provided for @categoryRenameFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename category'**
  String get categoryRenameFail;

  /// No description provided for @categoryRenameError.
  ///
  /// In en, this message translates to:
  /// **'Error renaming category'**
  String get categoryRenameError;

  /// No description provided for @deleteCategoryConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'All products will be moved from \"{name}\" to \"{moveTo}\". Are you sure?'**
  String deleteCategoryConfirmMsg(Object moveTo, Object name);

  /// No description provided for @categoryDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeleteSuccess;

  /// No description provided for @categoryDeleteFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category'**
  String get categoryDeleteFail;

  /// No description provided for @categoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting category'**
  String get categoryDeleteError;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Products'**
  String productsCount(Object count);

  /// No description provided for @viewProductsAction.
  ///
  /// In en, this message translates to:
  /// **'View Products'**
  String get viewProductsAction;

  /// No description provided for @viewProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open product list for this category'**
  String get viewProductsSubtitle;

  /// No description provided for @applyCategoryOfferAction.
  ///
  /// In en, this message translates to:
  /// **'Apply Offer to Category'**
  String get applyCategoryOfferAction;

  /// No description provided for @applyCategoryOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage discount for all products'**
  String get applyCategoryOfferSubtitle;

  /// No description provided for @stopCategoryOffersAction.
  ///
  /// In en, this message translates to:
  /// **'Stop Category Offers'**
  String get stopCategoryOffersAction;

  /// No description provided for @stopCategoryOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable all offers in this category'**
  String get stopCategoryOffersSubtitle;

  /// No description provided for @categoryFullOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Category Offer'**
  String get categoryFullOfferTitle;

  /// No description provided for @applyToCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to \"{category}\"'**
  String applyToCategorySubtitle(Object category);

  /// No description provided for @percentageHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 15'**
  String get percentageHint;

  /// No description provided for @offerValidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Validity'**
  String get offerValidityLabel;

  /// No description provided for @invalidPercentageError.
  ///
  /// In en, this message translates to:
  /// **'Enter valid percentage'**
  String get invalidPercentageError;

  /// No description provided for @applyOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Offer'**
  String get applyOfferButton;

  /// No description provided for @categoryOfferAppliedMsg.
  ///
  /// In en, this message translates to:
  /// **'Offer applied to category \"{category}\"'**
  String categoryOfferAppliedMsg(Object category);

  /// No description provided for @categoryOfferApplyFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply offer'**
  String get categoryOfferApplyFail;

  /// No description provided for @categoryOffersDisabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Offers stopped for category \"{category}\"'**
  String categoryOffersDisabledMsg(Object category);

  /// No description provided for @categoryOffersDisableFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop offers'**
  String get categoryOffersDisableFail;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Categories'**
  String categoriesCountLabel(Object count);

  /// No description provided for @noCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesTitle;

  /// No description provided for @noCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add new categories to organize your products'**
  String get noCategoriesSubtitle;

  /// No description provided for @offerUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String offerUntilDate(Object date);

  /// No description provided for @discountPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Discount'**
  String discountPercent(Object percent);

  /// No description provided for @bundleOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'{qty} for {price} {currency}'**
  String bundleOfferLabel(Object currency, Object price, Object qty);

  /// No description provided for @offerLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerLabel;

  /// No description provided for @availableStatus.
  ///
  /// In en, this message translates to:
  /// **' Available'**
  String get availableStatus;

  /// No description provided for @unavailableStatus.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailableStatus;

  /// No description provided for @updateFail.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFail;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{name}\"?'**
  String deleteProductConfirmMsg(Object name);

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @deleteFail.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFail;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @customerMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Message'**
  String get customerMessageTitle;

  /// No description provided for @templateDiscountTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Discount'**
  String get templateDiscountTitle;

  /// No description provided for @templateDiscountText.
  ///
  /// In en, this message translates to:
  /// **'🔥 Special 20% discount on all products for a limited time! Don\'t miss out.'**
  String get templateDiscountText;

  /// No description provided for @templateWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get templateWelcomeTitle;

  /// No description provided for @templateWelcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our store! We wish you a happy and enjoyable shopping experience. ✨'**
  String get templateWelcomeText;

  /// No description provided for @templateNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get templateNewTitle;

  /// No description provided for @templateNewText.
  ///
  /// In en, this message translates to:
  /// **'A new and distinctive collection has arrived! Browse the latest products in the store now. 🆕'**
  String get templateNewText;

  /// No description provided for @templateDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get templateDeliveryTitle;

  /// No description provided for @templateDeliveryText.
  ///
  /// In en, this message translates to:
  /// **'Shop now and get free delivery on all orders over 50 Euro! 🚚'**
  String get templateDeliveryText;

  /// No description provided for @templateOccasionTitle.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get templateOccasionTitle;

  /// No description provided for @templateOccasionText.
  ///
  /// In en, this message translates to:
  /// **'Happy Holidays! Enjoy our exclusive offers. 🌙'**
  String get templateOccasionText;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get loadDataError;

  /// No description provided for @messagePublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message published successfully ✅'**
  String get messagePublishedSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed, please try again'**
  String get saveFailed;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted 🗑'**
  String get messageDeleted;

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessageTitle;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the message? It will no longer appear to customers.'**
  String get deleteMessageConfirm;

  /// No description provided for @chooseTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get chooseTemplateTitle;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Preview'**
  String get previewTitle;

  /// No description provided for @editMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessageTitle;

  /// No description provided for @templatesButton.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesButton;

  /// No description provided for @displayDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Display Duration'**
  String get displayDurationTitle;

  /// No description provided for @previewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your message will appear here...'**
  String get previewPlaceholder;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 20% discount on all products 🌙'**
  String get messageHint;

  /// No description provided for @engageTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter engaging text to increase sales'**
  String get engageTextHint;

  /// No description provided for @durationAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get durationAlways;

  /// No description provided for @durationDay.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get durationDay;

  /// No description provided for @duration3Days.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get duration3Days;

  /// No description provided for @durationWeek.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get durationWeek;

  /// No description provided for @durationMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get durationMonth;

  /// No description provided for @saveAndPublishButton.
  ///
  /// In en, this message translates to:
  /// **'Save and Publish'**
  String get saveAndPublishButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @restorePasswordHeadline.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get restorePasswordHeadline;

  /// No description provided for @restorePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we will send you a link to set a new password.'**
  String get restorePasswordDesc;

  /// No description provided for @enterEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get enterEmailValidation;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @resetLinkSentMsg.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email.'**
  String get resetLinkSentMsg;

  /// No description provided for @emailNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is not registered.'**
  String get emailNotRegistered;

  /// No description provided for @generalSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send now. Please check the email address.'**
  String get generalSendError;

  /// No description provided for @sendLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLinkButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @welcomeStoreName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {storeName}'**
  String welcomeStoreName(Object storeName);

  /// No description provided for @validationEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter the store address'**
  String get validationEnterAddress;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is a quick summary of your store today'**
  String get dashboardSubtitle;

  /// No description provided for @publicStoreLink.
  ///
  /// In en, this message translates to:
  /// **'Public Store Link'**
  String get publicStoreLink;

  /// No description provided for @noLinkYet.
  ///
  /// In en, this message translates to:
  /// **'No link yet'**
  String get noLinkYet;

  /// No description provided for @copyLinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get copyLinkSuccess;

  /// No description provided for @shareStoreInvite.
  ///
  /// In en, this message translates to:
  /// **'Share Store Invite'**
  String get shareStoreInvite;

  /// No description provided for @customerMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No message set yet. Tap to add.'**
  String get customerMessagePlaceholder;

  /// No description provided for @liveStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Statistics'**
  String get liveStatsTitle;

  /// No description provided for @statsTotalProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get statsTotalProducts;

  /// No description provided for @statsAvailable.
  ///
  /// In en, this message translates to:
  /// **' Available'**
  String get statsAvailable;

  /// No description provided for @statsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get statsUnavailable;

  /// No description provided for @statsOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get statsOffers;

  /// No description provided for @statsCategoryOffers.
  ///
  /// In en, this message translates to:
  /// **'Cat. Offers'**
  String get statsCategoryOffers;

  /// No description provided for @statsNoImage.
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get statsNoImage;

  /// No description provided for @statsLargestCategory.
  ///
  /// In en, this message translates to:
  /// **'Largest Cat.'**
  String get statsLargestCategory;

  /// No description provided for @filterAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get filterAllProducts;

  /// No description provided for @filterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available Products'**
  String get filterAvailable;

  /// No description provided for @filterUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable Products'**
  String get filterUnavailable;

  /// No description provided for @filterActiveOffers.
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get filterActiveOffers;

  /// No description provided for @filterNoImage.
  ///
  /// In en, this message translates to:
  /// **'Products without Image'**
  String get filterNoImage;

  /// No description provided for @filterCategoryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String filterCategoryPrefix(Object category);

  /// No description provided for @noProductsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No products: {title}'**
  String noProductsFoundTitle(Object title);

  /// No description provided for @categoryOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Category Offers'**
  String get categoryOffersTitle;

  /// No description provided for @categoryOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories where all products are on offer'**
  String get categoryOffersSubtitle;

  /// No description provided for @noCategoryOffers.
  ///
  /// In en, this message translates to:
  /// **'No categories with full offers'**
  String get noCategoryOffers;

  /// No description provided for @stopOfferAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopOfferAction;

  /// No description provided for @stopCategoryOfferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category offers stopped'**
  String get stopCategoryOfferSuccess;

  /// No description provided for @stopCategoryOfferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All offer types in this category will be stopped.'**
  String get stopCategoryOfferConfirm;

  /// No description provided for @expirationAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiration Alert'**
  String get expirationAlertTitle;

  /// No description provided for @expirationAlertMsg.
  ///
  /// In en, this message translates to:
  /// **'Hello! Your store subscription will expire in {days} days. Please renew now to ensure uninterrupted service.'**
  String expirationAlertMsg(Object days);

  /// No description provided for @renewNowButton.
  ///
  /// In en, this message translates to:
  /// **'Renew Now'**
  String get renewNowButton;

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get navStore;

  /// No description provided for @activateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your account details to access your store'**
  String get loginSubtitle;

  /// No description provided for @loginEmailOrPassError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get loginEmailOrPassError;

  /// No description provided for @noStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'No Store Found'**
  String get noStoreTitle;

  /// No description provided for @noStoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a new store using this account?'**
  String get noStoreMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createStore.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get createStore;

  /// No description provided for @loginNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get loginNoPermission;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleLoginFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @googleSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get googleSigningIn;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @createNewStore.
  ///
  /// In en, this message translates to:
  /// **'Create new store'**
  String get createNewStore;

  /// No description provided for @activationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Activation Successful!'**
  String get activationSuccessTitle;

  /// No description provided for @activationSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your store has been activated successfully.'**
  String get activationSuccessMsg;

  /// No description provided for @startNowButton.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNowButton;

  /// No description provided for @loadingErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get loadingErrorPrefix;

  /// No description provided for @choosePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get choosePlanTitle;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available at the moment'**
  String get noPlansAvailable;

  /// No description provided for @choosePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the subscription plan that suits you'**
  String get choosePlanSubtitle;

  /// No description provided for @savePercentage.
  ///
  /// In en, this message translates to:
  /// **'Save 20%'**
  String get savePercentage;

  /// No description provided for @paymentLinkError.
  ///
  /// In en, this message translates to:
  /// **'Server did not return a payment link'**
  String get paymentLinkError;

  /// No description provided for @paymentPrepError.
  ///
  /// In en, this message translates to:
  /// **'Error preparing payment. Please try again later.'**
  String get paymentPrepError;

  /// No description provided for @payAndActivate.
  ///
  /// In en, this message translates to:
  /// **'Pay {price} & Activate'**
  String payAndActivate(Object price);

  /// No description provided for @featureUnlimitedProducts.
  ///
  /// In en, this message translates to:
  /// **'Extensive Inventory (up to 400 products)'**
  String get featureUnlimitedProducts;

  /// No description provided for @featurePremiumSupport.
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get featurePremiumSupport;

  /// No description provided for @featureAdvancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced Statistics'**
  String get featureAdvancedStats;

  /// No description provided for @featureNoCommission.
  ///
  /// In en, this message translates to:
  /// **'No Sales Commission'**
  String get featureNoCommission;

  /// No description provided for @paymentAndActivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment & Activation'**
  String get paymentAndActivationTitle;

  /// No description provided for @adminContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation Manager'**
  String get adminContactLabel;

  /// No description provided for @step1ChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'1. Choose Plan:'**
  String get step1ChoosePlan;

  /// No description provided for @step2PaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'2. Payment Details (Transfer here):'**
  String get step2PaymentDetails;

  /// No description provided for @qrCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'QR Code Photo'**
  String get qrCodePlaceholder;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number / ID'**
  String get accountNumberLabel;

  /// No description provided for @copyIdSuccess.
  ///
  /// In en, this message translates to:
  /// **'ID Copied'**
  String get copyIdSuccess;

  /// No description provided for @sendActivationInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Send Activation Info'**
  String get sendActivationInfoButton;

  /// No description provided for @afterPaymentInstruction.
  ///
  /// In en, this message translates to:
  /// **'After payment, tap the button to send your store name and ID automatically.'**
  String get afterPaymentInstruction;

  /// No description provided for @sharePaymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Send payment confirmation via'**
  String get sharePaymentConfirmTitle;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @telegramLabel.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegramLabel;

  /// No description provided for @telegramCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Message copied! Paste it in the chat.'**
  String get telegramCopySuccess;

  /// No description provided for @paymentMessageBody.
  ///
  /// In en, this message translates to:
  /// **'Hello, I have transferred the amount to activate the store.\nPlease activate:\n\n🏪 *Store:* {storeName}\n🆔 *ID:* {storeId}\n📅 *Plan:* {planName} ({price})\n\nThank you!'**
  String paymentMessageBody(
    Object planName,
    Object price,
    Object storeId,
    Object storeName,
  );

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

  /// No description provided for @productsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get productsLoadError;

  /// No description provided for @productUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdateSuccess;

  /// No description provided for @productUpdateStatusFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product status'**
  String get productUpdateStatusFail;

  /// No description provided for @offerUpdateFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update offer'**
  String get offerUpdateFail;

  /// No description provided for @productDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleteSuccess;

  /// No description provided for @productDeleteFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get productDeleteFail;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApply;

  /// No description provided for @stockStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get stockStatusLabel;

  /// No description provided for @offersLabel.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWithOffer.
  ///
  /// In en, this message translates to:
  /// **'With Offer'**
  String get filterWithOffer;

  /// No description provided for @filterWithoutOffer.
  ///
  /// In en, this message translates to:
  /// **'Without Offer'**
  String get filterWithoutOffer;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Available / Active'**
  String get filterActive;

  /// No description provided for @filterInactive.
  ///
  /// In en, this message translates to:
  /// **'Unavailable / Inactive'**
  String get filterInactive;

  /// No description provided for @disableProduct.
  ///
  /// In en, this message translates to:
  /// **'Disable Product'**
  String get disableProduct;

  /// No description provided for @enableProduct.
  ///
  /// In en, this message translates to:
  /// **'Enable Product'**
  String get enableProduct;

  /// No description provided for @disableOffer.
  ///
  /// In en, this message translates to:
  /// **'Disable Offer'**
  String get disableOffer;

  /// No description provided for @enableOffer.
  ///
  /// In en, this message translates to:
  /// **'Enable Offer'**
  String get enableOffer;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @noStoreFound.
  ///
  /// In en, this message translates to:
  /// **'No store found'**
  String get noStoreFound;

  /// No description provided for @noStoreMsg.
  ///
  /// In en, this message translates to:
  /// **'App data might be missing.\nPlease log in or setup the store again.'**
  String get noStoreMsg;

  /// No description provided for @setupStoreButton.
  ///
  /// In en, this message translates to:
  /// **'Setup Store'**
  String get setupStoreButton;

  /// No description provided for @reloginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in again'**
  String get reloginButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get registerTitle;

  /// No description provided for @completeStoreCreation.
  ///
  /// In en, this message translates to:
  /// **'Complete Store Creation'**
  String get completeStoreCreation;

  /// No description provided for @enterStoreNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter store name to complete registration'**
  String get enterStoreNamePrompt;

  /// No description provided for @googleAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get googleAccountLabel;

  /// No description provided for @trialPeriodInfo.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get trialPeriodInfo;

  /// No description provided for @createStoreButton.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get createStoreButton;

  /// No description provided for @cancelAndReturnToLogin.
  ///
  /// In en, this message translates to:
  /// **'Cancel and return to login'**
  String get cancelAndReturnToLogin;

  /// No description provided for @registerNewStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Store'**
  String get registerNewStoreTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your store and get a free trial'**
  String get registerSubtitle;

  /// No description provided for @googleRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get googleRegisterButton;

  /// No description provided for @googleRegistering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get googleRegistering;

  /// No description provided for @storeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Al-Aseel Store'**
  String get storeNameHint;

  /// No description provided for @storeNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Store name is too short (min. 3 chars)'**
  String get storeNameTooShort;

  /// No description provided for @requireEmailVerifyLabel.
  ///
  /// In en, this message translates to:
  /// **'Require email verification from customers'**
  String get requireEmailVerifyLabel;

  /// No description provided for @requireEmailVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'New customers need to verify their email'**
  String get requireEmailVerifySubtitle;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginLink;

  /// No description provided for @registerFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account. Please try again.'**
  String get registerFailedMsg;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetLinkSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSentTitle;

  /// No description provided for @checkEmailForResetMsg.
  ///
  /// In en, this message translates to:
  /// **'Please check your email ({username}) and follow the link to change your password.'**
  String checkEmailForResetMsg(Object username);

  /// No description provided for @backToLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLoginButton;

  /// No description provided for @subscriptionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionInfoTitle;

  /// No description provided for @activePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Premium Subscription'**
  String get activePremiumTitle;

  /// No description provided for @activePremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your store is fully operational without restrictions'**
  String get activePremiumSubtitle;

  /// No description provided for @trialPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial Period'**
  String get trialPeriodTitle;

  /// No description provided for @trialRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining in trial'**
  String trialRemaining(Object days);

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Period'**
  String get freeTrial;

  /// No description provided for @subscriptionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get subscriptionExpiredTitle;

  /// No description provided for @subscriptionExpiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store features are temporarily suspended'**
  String get subscriptionExpiredSubtitle;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Please contact support'**
  String get contactSupport;

  /// No description provided for @planDetailsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Details & Dates'**
  String get planDetailsCardTitle;

  /// No description provided for @storeLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeLabel;

  /// No description provided for @subscriptionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscription Type'**
  String get subscriptionTypeLabel;

  /// No description provided for @premiumYearly.
  ///
  /// In en, this message translates to:
  /// **'Premium (Yearly)'**
  String get premiumYearly;

  /// No description provided for @trialFree.
  ///
  /// In en, this message translates to:
  /// **'Trial / Free'**
  String get trialFree;

  /// No description provided for @creationDate.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get creationDate;

  /// No description provided for @activatedAt.
  ///
  /// In en, this message translates to:
  /// **'Activated At'**
  String get activatedAt;

  /// No description provided for @subscriptionEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Subscription Ends At'**
  String get subscriptionEndsAt;

  /// No description provided for @trialStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Trial Started At'**
  String get trialStartedAt;

  /// No description provided for @trialEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Trial Ends At'**
  String get trialEndsAt;

  /// No description provided for @subscriptionEndedAt.
  ///
  /// In en, this message translates to:
  /// **'Subscription Ended At'**
  String get subscriptionEndedAt;

  /// No description provided for @trialEndedAt.
  ///
  /// In en, this message translates to:
  /// **'Trial Ended At'**
  String get trialEndedAt;

  /// No description provided for @currentBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Subscription Benefits'**
  String get currentBenefitsTitle;

  /// No description provided for @benefitUnlimitedProducts.
  ///
  /// In en, this message translates to:
  /// **'Add and manage unlimited products'**
  String get benefitUnlimitedProducts;

  /// No description provided for @benefitHighQualityImages.
  ///
  /// In en, this message translates to:
  /// **'High-quality image display for customers'**
  String get benefitHighQualityImages;

  /// No description provided for @benefitShowPrices.
  ///
  /// In en, this message translates to:
  /// **'Prices and sizes visible on website'**
  String get benefitShowPrices;

  /// No description provided for @benefitFullControl.
  ///
  /// In en, this message translates to:
  /// **'Full control over store settings'**
  String get benefitFullControl;

  /// No description provided for @benefitDirectSupport.
  ///
  /// In en, this message translates to:
  /// **'Direct and fast support'**
  String get benefitDirectSupport;

  /// No description provided for @restrictionStagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Restriction Stages'**
  String get restrictionStagesTitle;

  /// No description provided for @restrictionStage1.
  ///
  /// In en, this message translates to:
  /// **'Hide product images from public store'**
  String get restrictionStage1;

  /// No description provided for @restrictionStage2.
  ///
  /// In en, this message translates to:
  /// **'Hide prices, sizes, and contact info'**
  String get restrictionStage2;

  /// No description provided for @restrictionStage3.
  ///
  /// In en, this message translates to:
  /// **'Full suspension of dashboard and store'**
  String get restrictionStage3;

  /// No description provided for @renewSubscriptionButton.
  ///
  /// In en, this message translates to:
  /// **'Renew Subscription Now'**
  String get renewSubscriptionButton;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutTooltip;

  /// No description provided for @checkYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmailTitle;

  /// No description provided for @sentLinkTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to:'**
  String get sentLinkTo;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open your email and click the confirmation link.\nYou will be redirected automatically after verification.'**
  String get verifyEmailInstructions;

  /// No description provided for @checkNowButton.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get checkNowButton;

  /// No description provided for @checkingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checkingStatus;

  /// No description provided for @resendButton.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive email? Resend'**
  String get resendButton;

  /// No description provided for @resendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendCountdown(Object seconds);

  /// No description provided for @spamFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Check your Spam folder if you don\'t see the email.'**
  String get spamFolderHint;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// No description provided for @verificationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation link sent again'**
  String get verificationLinkSent;

  /// No description provided for @verificationLinkSendFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send link: {error}'**
  String verificationLinkSendFail(Object error);

  /// No description provided for @defaultEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your Email'**
  String get defaultEmailPlaceholder;

  /// No description provided for @drawerStoreFallback.
  ///
  /// In en, this message translates to:
  /// **'Your Store'**
  String get drawerStoreFallback;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Support Message from - {name} \n (ID: {id})'**
  String supportEmailSubject(Object id, Object name);

  /// No description provided for @supportEmailBody.
  ///
  /// In en, this message translates to:
  /// **'\nStore Info:\nName: {name}\nID: {id} \n---\n'**
  String supportEmailBody(Object id, Object name);

  /// No description provided for @supportCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenterTitle;

  /// No description provided for @supportCenterMsg.
  ///
  /// In en, this message translates to:
  /// **'We are here to help! We always appreciate hearing your inquiries or suggestions to improve the app.'**
  String get supportCenterMsg;

  /// No description provided for @contactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Email:'**
  String get contactEmailLabel;

  /// No description provided for @emailCopiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopiedMsg;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @sendNowButton.
  ///
  /// In en, this message translates to:
  /// **'Send Now'**
  String get sendNowButton;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get drawerTheme;

  /// No description provided for @drawerSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get drawerSupport;

  /// No description provided for @drawerAdvancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced Stats'**
  String get drawerAdvancedStats;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get drawerAbout;

  /// No description provided for @drawerRate.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get drawerRate;

  /// No description provided for @drawerHelpfulInfo.
  ///
  /// In en, this message translates to:
  /// **'Helpful Tips'**
  String get drawerHelpfulInfo;

  /// No description provided for @fieldsMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing: {fields}'**
  String fieldsMissing(String fields);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMsg.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Update now to get the latest features and improvements.'**
  String get updateAvailableMsg;

  /// No description provided for @updateNowButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNowButton;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @upgradeBannerText.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your account to access all features'**
  String get upgradeBannerText;

  /// No description provided for @aboutAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced application to manage online stores with ease.'**
  String get aboutAppDesc;

  /// No description provided for @advancedStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Statistics'**
  String get advancedStatsTitle;

  /// No description provided for @advancedStatsMsg.
  ///
  /// In en, this message translates to:
  /// **'This page is available only for premium subscribers. Coming soon.'**
  String get advancedStatsMsg;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you think of the app?'**
  String get rateAppTitle;

  /// No description provided for @rateAppMsg.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps us improve the service and develop new features.'**
  String get rateAppMsg;

  /// No description provided for @rateAppHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us how we can improve?'**
  String get rateAppHint;

  /// No description provided for @rateAppGooglePlayMsg.
  ///
  /// In en, this message translates to:
  /// **'We are glad you like the app! Would you like to rate us on the Google Play Store?'**
  String get rateAppGooglePlayMsg;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @ratingThanksMsg.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback, we will work on improving the app!'**
  String get ratingThanksMsg;

  /// No description provided for @loadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingStatus;

  /// No description provided for @premiumStatus.
  ///
  /// In en, this message translates to:
  /// **'Premium ✨'**
  String get premiumStatus;

  /// No description provided for @trialStatusDays.
  ///
  /// In en, this message translates to:
  /// **'Trial ({days} days)'**
  String trialStatusDays(Object days);

  /// No description provided for @trialStatus.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get trialStatus;

  /// No description provided for @expiredStatus.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredStatus;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @loadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'الديب'**
  String get appSubtitle;

  /// No description provided for @sessionExpiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please register again.'**
  String get sessionExpiredMsg;

  /// No description provided for @accountNotRegisteredMsg.
  ///
  /// In en, this message translates to:
  /// **'Account not registered. Please create a new store.'**
  String get accountNotRegisteredMsg;

  /// No description provided for @paymentSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessMsg;

  /// No description provided for @uploadPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing image...'**
  String get uploadPreparing;

  /// No description provided for @uploadStoreIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Store ID missing'**
  String get uploadStoreIdMissing;

  /// No description provided for @uploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading... {progress}%'**
  String uploadingProgress(Object progress);

  /// No description provided for @uploadProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get uploadProcessing;

  /// No description provided for @uploadDone.
  ///
  /// In en, this message translates to:
  /// **'Done ✅'**
  String get uploadDone;

  /// No description provided for @validationEnterPriceValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get validationEnterPriceValid;

  /// No description provided for @validationSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validationSelectCategory;

  /// No description provided for @saveProductError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save product'**
  String get saveProductError;

  /// No description provided for @alreadySaving.
  ///
  /// In en, this message translates to:
  /// **'Already saving'**
  String get alreadySaving;

  /// No description provided for @defaultStoreName.
  ///
  /// In en, this message translates to:
  /// **'My Store'**
  String get defaultStoreName;

  /// No description provided for @inviteText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to \"{storeName}\"! 🛍️✨\n\nWe are happy to invite you to visit our store, browse the latest products, and order directly via the following link:\n{url}\n\nWe look forward to seeing you! 😊'**
  String inviteText(Object storeName, Object url);

  /// No description provided for @defaultCategoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get defaultCategoryOthers;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get languageLabel;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please log in first.'**
  String get errorPermissionDenied;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get errorInvalidEmail;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password too weak. Use at least 6 characters'**
  String get errorWeakPassword;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get errorUserNotFound;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again'**
  String get errorUnknown;

  /// No description provided for @errorNoStoreFound.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no account found for this email.'**
  String get errorNoStoreFound;

  /// No description provided for @errorAccountExpired.
  ///
  /// In en, this message translates to:
  /// **'Account activation expired. Please register again.'**
  String get errorAccountExpired;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get dashboardLoadError;

  /// No description provided for @dashboardUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update dashboard'**
  String get dashboardUpdateError;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @storeLangLabel.
  ///
  /// In en, this message translates to:
  /// **'Website Language'**
  String get storeLangLabel;

  /// No description provided for @storeLangHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose the language your store will appear in for customers'**
  String get storeLangHelper;

  /// No description provided for @congratulationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get congratulationsTitle;

  /// No description provided for @storeReadyMsg.
  ///
  /// In en, this message translates to:
  /// **'Your store link is now ready!'**
  String get storeReadyMsg;

  /// No description provided for @yourStoreLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Your store link'**
  String get yourStoreLinkLabel;

  /// No description provided for @goToHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHomeButton;

  /// No description provided for @step3TransferInfo.
  ///
  /// In en, this message translates to:
  /// **'3. Transfer Information:'**
  String get step3TransferInfo;

  /// No description provided for @transferAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Sender Name / Account Holder'**
  String get transferAccountNameLabel;

  /// No description provided for @transferAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: John Doe'**
  String get transferAccountNameHint;

  /// No description provided for @transferAccountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the account holder name'**
  String get transferAccountNameRequired;

  /// No description provided for @transferAccountNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the name you transferred from so we can verify the payment'**
  String get transferAccountNameHelper;

  /// No description provided for @confirmPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment & Request Activation'**
  String get confirmPaymentButton;

  /// No description provided for @submittingRequest.
  ///
  /// In en, this message translates to:
  /// **'Submitting request...'**
  String get submittingRequest;

  /// No description provided for @activationRequestInstruction.
  ///
  /// In en, this message translates to:
  /// **'After transferring, enter the account name and tap the button to submit your activation request.'**
  String get activationRequestInstruction;

  /// No description provided for @orContactViaMessenger.
  ///
  /// In en, this message translates to:
  /// **'Or contact via WhatsApp / Telegram'**
  String get orContactViaMessenger;

  /// No description provided for @activationRequestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get activationRequestSentTitle;

  /// No description provided for @activationRequestSentMsg.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your activation request has been received and will be reviewed shortly. We will activate your store once the payment is verified.'**
  String get activationRequestSentMsg;

  /// No description provided for @activationRequestError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the request. Please try again.'**
  String get activationRequestError;

  /// No description provided for @paymentMethodElectronic.
  ///
  /// In en, this message translates to:
  /// **'شام كاش'**
  String get paymentMethodElectronic;

  /// No description provided for @paymentSyriaInfoBox.
  ///
  /// In en, this message translates to:
  /// **'يرجى إرسال المبلغ وملء النموذج. سنقوم بتفعيل متجرك فور التحقق.'**
  String get paymentSyriaInfoBox;

  /// No description provided for @paymentSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'هل تواجه مشكلة في الدفع؟'**
  String get paymentSupportTitle;

  /// No description provided for @paymentSupportAction.
  ///
  /// In en, this message translates to:
  /// **'التواصل مع الدعم'**
  String get paymentSupportAction;

  /// No description provided for @errorGoogleNoUser.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get errorGoogleNoUser;

  /// No description provided for @errorGooglePopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'The sign-in popup was blocked. Please allow popups or use redirect sign-in.'**
  String get errorGooglePopupBlocked;

  /// No description provided for @pcs1.
  ///
  /// In en, this message translates to:
  /// **'1 piece'**
  String get pcs1;

  /// No description provided for @pcs2.
  ///
  /// In en, this message translates to:
  /// **'2 pieces'**
  String get pcs2;

  /// No description provided for @pcs3to10.
  ///
  /// In en, this message translates to:
  /// **'{count} pieces'**
  String pcs3to10(Object count);

  /// No description provided for @pcsOver10.
  ///
  /// In en, this message translates to:
  /// **'{count} pieces'**
  String pcsOver10(Object count);

  /// No description provided for @securitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySectionTitle;

  /// No description provided for @securitySectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Password and Account Safety'**
  String get securitySectionSubtitle;

  /// No description provided for @setupCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Your store is ready to be published.'**
  String get setupCompleteMessage;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @licensesButton.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licensesButton;

  /// No description provided for @privacyConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get privacyConsentTitle;

  /// No description provided for @privacyConsentMessage.
  ///
  /// In en, this message translates to:
  /// **'We use (Google) for authentication and data storage. Your IP address and user ID are processed by Google services. By using this app, you agree to our privacy policy.'**
  String get privacyConsentMessage;

  /// No description provided for @privacyAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get privacyAcceptButton;

  /// No description provided for @privacyDeclineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get privacyDeclineButton;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyDeclineMessage.
  ///
  /// In en, this message translates to:
  /// **'The app cannot be used without consent to data processing.'**
  String get privacyDeclineMessage;

  /// No description provided for @pricingForMonths.
  ///
  /// In en, this message translates to:
  /// **'for {months} months'**
  String pricingForMonths(int months);

  /// No description provided for @pricingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {price}'**
  String pricingTotal(String price);

  /// No description provided for @pricingOriginalPrice.
  ///
  /// In en, this message translates to:
  /// **'Was {price}'**
  String pricingOriginalPrice(String price);

  /// No description provided for @pricingSaveAmount.
  ///
  /// In en, this message translates to:
  /// **'You save {amount}'**
  String pricingSaveAmount(String amount);

  /// No description provided for @pricingSaveTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total savings: {amount}'**
  String pricingSaveTotalAmount(String amount);

  /// No description provided for @pricingBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get pricingBestValue;

  /// No description provided for @pricingPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get pricingPopular;

  /// No description provided for @pricingLimitedOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get pricingLimitedOffer;

  /// No description provided for @pricingMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get pricingMonthlyLabel;

  /// No description provided for @pricingYearlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get pricingYearlyLabel;

  /// No description provided for @pricingBiannualLabel.
  ///
  /// In en, this message translates to:
  /// **'Biannually'**
  String get pricingBiannualLabel;

  /// No description provided for @pricingQuarterlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get pricingQuarterlyLabel;

  /// No description provided for @pricingOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get pricingOneMonth;

  /// No description provided for @pricingMonthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String pricingMonthsCount(int count);

  /// No description provided for @pricingBilledAs.
  ///
  /// In en, this message translates to:
  /// **'Billed as {total}'**
  String pricingBilledAs(String total);

  /// Error message shown when the product limit is reached
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your product limit. Upgrade your plan to publish more products.'**
  String get productLimitReached;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Growth'**
  String get paymentTitle;

  /// No description provided for @bestValueLabel.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get bestValueLabel;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ mo.'**
  String get perMonth;

  /// No description provided for @totalAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Total will be securely shown at Stripe'**
  String get totalAtCheckout;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(Object percent);

  /// No description provided for @yearlyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlanTitle;

  /// No description provided for @monthlyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlanTitle;

  /// No description provided for @pricingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get pricingPerMonth;

  /// No description provided for @pricingBilledSixMonths.
  ///
  /// In en, this message translates to:
  /// **'billed every 6 months'**
  String get pricingBilledSixMonths;

  /// No description provided for @pricingBilledYearly.
  ///
  /// In en, this message translates to:
  /// **'billed yearly'**
  String get pricingBilledYearly;

  /// No description provided for @pricingMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get pricingMostPopular;

  /// No description provided for @pricingSavePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}'**
  String pricingSavePercent(int percent);

  /// No description provided for @pricingFallbackEurInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment in USD (local currency not available)'**
  String get pricingFallbackEurInfo;

  /// No description provided for @pricingCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency:'**
  String get pricingCurrencyLabel;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get common_later;

  /// No description provided for @paywall_suspended_title.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Store Temporarily Suspended'**
  String get paywall_suspended_title;

  /// No description provided for @paywall_suspended_body.
  ///
  /// In en, this message translates to:
  /// **'The store has been temporarily suspended.\nIf you believe this is an error, please contact support and we will help you quickly.'**
  String get paywall_suspended_body;

  /// No description provided for @paywall_trial_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'🎁 Welcome! Trial Activated'**
  String get paywall_trial_welcome_title;

  /// No description provided for @paywall_trial_welcome_body.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your products and sharing your store link with customers.\nTip: Add 5–10 products initially to make your store look great.'**
  String get paywall_trial_welcome_body;

  /// No description provided for @paywall_expired_s1_title.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Ended'**
  String get paywall_expired_s1_title;

  /// No description provided for @paywall_expired_s1_body.
  ///
  /// In en, this message translates to:
  /// **'Your store is still visible to customers, but prices and sizes are temporarily hidden.\n\nActivate your subscription to restore all features immediately.'**
  String get paywall_expired_s1_body;

  /// No description provided for @paywall_expired_s2_title.
  ///
  /// In en, this message translates to:
  /// **'Images Temporarily Disabled'**
  String get paywall_expired_s2_title;

  /// No description provided for @paywall_expired_s2_body.
  ///
  /// In en, this message translates to:
  /// **'Your store is still visible to customers, but product images are temporarily hidden.\n\nActivate your subscription to restore images and other features immediately.'**
  String get paywall_expired_s2_body;

  /// No description provided for @paywall_expired_s3_title.
  ///
  /// In en, this message translates to:
  /// **'Store Currently Inactive'**
  String get paywall_expired_s3_title;

  /// No description provided for @paywall_expired_s3_body.
  ///
  /// In en, this message translates to:
  /// **'Some features have been restricted after the trial ended.\n\nActivate your subscription to continue working and display your store fully.'**
  String get paywall_expired_s3_body;

  /// No description provided for @paywall_cta_activate_now.
  ///
  /// In en, this message translates to:
  /// **'Activate Now'**
  String get paywall_cta_activate_now;

  /// No description provided for @paywall_cta_activate_store.
  ///
  /// In en, this message translates to:
  /// **'Activate Store'**
  String get paywall_cta_activate_store;

  /// No description provided for @paywall_features_header.
  ///
  /// In en, this message translates to:
  /// **'By activating, you will get:'**
  String get paywall_features_header;

  /// No description provided for @feature_show_prices.
  ///
  /// In en, this message translates to:
  /// **'Show prices, sizes, and options'**
  String get feature_show_prices;

  /// No description provided for @feature_show_images.
  ///
  /// In en, this message translates to:
  /// **'Show product images'**
  String get feature_show_images;

  /// No description provided for @feature_edit_products.
  ///
  /// In en, this message translates to:
  /// **'Add and edit products'**
  String get feature_edit_products;

  /// No description provided for @feature_faster_support.
  ///
  /// In en, this message translates to:
  /// **'Faster support when needed'**
  String get feature_faster_support;

  /// No description provided for @trial_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Trial! 🎉'**
  String get trial_popup_title;

  /// No description provided for @trial_popup_body.
  ///
  /// In en, this message translates to:
  /// **'You can now try all features:\n• Add products\n• Share your store link\n• Display the store to customers'**
  String get trial_popup_body;

  /// No description provided for @trial_days_remaining_msg.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today is the last day of the trial.} =1{1 day remaining in the trial.} other{{count} days remaining in the trial.}}'**
  String trial_days_remaining_msg(num count);

  /// No description provided for @locationPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get locationPickerTitle;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @tapMapHint.
  ///
  /// In en, this message translates to:
  /// **'Please tap on the map to set your location.'**
  String get tapMapHint;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select location on map'**
  String get selectLocationOnMap;

  /// No description provided for @imageSourceUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get imageSourceUpload;

  /// No description provided for @imageSourceLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get imageSourceLink;

  /// No description provided for @imageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image link'**
  String get imageUrlLabel;

  /// No description provided for @imageUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a direct image URL (https://...jpg/png/webp).'**
  String get imageUrlHint;

  /// No description provided for @pasteImageLink.
  ///
  /// In en, this message translates to:
  /// **'Paste an image link to preview it'**
  String get pasteImageLink;

  /// No description provided for @offerBadgePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String offerBadgePercent(Object percent);

  /// No description provided for @bundleOverlay.
  ///
  /// In en, this message translates to:
  /// **'{currency}{price} • {qtyText}'**
  String bundleOverlay(Object currency, Object price, Object qtyText);

  /// No description provided for @bundleDetailPayOnly.
  ///
  /// In en, this message translates to:
  /// **'Pay only {payQty} and get {qtyText}'**
  String bundleDetailPayOnly(Object payQty, Object qtyText);

  /// No description provided for @bundleDetail.
  ///
  /// In en, this message translates to:
  /// **'{price} for {qtyText}'**
  String bundleDetail(Object price, Object qtyText);

  /// No description provided for @freeQtyBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE {freeQtyText}'**
  String freeQtyBadge(Object freeQtyText);

  /// No description provided for @bulkBadge.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get bulkBadge;

  /// No description provided for @bulkOverlay.
  ///
  /// In en, this message translates to:
  /// **'From {qty} {qtyText}'**
  String bulkOverlay(Object qty, Object qtyText);

  /// No description provided for @pendingRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request In Progress'**
  String get pendingRequestTitle;

  /// No description provided for @pendingRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted a request. Please wait until the administrator has confirmed it.'**
  String get pendingRequestMessage;

  /// No description provided for @regularPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Regular price'**
  String get regularPriceLabel;

  /// No description provided for @discountedPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Discounted price'**
  String get discountedPriceLabel;

  /// No description provided for @effectiveUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get effectiveUnitPriceLabel;

  /// No description provided for @effectiveDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get effectiveDiscountLabel;

  /// No description provided for @logoHint.
  ///
  /// In en, this message translates to:
  /// **'Without a logo, the store name will be displayed'**
  String get logoHint;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get changeLogo;

  /// No description provided for @deleteLogo.
  ///
  /// In en, this message translates to:
  /// **'Delete logo'**
  String get deleteLogo;

  /// No description provided for @deleteLogoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the logo?'**
  String get deleteLogoConfirm;

  /// No description provided for @showNameWithLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'Show name with logo'**
  String get showNameWithLogoLabel;

  /// No description provided for @showNameWithLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Name appears next to your logo in the menu'**
  String get showNameWithLogoHint;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadError;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you really want to leave? All changes will be lost.'**
  String get unsavedChangesMessage;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @stayButton.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayButton;

  /// No description provided for @addressDescriptionToggle.
  ///
  /// In en, this message translates to:
  /// **'Add additional address description'**
  String get addressDescriptionToggle;

  /// No description provided for @addressDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Address description (optional)'**
  String get addressDescriptionLabel;

  /// No description provided for @addressDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Next to the bakery, 2nd floor left...'**
  String get addressDescriptionHint;

  /// No description provided for @storeNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Store name must not exceed 40 characters'**
  String get storeNameTooLong;

  /// No description provided for @recommendedCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested Category'**
  String get recommendedCategoryLabel;

  /// No description provided for @xlsProductId.
  ///
  /// In en, this message translates to:
  /// **'Product ID'**
  String get xlsProductId;

  /// No description provided for @xlsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get xlsName;

  /// No description provided for @xlsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get xlsCategory;

  /// No description provided for @xlsQty.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get xlsQty;

  /// No description provided for @xlsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get xlsUnit;

  /// No description provided for @xlsPurchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get xlsPurchasePrice;

  /// No description provided for @xlsPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (Unit)'**
  String get xlsPrice;

  /// No description provided for @xlsVat.
  ///
  /// In en, this message translates to:
  /// **'VAT (%)'**
  String get xlsVat;

  /// No description provided for @xlsGrossPrice.
  ///
  /// In en, this message translates to:
  /// **'Gross Price'**
  String get xlsGrossPrice;

  /// No description provided for @xlsStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get xlsStock;

  /// No description provided for @xlsSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get xlsSupplier;

  /// No description provided for @xlsActive.
  ///
  /// In en, this message translates to:
  /// **'Status (active)'**
  String get xlsActive;

  /// No description provided for @xlsOfferType.
  ///
  /// In en, this message translates to:
  /// **'Offer Type'**
  String get xlsOfferType;

  /// No description provided for @xlsCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get xlsCreatedAt;

  /// No description provided for @xlsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get xlsNote;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @xlsExportButton.
  ///
  /// In en, this message translates to:
  /// **'Excel Export'**
  String get xlsExportButton;

  /// No description provided for @xlsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export downloaded successfully'**
  String get xlsExportSuccess;

  /// No description provided for @xlsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get xlsExportError;

  /// No description provided for @xlsExportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export products'**
  String get xlsExportDialogTitle;

  /// No description provided for @xlsExportDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'Would you like to download all products as an Excel file? You can use it for accounting purposes.'**
  String get xlsExportDialogMsg;

  /// No description provided for @xlsExportDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get xlsExportDialogConfirm;

  /// No description provided for @descLangAr.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get descLangAr;

  /// No description provided for @descLangDe.
  ///
  /// In en, this message translates to:
  /// **'DE'**
  String get descLangDe;

  /// No description provided for @descLangEn.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get descLangEn;

  /// No description provided for @descLangTr.
  ///
  /// In en, this message translates to:
  /// **'TR'**
  String get descLangTr;

  /// No description provided for @autoTranslateButton.
  ///
  /// In en, this message translates to:
  /// **'Auto-Translate'**
  String get autoTranslateButton;

  /// No description provided for @autoTranslateUsed.
  ///
  /// In en, this message translates to:
  /// **'Already translated'**
  String get autoTranslateUsed;

  /// No description provided for @autoTranslateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Description was automatically translated'**
  String get autoTranslateSuccess;

  /// No description provided for @autoTranslateError.
  ///
  /// In en, this message translates to:
  /// **'Automatic translation failed'**
  String get autoTranslateError;

  /// No description provided for @autoTranslateBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Translation quota exhausted'**
  String get autoTranslateBudgetExceeded;

  /// No description provided for @descriptionHintAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic description'**
  String get descriptionHintAr;

  /// No description provided for @descriptionHintDe.
  ///
  /// In en, this message translates to:
  /// **'German description'**
  String get descriptionHintDe;

  /// No description provided for @descriptionHintEn.
  ///
  /// In en, this message translates to:
  /// **'English description'**
  String get descriptionHintEn;

  /// No description provided for @descriptionHintTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish description'**
  String get descriptionHintTr;

  /// No description provided for @autoTranslateOnCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to translate the description automatically?'**
  String get autoTranslateOnCreateTitle;

  /// No description provided for @autoTranslateOnCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter only one language and the other languages will be translated automatically.'**
  String get autoTranslateOnCreateHint;

  /// No description provided for @pageDescLabelAr.
  ///
  /// In en, this message translates to:
  /// **'Description in Arabic'**
  String get pageDescLabelAr;

  /// No description provided for @pageDescLabelDe.
  ///
  /// In en, this message translates to:
  /// **'Description in German'**
  String get pageDescLabelDe;

  /// No description provided for @pageDescLabelEn.
  ///
  /// In en, this message translates to:
  /// **'Description in English'**
  String get pageDescLabelEn;

  /// No description provided for @pageDescLabelTr.
  ///
  /// In en, this message translates to:
  /// **'Description in Turkish'**
  String get pageDescLabelTr;

  /// No description provided for @logoUploadInProgressMsg.
  ///
  /// In en, this message translates to:
  /// **'Logo is being uploaded, please wait...'**
  String get logoUploadInProgressMsg;

  /// No description provided for @productPolicyMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get productPolicyMismatchTitle;

  /// No description provided for @productPolicyMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'This product does not comply with the platform policies.'**
  String get productPolicyMismatchBody;

  /// No description provided for @productPolicyMismatchSubtext.
  ///
  /// In en, this message translates to:
  /// **'If you think this is a mistake, please contact us.'**
  String get productPolicyMismatchSubtext;

  /// No description provided for @productPolicyMismatchCta.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get productPolicyMismatchCta;

  /// No description provided for @pricingSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get pricingSummaryTitle;

  /// No description provided for @pricingSummaryPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get pricingSummaryPlanLabel;

  /// No description provided for @pricingSummaryMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly equivalent'**
  String get pricingSummaryMonthlyLabel;

  /// No description provided for @pricingSummaryTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total due today'**
  String get pricingSummaryTotalLabel;

  /// No description provided for @pricingCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get pricingCheckoutTitle;

  /// No description provided for @pricingCheckoutPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get pricingCheckoutPlanLabel;

  /// No description provided for @pricingCheckoutOriginalLabel.
  ///
  /// In en, this message translates to:
  /// **'Original price before offer'**
  String get pricingCheckoutOriginalLabel;

  /// No description provided for @pricingCheckoutOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer applied'**
  String get pricingCheckoutOfferLabel;

  /// No description provided for @pricingCheckoutTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get pricingCheckoutTotalLabel;

  /// No description provided for @pricingCheckoutDiscountValue.
  ///
  /// In en, this message translates to:
  /// **'Off {percent}  (%{amount})'**
  String pricingCheckoutDiscountValue(Object amount, Object percent);

  /// No description provided for @pricingActivationYearly.
  ///
  /// In en, this message translates to:
  /// **'Activate store for a full year'**
  String get pricingActivationYearly;

  /// No description provided for @pricingActivationSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Activate store for 6 months'**
  String get pricingActivationSixMonths;

  /// No description provided for @alreadyRatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get alreadyRatedTitle;

  /// No description provided for @alreadyRatedMsg.
  ///
  /// In en, this message translates to:
  /// **'You have already rated the app. Would you like to update your rating in the Google Play Store or leave a new review?'**
  String get alreadyRatedMsg;

  /// No description provided for @alreadyRatedHint.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us continuously improve the app.'**
  String get alreadyRatedHint;

  /// No description provided for @goToPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Go to Play Store'**
  String get goToPlayStore;

  /// No description provided for @updateRating.
  ///
  /// In en, this message translates to:
  /// **'Update rating'**
  String get updateRating;

  /// No description provided for @contactWhatsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get contactWhatsAppLabel;

  /// No description provided for @whatsappNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not available. Number copied: {phone}'**
  String whatsappNotAvailable(Object phone);

  /// No description provided for @whatsappError.
  ///
  /// In en, this message translates to:
  /// **'Error opening WhatsApp'**
  String get whatsappError;

  /// No description provided for @refPriceMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference Pricing & Exchange Rate'**
  String get refPriceMenuTitle;

  /// No description provided for @refPriceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference Product Pricing'**
  String get refPriceDialogTitle;

  /// No description provided for @refPriceDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your product prices in a reference currency (e.g., USD). The system will automatically convert them and display them to customers in the local currency based on the exchange rate you set.'**
  String get refPriceDialogDesc;

  /// No description provided for @refPriceEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable reference pricing'**
  String get refPriceEnable;

  /// No description provided for @refCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference currency (for input)'**
  String get refCurrencyLabel;

  /// No description provided for @refRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get refRateLabel;

  /// No description provided for @refPriceExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If you enter a product price in {base}, the customer will see it as: {finalPrice} {localCurrency}'**
  String refPriceExample(Object base, Object finalPrice, Object localCurrency);

  /// No description provided for @refPriceHelperText.
  ///
  /// In en, this message translates to:
  /// **'for the customer: {finalPrice} {localCurrency}'**
  String refPriceHelperText(String finalPrice, String localCurrency);

  /// No description provided for @refCurrencyHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'The reference currency is not visible in your store. It is used exclusively as an internal base for your price calculations.'**
  String get refCurrencyHiddenHint;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'\$  US Dollar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'€  Euro'**
  String get currencyEur;

  /// No description provided for @currencyTry.
  ///
  /// In en, this message translates to:
  /// **'₺  Turkish Lira'**
  String get currencyTry;

  /// No description provided for @currencyLabelSYP.
  ///
  /// In en, this message translates to:
  /// **'ل.س  Syrian Pound (SYP)'**
  String get currencyLabelSYP;

  /// No description provided for @currencyLabelAED.
  ///
  /// In en, this message translates to:
  /// **'د.إ  United Arab Emirates Dirham (AED)'**
  String get currencyLabelAED;

  /// No description provided for @currencyLabelBHD.
  ///
  /// In en, this message translates to:
  /// **'د.ب  Bahraini Dinar (BHD)'**
  String get currencyLabelBHD;

  /// No description provided for @currencyLabelDZD.
  ///
  /// In en, this message translates to:
  /// **'د.ج  Algerian Dinar (DZD)'**
  String get currencyLabelDZD;

  /// No description provided for @currencyLabelEGP.
  ///
  /// In en, this message translates to:
  /// **'ج.م  Egyptian Pound (EGP)'**
  String get currencyLabelEGP;

  /// No description provided for @currencyLabelIQD.
  ///
  /// In en, this message translates to:
  /// **'ع.د  Iraqi Dinar (IQD)'**
  String get currencyLabelIQD;

  /// No description provided for @currencyLabelJOD.
  ///
  /// In en, this message translates to:
  /// **'د.أ  Jordanian Dinar (JOD)'**
  String get currencyLabelJOD;

  /// No description provided for @currencyLabelKWD.
  ///
  /// In en, this message translates to:
  /// **'د.ك  Kuwaiti Dinar (KWD)'**
  String get currencyLabelKWD;

  /// No description provided for @currencyLabelLBP.
  ///
  /// In en, this message translates to:
  /// **'ل.ل  Lebanese Pound (LBP)'**
  String get currencyLabelLBP;

  /// No description provided for @currencyLabelLYD.
  ///
  /// In en, this message translates to:
  /// **'د.ل  Libyan Dinar (LYD)'**
  String get currencyLabelLYD;

  /// No description provided for @currencyLabelMAD.
  ///
  /// In en, this message translates to:
  /// **'د.م.  Moroccan Dirham (MAD)'**
  String get currencyLabelMAD;

  /// No description provided for @currencyLabelOMR.
  ///
  /// In en, this message translates to:
  /// **'ر.ع.  Omani Rial (OMR)'**
  String get currencyLabelOMR;

  /// No description provided for @currencyLabelQAR.
  ///
  /// In en, this message translates to:
  /// **'ر.ق  Qatari Riyal (QAR)'**
  String get currencyLabelQAR;

  /// No description provided for @currencyLabelSAR.
  ///
  /// In en, this message translates to:
  /// **'﷼  Saudi Riyal (SAR)'**
  String get currencyLabelSAR;

  /// No description provided for @currencyLabelSDG.
  ///
  /// In en, this message translates to:
  /// **'ج.س  Sudanese Pound (SDG)'**
  String get currencyLabelSDG;

  /// No description provided for @currencyLabelDJF.
  ///
  /// In en, this message translates to:
  /// **'Fdj  Djiboutian Franc (DJF)'**
  String get currencyLabelDJF;

  /// No description provided for @currencyLabelTND.
  ///
  /// In en, this message translates to:
  /// **'د.ت  Tunisian Dinar (TND)'**
  String get currencyLabelTND;

  /// No description provided for @currencyLabelYER.
  ///
  /// In en, this message translates to:
  /// **'ر.ي  Yemeni Rial (YER)'**
  String get currencyLabelYER;

  /// No description provided for @currencyLabelMRU.
  ///
  /// In en, this message translates to:
  /// **'UM  Mauritanian Ouguiya (MRU)'**
  String get currencyLabelMRU;

  /// No description provided for @currencyLabelSOS.
  ///
  /// In en, this message translates to:
  /// **'Sh  Somali Shilling (SOS)'**
  String get currencyLabelSOS;

  /// No description provided for @currencyLabelKMF.
  ///
  /// In en, this message translates to:
  /// **'CF  Comorian Franc (KMF)'**
  String get currencyLabelKMF;

  /// No description provided for @currencyLabelAUD.
  ///
  /// In en, this message translates to:
  /// **'A\$  Australian Dollar (AUD)'**
  String get currencyLabelAUD;

  /// No description provided for @currencyLabelBRL.
  ///
  /// In en, this message translates to:
  /// **'R\$  Brazilian Real (BRL)'**
  String get currencyLabelBRL;

  /// No description provided for @currencyLabelCAD.
  ///
  /// In en, this message translates to:
  /// **'C\$  Canadian Dollar (CAD)'**
  String get currencyLabelCAD;

  /// No description provided for @currencyLabelCHF.
  ///
  /// In en, this message translates to:
  /// **'CHF  Swiss Franc (CHF)'**
  String get currencyLabelCHF;

  /// No description provided for @currencyLabelCNY.
  ///
  /// In en, this message translates to:
  /// **'¥  Chinese Yuan (CNY)'**
  String get currencyLabelCNY;

  /// No description provided for @currencyLabelEUR.
  ///
  /// In en, this message translates to:
  /// **'€  Euro (EUR)'**
  String get currencyLabelEUR;

  /// No description provided for @currencyLabelGBP.
  ///
  /// In en, this message translates to:
  /// **'£  British Pound (GBP)'**
  String get currencyLabelGBP;

  /// No description provided for @currencyLabelJPY.
  ///
  /// In en, this message translates to:
  /// **'¥  Japanese Yen (JPY)'**
  String get currencyLabelJPY;

  /// No description provided for @currencyLabelRUB.
  ///
  /// In en, this message translates to:
  /// **'₽  Russian Ruble (RUB)'**
  String get currencyLabelRUB;

  /// No description provided for @currencyLabelSEK.
  ///
  /// In en, this message translates to:
  /// **'kr  Swedish Krona (SEK)'**
  String get currencyLabelSEK;

  /// No description provided for @currencyLabelTRY.
  ///
  /// In en, this message translates to:
  /// **'₺  Turkish Lira (TRY)'**
  String get currencyLabelTRY;

  /// No description provided for @currencyLabelUSD.
  ///
  /// In en, this message translates to:
  /// **'\$  US Dollar (USD)'**
  String get currencyLabelUSD;

  /// No description provided for @customTemplateNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get customTemplateNewTitle;

  /// No description provided for @customTemplateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get customTemplateEditTitle;

  /// No description provided for @customTemplateTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (e.g., Weekend Sale)'**
  String get customTemplateTitleHint;

  /// No description provided for @customTemplateMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get customTemplateMessageHint;

  /// No description provided for @customTemplateDefaultTab.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get customTemplateDefaultTab;

  /// No description provided for @customTemplateMyTab.
  ///
  /// In en, this message translates to:
  /// **'My Templates'**
  String get customTemplateMyTab;

  /// No description provided for @customTemplateCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get customTemplateCreateNew;

  /// No description provided for @customTemplateEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any custom templates yet.'**
  String get customTemplateEmpty;

  /// No description provided for @stopCategoryOffersConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Offers?'**
  String get stopCategoryOffersConfirmTitle;

  /// No description provided for @stopCategoryOffersConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to turn off all offers for this category?'**
  String get stopCategoryOffersConfirmMessage;

  /// No description provided for @stopCategoryOffersConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, turn off'**
  String get stopCategoryOffersConfirmYes;

  /// No description provided for @stopCategoryOffersConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No, cancel'**
  String get stopCategoryOffersConfirmNo;

  /// No description provided for @activeOffersBadge.
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get activeOffersBadge;

  /// No description provided for @addressPrecisionHint.
  ///
  /// In en, this message translates to:
  /// **'The exact location is saved via the map, even if the address text seems imprecise.'**
  String get addressPrecisionHint;

  /// No description provided for @logoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get logoUploading;

  /// No description provided for @logoProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get logoProcessing;

  /// No description provided for @logoDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get logoDeleting;

  /// No description provided for @logoUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Logo updated'**
  String get logoUpdatedToast;

  /// No description provided for @logoDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Logo deleted'**
  String get logoDeletedToast;

  /// No description provided for @deleteLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete logo'**
  String get deleteLogoTitle;

  /// No description provided for @productPolicyEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Product Review'**
  String get productPolicyEmailSubject;

  /// No description provided for @productPolicyEmailBodyIntro.
  ///
  /// In en, this message translates to:
  /// **'I believe this restriction is a mistake.'**
  String get productPolicyEmailBodyIntro;

  /// No description provided for @contactEmailLine.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String contactEmailLine(Object email);

  /// No description provided for @contactEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email address copied'**
  String get contactEmailCopied;

  /// No description provided for @drawerAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Store Analytics'**
  String get drawerAnalytics;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsRange7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get analyticsRange7;

  /// No description provided for @analyticsRange30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get analyticsRange30;

  /// No description provided for @analyticsRange90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get analyticsRange90;

  /// No description provided for @analyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No analytics yet.'**
  String get analyticsEmpty;

  /// No description provided for @analyticsCardVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get analyticsCardVisits;

  /// No description provided for @analyticsCardWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp clicks'**
  String get analyticsCardWhatsapp;

  /// No description provided for @analyticsCardProductViews.
  ///
  /// In en, this message translates to:
  /// **'Product views'**
  String get analyticsCardProductViews;

  /// No description provided for @analyticsCardAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get analyticsCardAddToCart;

  /// No description provided for @analyticsCardCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout intent'**
  String get analyticsCardCheckout;

  /// No description provided for @analyticsChartVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits per day'**
  String get analyticsChartVisits;

  /// No description provided for @analyticsChartWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp clicks per day'**
  String get analyticsChartWhatsapp;

  /// No description provided for @analyticsTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent days'**
  String get analyticsTableTitle;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @analyticsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get analyticsFilterTitle;

  /// No description provided for @analyticsFilterFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get analyticsFilterFrom;

  /// No description provided for @analyticsFilterTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get analyticsFilterTo;

  /// No description provided for @analyticsPeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak day'**
  String get analyticsPeakTitle;

  /// No description provided for @analyticsAxisDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get analyticsAxisDays;

  /// No description provided for @analyticsAxisCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get analyticsAxisCount;

  /// No description provided for @analyticsMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get analyticsMonthLabel;

  /// No description provided for @month01.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month01;

  /// No description provided for @month02.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month02;

  /// No description provided for @month03.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month03;

  /// No description provided for @month04.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month04;

  /// No description provided for @month05.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month05;

  /// No description provided for @month06.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month06;

  /// No description provided for @month07.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month07;

  /// No description provided for @month08.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month08;

  /// No description provided for @month09.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month09;

  /// No description provided for @month10.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month12;

  /// No description provided for @installAppAppleTitle.
  ///
  /// In en, this message translates to:
  /// **'Install App (iOS)'**
  String get installAppAppleTitle;

  /// No description provided for @installAppAppleStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Tap the Share icon at the bottom of Safari (square with arrow).'**
  String get installAppAppleStep1;

  /// No description provided for @installAppAppleStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Scroll down and select \'Add to Home Screen\'.'**
  String get installAppAppleStep2;

  /// No description provided for @installAppAppleStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Confirm by tapping \'Add\' in the top right corner.'**
  String get installAppAppleStep3;

  /// No description provided for @gotItButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItButton;

  /// No description provided for @analyticsPeakVisits.
  ///
  /// In en, this message translates to:
  /// **'{count} visits'**
  String analyticsPeakVisits(int count);

  /// No description provided for @analyticsPeakWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'{count} clicks'**
  String analyticsPeakWhatsapp(int count);

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter active'**
  String get activeFilters;

  /// No description provided for @analyticsVsYesterdayValue.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {value}'**
  String analyticsVsYesterdayValue(Object value);

  /// No description provided for @analyticsAvg7DaysValue.
  ///
  /// In en, this message translates to:
  /// **'7-day avg {value}'**
  String analyticsAvg7DaysValue(Object value);

  /// No description provided for @analyticsCardVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'Visits Today'**
  String get analyticsCardVisitsToday;

  /// No description provided for @analyticsCardVisitsRange.
  ///
  /// In en, this message translates to:
  /// **'Visits (Date Range)'**
  String get analyticsCardVisitsRange;
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
      <String>['ar', 'de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
