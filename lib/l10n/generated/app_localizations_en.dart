// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Product Management';

  @override
  String get login => 'Login';

  @override
  String get sessionExpired => 'Session expired. Please verify again.';

  @override
  String get noStore => 'Account not registered. Please create a store.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get contactAndAddressTitle => 'Contact & Address';

  @override
  String get phoneNumberLabel => 'Phone Number*';

  @override
  String get whatsappSameAsPhone => 'WhatsApp same as phone number';

  @override
  String get whatsappNumberLabel => 'WhatsApp Number*';

  @override
  String get countryLabel => 'Country';

  @override
  String get selectCountry => 'Select Country';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressHint => 'Street, District, City...';

  @override
  String get useCurrentLocationTooltip => 'Use current location';

  @override
  String get securityTitle => 'Security';

  @override
  String get loginEmailLabel => 'Login Email';

  @override
  String get googleAuthInfo =>
      'You are signed in via Google. You can set a password to enable direct email login.';

  @override
  String get passwordResetSent => 'Password reset link sent to your email';

  @override
  String get sendingStatus => 'Sending...';

  @override
  String get sendResetLinkButton => 'Send password reset link';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get forgotPasswordButton => 'Forgot Password?';

  @override
  String get storeFallbackName => 'Your Store';

  @override
  String get noEmail => 'No email specified';

  @override
  String statusTrialDays(Object days) {
    return 'Trial • $days days';
  }

  @override
  String get statusTrial => 'Trial';

  @override
  String get statusActive => 'Active';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get shippingTitle => 'Delivery';

  @override
  String get shippingEnabled => 'Delivery Available';

  @override
  String get shippingEnabledSubtitle => 'Enable delivery service for customers';

  @override
  String get shippingCostLabel => 'Delivery Cost';

  @override
  String get shippingCostHint => '0.00';

  @override
  String get socialLinksTitle => 'Links & Social';

  @override
  String get socialTiktok => 'TikTok';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get supportEmailLabel => 'Support Email';

  @override
  String get supportEmailHint => 'email@example.com';

  @override
  String get storeInfoTitle => 'Store Information';

  @override
  String get storeNameLabel => 'Store Name';

  @override
  String get storeDescLabel => 'Store Description';

  @override
  String get storeDescHint => 'High quality and reasonable prices';

  @override
  String get storeDescHelper =>
      'This description appears below the store name on the home page.';

  @override
  String createdAtDate(Object date) {
    return 'Created: $date';
  }

  @override
  String get currencyLabel => 'Store Currency*';

  @override
  String get workingHoursTitle => 'Working Hours';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get profileTitle => 'Profile';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get appearanceSectionSubtitle => 'Customize app appearance';

  @override
  String get storeInfoSectionTitle => 'Store Info';

  @override
  String get storeInfoSectionSubtitle => 'Name, Currency, Description';

  @override
  String get contactSectionTitle => 'Contact';

  @override
  String get contactSectionSubtitle => 'Phone, Address, Social Links';

  @override
  String get otherSettingsSectionTitle => 'Other Settings';

  @override
  String get otherSettingsSectionSubtitle =>
      'Working Hours, Delivery, Security';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get savingButton => 'Saving...';

  @override
  String get logoutButton => 'Log Out';

  @override
  String get saveSuccessMsg => 'Changes saved';

  @override
  String get saveErrorMsg => 'Error saving';

  @override
  String get setupStoreTitle => 'Store Setup';

  @override
  String get stepIdentity => 'Identity';

  @override
  String get stepContact => 'Contact';

  @override
  String get stepDelivery => 'Delivery';

  @override
  String get stepHours => 'Hours';

  @override
  String get stepFinish => 'Finish';

  @override
  String get step1Title => 'Let\'s start with basics';

  @override
  String get step1Subtitle => 'Choose a name and logo for your store';

  @override
  String get step2Title => 'How to contact you?';

  @override
  String get step2Subtitle => 'Enter phone number and address for customers';

  @override
  String get step3Title => 'Delivery Service';

  @override
  String get step3Subtitle => 'Do you provide delivery for your customers?';

  @override
  String get enableDeliveryLabel => 'Enable Delivery';

  @override
  String get deliveryEnabled => 'Service Enabled';

  @override
  String get deliveryDisabled => 'Service Disabled';

  @override
  String get fixedDeliveryPriceLabel => 'Fixed Delivery Price';

  @override
  String get deliveryPriceHelper => 'Leave empty to set price later per order';

  @override
  String get step4Title => 'When is your store open?';

  @override
  String get step4Subtitle => 'You can skip this step and add it later';

  @override
  String get step5Title =>
      'Congratulations! You have completed your store setup.';

  @override
  String get step5Subtitle =>
      'You have completed your store setup. You can edit it later in your profile.';

  @override
  String get step5SubtitleWeb =>
      'For iPhone users: Tap the Share button and select \'Add to Home Screen\' for a better experience.';

  @override
  String get shortDescriptionLabel => 'Short Store Description (Optional)';

  @override
  String get optionalBadge => 'Optional';

  @override
  String get skipButton => 'Skip';

  @override
  String get nextButton => 'Next';

  @override
  String get finishSetupButton => 'Finish Setup';

  @override
  String get validationEnterStoreName => 'Please enter store name';

  @override
  String get validationEnterPhone => 'Please enter phone number';

  @override
  String get logoutConfirmMsg => 'Are you sure you want to log out?';

  @override
  String get logoutConfirmButton => 'Log Out';

  @override
  String locationFetchError(Object error) {
    return 'Error fetching location: $error';
  }

  @override
  String get fillAllFieldsError => 'Please fill all fields';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password is too short (min. 6 characters)';

  @override
  String generalError(Object error) {
    return 'Error: $error';
  }

  @override
  String get storeNameRequired => 'Store name is required';

  @override
  String get noEditPermission => 'You do not have permission to edit';

  @override
  String get addProductTitle => 'Add Product';

  @override
  String get editProductTitle => 'Edit Product';

  @override
  String get requiredField => 'Required';

  @override
  String get productNameLabel => 'Product Name';

  @override
  String get priceLabel => 'Price';

  @override
  String get newCategoryLabel => 'New Category';

  @override
  String get categoryLabel => 'Category';

  @override
  String get addNewCategory => 'Add New';

  @override
  String get sizeLabel => 'Size';

  @override
  String get unitLabel => 'Unit';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descQuality => 'High quality & great taste';

  @override
  String get descFresh => 'Fresh & Daily';

  @override
  String get descBestseller => 'Our Bestseller';

  @override
  String get descLimited => 'Limited Offer';

  @override
  String get descHandmade => 'Luxury Handmade';

  @override
  String get descNatural => '100% Natural';

  @override
  String get productAvailable => 'Product Available';

  @override
  String get visibleToCustomers => 'Visible to customers';

  @override
  String get hiddenFromCustomers => 'Hidden from customers';

  @override
  String get specialOfferAvailable => 'Special Offer';

  @override
  String get specialOfferSubtitle => 'Enable discounts or wholesale offers';

  @override
  String get offerTypeLabel => 'Offer Type';

  @override
  String get offerTypePercent => 'Percentage %';

  @override
  String get offerTypeBundle => 'Bundle Offer';

  @override
  String get offerTypeBulk => 'Bulk/Tiered Price';

  @override
  String get percentageLabel => 'Percentage (%)';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get totalPriceLabel => 'Total Price';

  @override
  String get quantityStartLabel => 'Quantity (from)';

  @override
  String get pricePerPieceLabel => 'Price per piece';

  @override
  String get offerDurationLabel => 'Offer Duration';

  @override
  String get saveButton => 'Save';

  @override
  String get productPublishedMsg => 'Product published';

  @override
  String get uploading => 'Uploading...';

  @override
  String get processing => 'Processing...';

  @override
  String get errorStatus => 'Error';

  @override
  String get productImageLabel => 'Product Image';

  @override
  String get tapToUpload => 'Tap to upload image';

  @override
  String get optionalSuffix => '(Optional)';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'g';

  @override
  String get unitL => 'L';

  @override
  String get unitMl => 'ml';

  @override
  String get unitPcs => 'pcs';

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteCategoryMsg(Object name) {
    return 'Do you want to delete \"$name\"? Products will be moved to \"Others\".';
  }

  @override
  String get categoriesLoadError => 'Failed to load categories';

  @override
  String get categoryRenameTitle => 'Edit Category';

  @override
  String get categoryRenameLabel => 'New Category Name';

  @override
  String get categoryRenameSuccess => 'Category renamed successfully';

  @override
  String get categoryRenameFail => 'Failed to rename category';

  @override
  String get categoryRenameError => 'Error renaming category';

  @override
  String deleteCategoryConfirmMsg(Object moveTo, Object name) {
    return 'All products will be moved from \"$name\" to \"$moveTo\". Are you sure?';
  }

  @override
  String get categoryDeleteSuccess => 'Category deleted successfully';

  @override
  String get categoryDeleteFail => 'Failed to delete category';

  @override
  String get categoryDeleteError => 'Error deleting category';

  @override
  String productsCount(Object count) {
    return '$count Products';
  }

  @override
  String get viewProductsAction => 'View Products';

  @override
  String get viewProductsSubtitle => 'Open product list for this category';

  @override
  String get applyCategoryOfferAction => 'Apply Offer to Category';

  @override
  String get applyCategoryOfferSubtitle =>
      'Percentage discount for all products';

  @override
  String get stopCategoryOffersAction => 'Stop Category Offers';

  @override
  String get stopCategoryOffersSubtitle =>
      'Disable all offers in this category';

  @override
  String get categoryFullOfferTitle => 'Full Category Offer';

  @override
  String applyToCategorySubtitle(Object category) {
    return 'Apply to \"$category\"';
  }

  @override
  String get percentageHint => 'Example: 15';

  @override
  String get offerValidityLabel => 'Offer Validity';

  @override
  String get invalidPercentageError => 'Enter valid percentage';

  @override
  String get applyOfferButton => 'Apply Offer';

  @override
  String categoryOfferAppliedMsg(Object category) {
    return 'Offer applied to category \"$category\"';
  }

  @override
  String get categoryOfferApplyFail => 'Failed to apply offer';

  @override
  String categoryOffersDisabledMsg(Object category) {
    return 'Offers stopped for category \"$category\"';
  }

  @override
  String get categoryOffersDisableFail => 'Failed to stop offers';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String categoriesCountLabel(Object count) {
    return '$count Categories';
  }

  @override
  String get noCategoriesTitle => 'No categories yet';

  @override
  String get noCategoriesSubtitle =>
      'Add new categories to organize your products';

  @override
  String offerUntilDate(Object date) {
    return 'Until $date';
  }

  @override
  String discountPercent(Object percent) {
    return '$percent% Discount';
  }

  @override
  String bundleOfferLabel(Object currency, Object price, Object qty) {
    return '$qty for $price $currency';
  }

  @override
  String get offerLabel => 'Offer';

  @override
  String get availableStatus => ' Available';

  @override
  String get unavailableStatus => 'Unavailable';

  @override
  String get updateFail => 'Update failed';

  @override
  String get deleteProductTitle => 'Delete Product';

  @override
  String deleteProductConfirmMsg(Object name) {
    return 'Do you want to delete \"$name\"?';
  }

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get deleteFail => 'Delete failed';

  @override
  String get noProducts => 'No products found';

  @override
  String get customerMessageTitle => 'Customer Message';

  @override
  String get templateDiscountTitle => 'Special Discount';

  @override
  String get templateDiscountText =>
      '🔥 Special 20% discount on all products for a limited time! Don\'t miss out.';

  @override
  String get templateWelcomeTitle => 'Welcome';

  @override
  String get templateWelcomeText =>
      'Welcome to our store! We wish you a happy and enjoyable shopping experience. ✨';

  @override
  String get templateNewTitle => 'New Arrivals';

  @override
  String get templateNewText =>
      'A new and distinctive collection has arrived! Browse the latest products in the store now. 🆕';

  @override
  String get templateDeliveryTitle => 'Free Delivery';

  @override
  String get templateDeliveryText =>
      'Shop now and get free delivery on all orders over 50 Euro! 🚚';

  @override
  String get templateOccasionTitle => 'Occasion';

  @override
  String get templateOccasionText =>
      'Happy Holidays! Enjoy our exclusive offers. 🌙';

  @override
  String get loadDataError => 'Failed to load data';

  @override
  String get messagePublishedSuccess => 'Message published successfully ✅';

  @override
  String get saveFailed => 'Save failed, please try again';

  @override
  String get connectionError => 'Connection error';

  @override
  String get messageDeleted => 'Message deleted 🗑';

  @override
  String get deleteMessageTitle => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete the message? It will no longer appear to customers.';

  @override
  String get chooseTemplateTitle => 'Choose a template';

  @override
  String get previewTitle => 'Customer Preview';

  @override
  String get editMessageTitle => 'Edit Message';

  @override
  String get templatesButton => 'Templates';

  @override
  String get displayDurationTitle => 'Display Duration';

  @override
  String get previewPlaceholder => 'Your message will appear here...';

  @override
  String get messageHint => 'E.g.: 20% discount on all products 🌙';

  @override
  String get engageTextHint => 'Enter engaging text to increase sales';

  @override
  String get durationAlways => 'Always';

  @override
  String get durationDay => '1 Day';

  @override
  String get duration3Days => '3 Days';

  @override
  String get durationWeek => '1 Week';

  @override
  String get durationMonth => '1 Month';

  @override
  String get saveAndPublishButton => 'Save and Publish';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get restorePasswordHeadline => 'Reset Password';

  @override
  String get restorePasswordDesc =>
      'Enter your registered email and we will send you a link to set a new password.';

  @override
  String get enterEmailValidation => 'Please enter email';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get resetLinkSentMsg => 'Password reset link sent to your email.';

  @override
  String get emailNotRegistered => 'This email is not registered.';

  @override
  String get generalSendError =>
      'Could not send now. Please check the email address.';

  @override
  String get sendLinkButton => 'Send Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get homeTitle => 'Home';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String welcomeStoreName(Object storeName) {
    return 'Welcome, $storeName';
  }

  @override
  String get validationEnterAddress => 'Please enter the store address';

  @override
  String get dashboardSubtitle => 'Here is a quick summary of your store today';

  @override
  String get publicStoreLink => 'Public Store Link';

  @override
  String get noLinkYet => 'No link yet';

  @override
  String get copyLinkSuccess => 'Link copied!';

  @override
  String get shareStoreInvite => 'Share Store Invite';

  @override
  String get customerMessagePlaceholder => 'No message set yet. Tap to add.';

  @override
  String get liveStatsTitle => 'Live Statistics';

  @override
  String get statsTotalProducts => 'Products';

  @override
  String get statsAvailable => ' Available';

  @override
  String get statsUnavailable => 'Unavailable';

  @override
  String get statsOffers => 'Offers';

  @override
  String get statsCategoryOffers => 'Cat. Offers';

  @override
  String get statsNoImage => 'No Image';

  @override
  String get statsLargestCategory => 'Largest Cat.';

  @override
  String get filterAllProducts => 'All Products';

  @override
  String get filterAvailable => 'Available Products';

  @override
  String get filterUnavailable => 'Unavailable Products';

  @override
  String get filterActiveOffers => 'Active Offers';

  @override
  String get filterNoImage => 'Products without Image';

  @override
  String filterCategoryPrefix(Object category) {
    return 'Category: $category';
  }

  @override
  String noProductsFoundTitle(Object title) {
    return 'No products: $title';
  }

  @override
  String get categoryOffersTitle => 'Full Category Offers';

  @override
  String get categoryOffersSubtitle =>
      'Categories where all products are on offer';

  @override
  String get noCategoryOffers => 'No categories with full offers';

  @override
  String get stopOfferAction => 'Stop';

  @override
  String get stopCategoryOfferSuccess => 'Category offers stopped';

  @override
  String get stopCategoryOfferConfirm =>
      'Are you sure? All offer types in this category will be stopped.';

  @override
  String get expirationAlertTitle => 'Expiration Alert';

  @override
  String expirationAlertMsg(Object days) {
    return 'Hello! Your store subscription will expire in $days days. Please renew now to ensure uninterrupted service.';
  }

  @override
  String get renewNowButton => 'Renew Now';

  @override
  String get laterButton => 'Later';

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navCategories => 'Categories';

  @override
  String get navStore => 'Store';

  @override
  String get activateButton => 'Activate';

  @override
  String get loginTitle => 'Log In';

  @override
  String get loginSubtitle => 'Enter your account details to access your store';

  @override
  String get loginEmailOrPassError => 'Incorrect email or password';

  @override
  String get noStoreTitle => 'No Store Found';

  @override
  String get noStoreMessage =>
      'Do you want to create a new store using this account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get createStore => 'Create Store';

  @override
  String get loginNoPermission => 'Access denied';

  @override
  String get googleLoginFailed => 'Google sign-in failed';

  @override
  String get unexpectedError => 'Sorry, an unexpected error occurred.';

  @override
  String get googleSigningIn => 'Signing in...';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get orSeparator => 'OR';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email format';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signInButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createNewStore => 'Create new store';

  @override
  String get activationSuccessTitle => 'Activation Successful!';

  @override
  String get activationSuccessMsg =>
      'Thank you! Your store has been activated successfully.';

  @override
  String get startNowButton => 'Start Now';

  @override
  String get loadingErrorPrefix => 'Error: ';

  @override
  String get choosePlanTitle => 'Choose Your Plan';

  @override
  String get noPlansAvailable => 'No plans available at the moment';

  @override
  String get choosePlanSubtitle =>
      'Choose the subscription plan that suits you';

  @override
  String get savePercentage => 'Save 20%';

  @override
  String get paymentLinkError => 'Server did not return a payment link';

  @override
  String get paymentPrepError =>
      'Error preparing payment. Please try again later.';

  @override
  String payAndActivate(Object price) {
    return 'Pay $price & Activate';
  }

  @override
  String get featureUnlimitedProducts =>
      'Extensive Inventory (up to 400 products)';

  @override
  String get featurePremiumSupport => 'Premium Support';

  @override
  String get featureAdvancedStats => 'Advanced Statistics';

  @override
  String get featureNoCommission => 'No Sales Commission';

  @override
  String get paymentAndActivationTitle => 'Payment & Activation';

  @override
  String get adminContactLabel => 'Activation Manager';

  @override
  String get step1ChoosePlan => '1. Choose Plan:';

  @override
  String get step2PaymentDetails => '2. Payment Details (Transfer here):';

  @override
  String get qrCodePlaceholder => 'QR Code Photo';

  @override
  String get accountNumberLabel => 'Account Number / ID';

  @override
  String get copyIdSuccess => 'ID Copied';

  @override
  String get sendActivationInfoButton => 'Send Activation Info';

  @override
  String get afterPaymentInstruction =>
      'After payment, tap the button to send your store name and ID automatically.';

  @override
  String get sharePaymentConfirmTitle => 'Send payment confirmation via';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get telegramLabel => 'Telegram';

  @override
  String get telegramCopySuccess => 'Message copied! Paste it in the chat.';

  @override
  String paymentMessageBody(
    Object planName,
    Object price,
    Object storeId,
    Object storeName,
  ) {
    return 'Hello, I have transferred the amount to activate the store.\nPlease activate:\n\n🏪 *Store:* $storeName\n🆔 *ID:* $storeId\n📅 *Plan:* $planName ($price)\n\nThank you!';
  }

  @override
  String get productsTitle => 'Products';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get productsLoadError => 'Failed to load products';

  @override
  String get productUpdateSuccess => 'Product updated successfully';

  @override
  String get productUpdateStatusFail => 'Failed to update product status';

  @override
  String get offerUpdateFail => 'Failed to update offer';

  @override
  String get productDeleteSuccess => 'Product deleted successfully';

  @override
  String get productDeleteFail => 'Failed to delete product';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterApply => 'Apply';

  @override
  String get stockStatusLabel => 'Status';

  @override
  String get offersLabel => 'Offers';

  @override
  String get filterAll => 'All';

  @override
  String get filterWithOffer => 'With Offer';

  @override
  String get filterWithoutOffer => 'Without Offer';

  @override
  String get filterActive => 'Available / Active';

  @override
  String get filterInactive => 'Unavailable / Inactive';

  @override
  String get disableProduct => 'Disable Product';

  @override
  String get enableProduct => 'Enable Product';

  @override
  String get disableOffer => 'Disable Offer';

  @override
  String get enableOffer => 'Enable Offer';

  @override
  String get noSearchResults => 'No results found';

  @override
  String get noStoreFound => 'No store found';

  @override
  String get noStoreMsg =>
      'App data might be missing.\nPlease log in or setup the store again.';

  @override
  String get setupStoreButton => 'Setup Store';

  @override
  String get reloginButton => 'Log in again';

  @override
  String get registerTitle => 'Create Store';

  @override
  String get completeStoreCreation => 'Complete Store Creation';

  @override
  String get enterStoreNamePrompt =>
      'Enter store name to complete registration';

  @override
  String get googleAccountLabel => 'Google Account';

  @override
  String get trialPeriodInfo => 'Free trial';

  @override
  String get createStoreButton => 'Create Store';

  @override
  String get cancelAndReturnToLogin => 'Cancel and return to login';

  @override
  String get registerNewStoreTitle => 'Create New Store';

  @override
  String get registerSubtitle => 'Create your store and get a free trial';

  @override
  String get googleRegisterButton => 'Sign up with Google';

  @override
  String get googleRegistering => 'Registering...';

  @override
  String get storeNameHint => 'Example: Al-Aseel Store';

  @override
  String get storeNameTooShort => 'Store name is too short (min. 3 chars)';

  @override
  String get requireEmailVerifyLabel =>
      'Require email verification from customers';

  @override
  String get requireEmailVerifySubtitle =>
      'New customers need to verify their email';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginLink => 'Log In';

  @override
  String get registerFailedMsg => 'Failed to create account. Please try again.';

  @override
  String errorOccurred(Object error) {
    return 'Error occurred: $error';
  }

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetLinkSentTitle => 'Reset Link Sent';

  @override
  String checkEmailForResetMsg(Object username) {
    return 'Please check your email ($username) and follow the link to change your password.';
  }

  @override
  String get backToLoginButton => 'Back to Login';

  @override
  String get subscriptionInfoTitle => 'Subscription Details';

  @override
  String get activePremiumTitle => 'Active Premium Subscription';

  @override
  String get activePremiumSubtitle =>
      'Your store is fully operational without restrictions';

  @override
  String get trialPeriodTitle => 'Trial Period';

  @override
  String trialRemaining(Object days) {
    return '$days days remaining in trial';
  }

  @override
  String get freeTrial => 'Free Trial Period';

  @override
  String get subscriptionExpiredTitle => 'Subscription Expired';

  @override
  String get subscriptionExpiredSubtitle =>
      'Store features are temporarily suspended';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get contactSupport => 'Please contact support';

  @override
  String get planDetailsCardTitle => 'Plan Details & Dates';

  @override
  String get storeLabel => 'Store';

  @override
  String get subscriptionTypeLabel => 'Subscription Type';

  @override
  String get premiumYearly => 'Premium (Yearly)';

  @override
  String get trialFree => 'Trial / Free';

  @override
  String get creationDate => 'Creation Date';

  @override
  String get activatedAt => 'Activated At';

  @override
  String get subscriptionEndsAt => 'Subscription Ends At';

  @override
  String get trialStartedAt => 'Trial Started At';

  @override
  String get trialEndsAt => 'Trial Ends At';

  @override
  String get subscriptionEndedAt => 'Subscription Ended At';

  @override
  String get trialEndedAt => 'Trial Ended At';

  @override
  String get currentBenefitsTitle => 'Current Subscription Benefits';

  @override
  String get benefitUnlimitedProducts => 'Add and manage unlimited products';

  @override
  String get benefitHighQualityImages =>
      'High-quality image display for customers';

  @override
  String get benefitShowPrices => 'Prices and sizes visible on website';

  @override
  String get benefitFullControl => 'Full control over store settings';

  @override
  String get benefitDirectSupport => 'Direct and fast support';

  @override
  String get restrictionStagesTitle => 'Store Restriction Stages';

  @override
  String get restrictionStage1 => 'Hide product images from public store';

  @override
  String get restrictionStage2 => 'Hide prices, sizes, and contact info';

  @override
  String get restrictionStage3 => 'Full suspension of dashboard and store';

  @override
  String get renewSubscriptionButton => 'Renew Subscription Now';

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String get logoutTooltip => 'Log Out';

  @override
  String get checkYourEmailTitle => 'Check Your Email';

  @override
  String get sentLinkTo => 'We sent a confirmation link to:';

  @override
  String get verifyEmailInstructions =>
      'Open your email and click the confirmation link.\nYou will be redirected automatically after verification.';

  @override
  String get checkNowButton => 'Check Now';

  @override
  String get checkingStatus => 'Checking...';

  @override
  String get resendButton => 'Didn\'t receive email? Resend';

  @override
  String resendCountdown(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get spamFolderHint =>
      'Check your Spam folder if you don\'t see the email.';

  @override
  String get emailVerifiedSuccess => 'Email verified successfully!';

  @override
  String get verificationLinkSent => 'Confirmation link sent again';

  @override
  String verificationLinkSendFail(Object error) {
    return 'Failed to send link: $error';
  }

  @override
  String get defaultEmailPlaceholder => 'Your Email';

  @override
  String get drawerStoreFallback => 'Your Store';

  @override
  String supportEmailSubject(Object id, Object name) {
    return 'Support Message from - $name \n (ID: $id)';
  }

  @override
  String supportEmailBody(Object id, Object name) {
    return '\nStore Info:\nName: $name\nID: $id \n---\n';
  }

  @override
  String get supportCenterTitle => 'Support Center';

  @override
  String get supportCenterMsg =>
      'We are here to help! We always appreciate hearing your inquiries or suggestions to improve the app.';

  @override
  String get contactEmailLabel => 'Contact Email:';

  @override
  String get emailCopiedMsg => 'Email copied';

  @override
  String get closeButton => 'Close';

  @override
  String get sendNowButton => 'Send Now';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get drawerTheme => 'Appearance';

  @override
  String get drawerSupport => 'Support';

  @override
  String get drawerAdvancedStats => 'Advanced Stats';

  @override
  String get drawerAbout => 'About App';

  @override
  String get drawerRate => 'Rate App';

  @override
  String get drawerHelpfulInfo => 'Helpful Tips';

  @override
  String fieldsMissing(String fields) {
    return 'Missing: $fields';
  }

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String get updateAvailableMsg =>
      'A new version of the app is available. Update now to get the latest features and improvements.';

  @override
  String get updateNowButton => 'Update Now';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get upgradeBannerText => 'Upgrade your account to access all features';

  @override
  String get aboutAppDesc =>
      'Advanced application to manage online stores with ease.';

  @override
  String get advancedStatsTitle => 'Advanced Statistics';

  @override
  String get advancedStatsMsg =>
      'This page is available only for premium subscribers. Coming soon.';

  @override
  String get okButton => 'OK';

  @override
  String get rateAppTitle => 'What do you think of the app?';

  @override
  String get rateAppMsg =>
      'Your rating helps us improve the service and develop new features.';

  @override
  String get rateAppHint => 'Tell us how we can improve?';

  @override
  String get rateAppGooglePlayMsg =>
      'We are glad you like the app! Would you like to rate us on the Google Play Store?';

  @override
  String get sendButton => 'Send';

  @override
  String get ratingThanksMsg =>
      'Thanks for your feedback, we will work on improving the app!';

  @override
  String get loadingStatus => 'Loading...';

  @override
  String get premiumStatus => 'Premium ✨';

  @override
  String trialStatusDays(Object days) {
    return 'Trial ($days days)';
  }

  @override
  String get trialStatus => 'Trial';

  @override
  String get expiredStatus => 'Expired';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get loadingMessage => 'Loading...';

  @override
  String get appName => 'Product Management';

  @override
  String get appSubtitle => 'الديب';

  @override
  String get sessionExpiredMsg => 'Session expired. Please register again.';

  @override
  String get accountNotRegisteredMsg =>
      'Account not registered. Please create a new store.';

  @override
  String get paymentSuccessMsg => 'Payment successful!';

  @override
  String get uploadPreparing => 'Preparing image...';

  @override
  String get uploadStoreIdMissing => 'Store ID missing';

  @override
  String uploadingProgress(Object progress) {
    return 'Uploading... $progress%';
  }

  @override
  String get uploadProcessing => 'Processing image...';

  @override
  String get uploadDone => 'Done ✅';

  @override
  String get validationEnterPriceValid => 'Please enter a valid price';

  @override
  String get validationSelectCategory => 'Please select a category';

  @override
  String get saveProductError => 'Failed to save product';

  @override
  String get alreadySaving => 'Already saving';

  @override
  String get defaultStoreName => 'My Store';

  @override
  String inviteText(Object storeName, Object url) {
    return 'Welcome to \"$storeName\"! 🛍️✨\n\nWe are happy to invite you to visit our store, browse the latest products, and order directly via the following link:\n$url\n\nWe look forward to seeing you! 😊';
  }

  @override
  String get defaultCategoryOthers => 'Others';

  @override
  String get languageLabel => 'App Language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorPermissionDenied => 'Permission denied. Please log in first.';

  @override
  String get errorEmailInUse => 'Email already in use';

  @override
  String get errorInvalidEmail => 'Invalid email format';

  @override
  String get errorWeakPassword =>
      'Password too weak. Use at least 6 characters';

  @override
  String get errorUserNotFound => 'Invalid credentials';

  @override
  String get errorNetwork => 'Network error';

  @override
  String get errorUnknown => 'Unexpected error. Please try again';

  @override
  String get errorNoStoreFound => 'Sorry, no account found for this email.';

  @override
  String get errorAccountExpired =>
      'Account activation expired. Please register again.';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get dashboardLoadError => 'Failed to load dashboard';

  @override
  String get dashboardUpdateError => 'Failed to update dashboard';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get storeLangLabel => 'Website Language';

  @override
  String get storeLangHelper =>
      'Choose the language your store will appear in for customers';

  @override
  String get congratulationsTitle => 'Congratulations! 🎉';

  @override
  String get storeReadyMsg => 'Your store link is now ready!';

  @override
  String get yourStoreLinkLabel => 'Your store link';

  @override
  String get goToHomeButton => 'Go to Home';

  @override
  String get step3TransferInfo => '3. Transfer Information:';

  @override
  String get transferAccountNameLabel => 'Sender Name / Account Holder';

  @override
  String get transferAccountNameHint => 'Example: John Doe';

  @override
  String get transferAccountNameRequired =>
      'Please enter the account holder name';

  @override
  String get transferAccountNameHelper =>
      'Enter the name you transferred from so we can verify the payment';

  @override
  String get confirmPaymentButton => 'Confirm Payment & Request Activation';

  @override
  String get submittingRequest => 'Submitting request...';

  @override
  String get activationRequestInstruction =>
      'After transferring, enter the account name and tap the button to submit your activation request.';

  @override
  String get orContactViaMessenger => 'Or contact via WhatsApp / Telegram';

  @override
  String get activationRequestSentTitle => 'Request Sent!';

  @override
  String get activationRequestSentMsg =>
      'Thank you! Your activation request has been received and will be reviewed shortly. We will activate your store once the payment is verified.';

  @override
  String get activationRequestError =>
      'An error occurred while sending the request. Please try again.';

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
  String get errorGoogleNoUser => 'Google sign-in failed. Please try again.';

  @override
  String get errorGooglePopupBlocked =>
      'The sign-in popup was blocked. Please allow popups or use redirect sign-in.';

  @override
  String get pcs1 => '1 piece';

  @override
  String get pcs2 => '2 pieces';

  @override
  String pcs3to10(Object count) {
    return '$count pieces';
  }

  @override
  String pcsOver10(Object count) {
    return '$count pieces';
  }

  @override
  String get securitySectionTitle => 'Security';

  @override
  String get securitySectionSubtitle => 'Password and Account Safety';

  @override
  String get setupCompleteMessage => 'Your store is ready to be published.';

  @override
  String get publishButton => 'Publish';

  @override
  String get licensesButton => 'Licenses';

  @override
  String get privacyConsentTitle => 'Privacy Notice';

  @override
  String get privacyConsentMessage =>
      'We use (Google) for authentication and data storage. Your IP address and user ID are processed by Google services. By using this app, you agree to our privacy policy.';

  @override
  String get privacyAcceptButton => 'Accept';

  @override
  String get privacyDeclineButton => 'Decline';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyDeclineMessage =>
      'The app cannot be used without consent to data processing.';

  @override
  String pricingForMonths(int months) {
    return 'for $months months';
  }

  @override
  String pricingTotal(String price) {
    return 'Total: $price';
  }

  @override
  String pricingOriginalPrice(String price) {
    return 'Was $price';
  }

  @override
  String pricingSaveAmount(String amount) {
    return 'You save $amount';
  }

  @override
  String pricingSaveTotalAmount(String amount) {
    return 'Total savings: $amount';
  }

  @override
  String get pricingBestValue => 'Best Value';

  @override
  String get pricingPopular => 'Popular';

  @override
  String get pricingLimitedOffer => 'Limited Time Offer';

  @override
  String get pricingMonthlyLabel => 'Monthly';

  @override
  String get pricingYearlyLabel => 'Yearly';

  @override
  String get pricingBiannualLabel => 'Biannually';

  @override
  String get pricingQuarterlyLabel => 'Quarterly';

  @override
  String get pricingOneMonth => '1 month';

  @override
  String pricingMonthsCount(int count) {
    return '$count months';
  }

  @override
  String pricingBilledAs(String total) {
    return 'Billed as $total';
  }

  @override
  String get productLimitReached =>
      'You\'ve reached your product limit. Upgrade your plan to publish more products.';

  @override
  String get paymentTitle => 'Choose Your Growth';

  @override
  String get bestValueLabel => 'RECOMMENDED';

  @override
  String get perMonth => '/ mo.';

  @override
  String get totalAtCheckout => 'Total will be securely shown at Stripe';

  @override
  String savePercent(Object percent) {
    return 'Save $percent%';
  }

  @override
  String get yearlyPlanTitle => 'Yearly Plan';

  @override
  String get monthlyPlanTitle => 'Monthly Plan';

  @override
  String get pricingPerMonth => 'per month';

  @override
  String get pricingBilledSixMonths => 'billed every 6 months';

  @override
  String get pricingBilledYearly => 'billed yearly';

  @override
  String get pricingMostPopular => 'Most popular';

  @override
  String pricingSavePercent(int percent) {
    return 'Save $percent';
  }

  @override
  String get pricingFallbackEurInfo =>
      'Payment in USD (local currency not available)';

  @override
  String get pricingCurrencyLabel => 'Currency:';

  @override
  String get common_ok => 'OK';

  @override
  String get common_later => 'Later';

  @override
  String get paywall_suspended_title => '⚠️ Store Temporarily Suspended';

  @override
  String get paywall_suspended_body =>
      'The store has been temporarily suspended.\nIf you believe this is an error, please contact support and we will help you quickly.';

  @override
  String get paywall_trial_welcome_title => '🎁 Welcome! Trial Activated';

  @override
  String get paywall_trial_welcome_body =>
      'Start by adding your products and sharing your store link with customers.\nTip: Add 5–10 products initially to make your store look great.';

  @override
  String get paywall_expired_s1_title => 'Free Trial Ended';

  @override
  String get paywall_expired_s1_body =>
      'Your store is still visible to customers, but prices and sizes are temporarily hidden.\n\nActivate your subscription to restore all features immediately.';

  @override
  String get paywall_expired_s2_title => 'Images Temporarily Disabled';

  @override
  String get paywall_expired_s2_body =>
      'Your store is still visible to customers, but product images are temporarily hidden.\n\nActivate your subscription to restore images and other features immediately.';

  @override
  String get paywall_expired_s3_title => 'Store Currently Inactive';

  @override
  String get paywall_expired_s3_body =>
      'Some features have been restricted after the trial ended.\n\nActivate your subscription to continue working and display your store fully.';

  @override
  String get paywall_cta_activate_now => 'Activate Now';

  @override
  String get paywall_cta_activate_store => 'Activate Store';

  @override
  String get paywall_features_header => 'By activating, you will get:';

  @override
  String get feature_show_prices => 'Show prices, sizes, and options';

  @override
  String get feature_show_images => 'Show product images';

  @override
  String get feature_edit_products => 'Add and edit products';

  @override
  String get feature_faster_support => 'Faster support when needed';

  @override
  String get trial_popup_title => 'Welcome to the Trial! 🎉';

  @override
  String get trial_popup_body =>
      'You can now try all features:\n• Add products\n• Share your store link\n• Display the store to customers';

  @override
  String trial_days_remaining_msg(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining in the trial.',
      one: '1 day remaining in the trial.',
      zero: 'Today is the last day of the trial.',
    );
    return '$_temp0';
  }

  @override
  String get locationPickerTitle => 'Select Location';

  @override
  String get saveLabel => 'Save';

  @override
  String get tapMapHint => 'Please tap on the map to set your location.';

  @override
  String get selectLocationOnMap => 'Select location on map';

  @override
  String get imageSourceUpload => 'Upload';

  @override
  String get imageSourceLink => 'Link';

  @override
  String get imageUrlLabel => 'Image link';

  @override
  String get imageUrlHint =>
      'Paste a direct image URL (https://...jpg/png/webp).';

  @override
  String get pasteImageLink => 'Paste an image link to preview it';

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
    return 'Pay only $payQty and get $qtyText';
  }

  @override
  String bundleDetail(Object price, Object qtyText) {
    return '$price for $qtyText';
  }

  @override
  String freeQtyBadge(Object freeQtyText) {
    return 'FREE $freeQtyText';
  }

  @override
  String get bulkBadge => 'Bulk';

  @override
  String bulkOverlay(Object qty, Object qtyText) {
    return 'From $qty $qtyText';
  }

  @override
  String get pendingRequestTitle => 'Request In Progress';

  @override
  String get pendingRequestMessage =>
      'You have already submitted a request. Please wait until the administrator has confirmed it.';

  @override
  String get regularPriceLabel => 'Regular price';

  @override
  String get discountedPriceLabel => 'Discounted price';

  @override
  String get effectiveUnitPriceLabel => 'Unit price';

  @override
  String get effectiveDiscountLabel => 'Discount';

  @override
  String get logoHint => 'Without a logo, the store name will be displayed';

  @override
  String get changeLogo => 'Change logo';

  @override
  String get deleteLogo => 'Delete logo';

  @override
  String get deleteLogoConfirm => 'Are you sure you want to delete the logo?';

  @override
  String get showNameWithLogoLabel => 'Show name with logo';

  @override
  String get showNameWithLogoHint =>
      'Name appears next to your logo in the menu';

  @override
  String get uploadError => 'Upload failed';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you really want to leave? All changes will be lost.';

  @override
  String get discardButton => 'Discard';

  @override
  String get stayButton => 'Stay';

  @override
  String get addressDescriptionToggle => 'Add additional address description';

  @override
  String get addressDescriptionLabel => 'Address description (optional)';

  @override
  String get addressDescriptionHint =>
      'e.g. Next to the bakery, 2nd floor left...';

  @override
  String get storeNameTooLong => 'Store name must not exceed 40 characters';

  @override
  String get recommendedCategoryLabel => 'Suggested Category';

  @override
  String get xlsProductId => 'Product ID';

  @override
  String get xlsName => 'Name';

  @override
  String get xlsCategory => 'Category';

  @override
  String get xlsQty => 'Quantity';

  @override
  String get xlsUnit => 'Unit';

  @override
  String get xlsPurchasePrice => 'Purchase Price';

  @override
  String get xlsPrice => 'Price (Unit)';

  @override
  String get xlsVat => 'VAT (%)';

  @override
  String get xlsGrossPrice => 'Gross Price';

  @override
  String get xlsStock => 'Stock';

  @override
  String get xlsSupplier => 'Supplier';

  @override
  String get xlsActive => 'Status (active)';

  @override
  String get xlsOfferType => 'Offer Type';

  @override
  String get xlsCreatedAt => 'Created At';

  @override
  String get xlsNote => 'Note';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get xlsExportButton => 'Excel Export';

  @override
  String get xlsExportSuccess => 'Export downloaded successfully';

  @override
  String get xlsExportError => 'Export failed';

  @override
  String get xlsExportDialogTitle => 'Export products';

  @override
  String get xlsExportDialogMsg =>
      'Would you like to download all products as an Excel file? You can use it for accounting purposes.';

  @override
  String get xlsExportDialogConfirm => 'Download';

  @override
  String get descLangAr => 'AR';

  @override
  String get descLangDe => 'DE';

  @override
  String get descLangEn => 'EN';

  @override
  String get descLangTr => 'TR';

  @override
  String get autoTranslateButton => 'Auto-Translate';

  @override
  String get autoTranslateUsed => 'Already translated';

  @override
  String get autoTranslateSuccess => 'Description was automatically translated';

  @override
  String get autoTranslateError => 'Automatic translation failed';

  @override
  String get autoTranslateBudgetExceeded => 'Translation quota exhausted';

  @override
  String get descriptionHintAr => 'Arabic description';

  @override
  String get descriptionHintDe => 'German description';

  @override
  String get descriptionHintEn => 'English description';

  @override
  String get descriptionHintTr => 'Turkish description';

  @override
  String get autoTranslateOnCreateTitle =>
      'Do you want to translate the description automatically?';

  @override
  String get autoTranslateOnCreateHint =>
      'Enter only one language and the other languages will be translated automatically.';

  @override
  String get pageDescLabelAr => 'Description in Arabic';

  @override
  String get pageDescLabelDe => 'Description in German';

  @override
  String get pageDescLabelEn => 'Description in English';

  @override
  String get pageDescLabelTr => 'Description in Turkish';

  @override
  String get logoUploadInProgressMsg =>
      'Logo is being uploaded, please wait...';

  @override
  String get productPolicyMismatchTitle => 'Notice';

  @override
  String get productPolicyMismatchBody =>
      'This product does not comply with the platform policies.';

  @override
  String get productPolicyMismatchSubtext =>
      'If you think this is a mistake, please contact us.';

  @override
  String get productPolicyMismatchCta => 'Contact support';

  @override
  String get pricingSummaryTitle => 'Payment summary';

  @override
  String get pricingSummaryPlanLabel => 'Plan';

  @override
  String get pricingSummaryMonthlyLabel => 'Monthly equivalent';

  @override
  String get pricingSummaryTotalLabel => 'Total due today';

  @override
  String get pricingCheckoutTitle => 'Payment summary';

  @override
  String get pricingCheckoutPlanLabel => 'Plan';

  @override
  String get pricingCheckoutOriginalLabel => 'Original price before offer';

  @override
  String get pricingCheckoutOfferLabel => 'Offer applied';

  @override
  String get pricingCheckoutTotalLabel => 'Total';

  @override
  String pricingCheckoutDiscountValue(Object amount, Object percent) {
    return 'Off $percent  (%$amount)';
  }

  @override
  String get pricingActivationYearly => 'Activate store for a full year';

  @override
  String get pricingActivationSixMonths => 'Activate store for 6 months';

  @override
  String get alreadyRatedTitle => 'Thank you for your rating!';

  @override
  String get alreadyRatedMsg =>
      'You have already rated the app. Would you like to update your rating in the Google Play Store or leave a new review?';

  @override
  String get alreadyRatedHint =>
      'Your feedback helps us continuously improve the app.';

  @override
  String get goToPlayStore => 'Go to Play Store';

  @override
  String get updateRating => 'Update rating';

  @override
  String get contactWhatsAppLabel => 'WhatsApp Support';

  @override
  String whatsappNotAvailable(Object phone) {
    return 'WhatsApp is not available. Number copied: $phone';
  }

  @override
  String get whatsappError => 'Error opening WhatsApp';

  @override
  String get refPriceMenuTitle => 'Reference Pricing & Exchange Rate';

  @override
  String get refPriceDialogTitle => 'Reference Product Pricing';

  @override
  String get refPriceDialogDesc =>
      'Enter your product prices in a reference currency (e.g., USD). The system will automatically convert them and display them to customers in the local currency based on the exchange rate you set.';

  @override
  String get refPriceEnable => 'Enable reference pricing';

  @override
  String get refCurrencyLabel => 'Reference currency (for input)';

  @override
  String get refRateLabel => 'Exchange rate';

  @override
  String refPriceExample(Object base, Object finalPrice, Object localCurrency) {
    return 'Example: If you enter a product price in $base, the customer will see it as: $finalPrice $localCurrency';
  }

  @override
  String refPriceHelperText(String finalPrice, String localCurrency) {
    return 'for the customer: $finalPrice $localCurrency';
  }

  @override
  String get refCurrencyHiddenHint =>
      'The reference currency is not visible in your store. It is used exclusively as an internal base for your price calculations.';

  @override
  String get currencyUsd => '\$  US Dollar';

  @override
  String get currencyEur => '€  Euro';

  @override
  String get currencyTry => '₺  Turkish Lira';

  @override
  String get currencyLabelSYP => 'ل.س  Syrian Pound (SYP)';

  @override
  String get currencyLabelAED => 'د.إ  United Arab Emirates Dirham (AED)';

  @override
  String get currencyLabelBHD => 'د.ب  Bahraini Dinar (BHD)';

  @override
  String get currencyLabelDZD => 'د.ج  Algerian Dinar (DZD)';

  @override
  String get currencyLabelEGP => 'ج.م  Egyptian Pound (EGP)';

  @override
  String get currencyLabelIQD => 'ع.د  Iraqi Dinar (IQD)';

  @override
  String get currencyLabelJOD => 'د.أ  Jordanian Dinar (JOD)';

  @override
  String get currencyLabelKWD => 'د.ك  Kuwaiti Dinar (KWD)';

  @override
  String get currencyLabelLBP => 'ل.ل  Lebanese Pound (LBP)';

  @override
  String get currencyLabelLYD => 'د.ل  Libyan Dinar (LYD)';

  @override
  String get currencyLabelMAD => 'د.م.  Moroccan Dirham (MAD)';

  @override
  String get currencyLabelOMR => 'ر.ع.  Omani Rial (OMR)';

  @override
  String get currencyLabelQAR => 'ر.ق  Qatari Riyal (QAR)';

  @override
  String get currencyLabelSAR => '﷼  Saudi Riyal (SAR)';

  @override
  String get currencyLabelSDG => 'ج.س  Sudanese Pound (SDG)';

  @override
  String get currencyLabelDJF => 'Fdj  Djiboutian Franc (DJF)';

  @override
  String get currencyLabelTND => 'د.ت  Tunisian Dinar (TND)';

  @override
  String get currencyLabelYER => 'ر.ي  Yemeni Rial (YER)';

  @override
  String get currencyLabelMRU => 'UM  Mauritanian Ouguiya (MRU)';

  @override
  String get currencyLabelSOS => 'Sh  Somali Shilling (SOS)';

  @override
  String get currencyLabelKMF => 'CF  Comorian Franc (KMF)';

  @override
  String get currencyLabelAUD => 'A\$  Australian Dollar (AUD)';

  @override
  String get currencyLabelBRL => 'R\$  Brazilian Real (BRL)';

  @override
  String get currencyLabelCAD => 'C\$  Canadian Dollar (CAD)';

  @override
  String get currencyLabelCHF => 'CHF  Swiss Franc (CHF)';

  @override
  String get currencyLabelCNY => '¥  Chinese Yuan (CNY)';

  @override
  String get currencyLabelEUR => '€  Euro (EUR)';

  @override
  String get currencyLabelGBP => '£  British Pound (GBP)';

  @override
  String get currencyLabelJPY => '¥  Japanese Yen (JPY)';

  @override
  String get currencyLabelRUB => '₽  Russian Ruble (RUB)';

  @override
  String get currencyLabelSEK => 'kr  Swedish Krona (SEK)';

  @override
  String get currencyLabelTRY => '₺  Turkish Lira (TRY)';

  @override
  String get currencyLabelUSD => '\$  US Dollar (USD)';

  @override
  String get customTemplateNewTitle => 'New Template';

  @override
  String get customTemplateEditTitle => 'Edit Template';

  @override
  String get customTemplateTitleHint => 'Title (e.g., Weekend Sale)';

  @override
  String get customTemplateMessageHint => 'Message';

  @override
  String get customTemplateDefaultTab => 'Default';

  @override
  String get customTemplateMyTab => 'My Templates';

  @override
  String get customTemplateCreateNew => 'Create New';

  @override
  String get customTemplateEmpty =>
      'You haven\'t created any custom templates yet.';

  @override
  String get stopCategoryOffersConfirmTitle => 'Stop Offers?';

  @override
  String get stopCategoryOffersConfirmMessage =>
      'Are you sure you want to turn off all offers for this category?';

  @override
  String get stopCategoryOffersConfirmYes => 'Yes, turn off';

  @override
  String get stopCategoryOffersConfirmNo => 'No, cancel';

  @override
  String get activeOffersBadge => 'Active Offers';

  @override
  String get addressPrecisionHint =>
      'The exact location is saved via the map, even if the address text seems imprecise.';

  @override
  String get logoUploading => 'Uploading…';

  @override
  String get logoProcessing => 'Processing…';

  @override
  String get logoDeleting => 'Deleting…';

  @override
  String get logoUpdatedToast => 'Logo updated';

  @override
  String get logoDeletedToast => 'Logo deleted';

  @override
  String get deleteLogoTitle => 'Delete logo';

  @override
  String get productPolicyEmailSubject => 'Product Review';

  @override
  String get productPolicyEmailBodyIntro =>
      'I believe this restriction is a mistake.';

  @override
  String contactEmailLine(Object email) {
    return 'Email: $email';
  }

  @override
  String get contactEmailCopied => 'Email address copied';

  @override
  String get drawerAnalytics => 'Store Analytics';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsRange7 => 'Last 7 days';

  @override
  String get analyticsRange30 => 'Last 30 days';

  @override
  String get analyticsRange90 => 'Last 90 days';

  @override
  String get analyticsEmpty => 'No analytics yet.';

  @override
  String get analyticsCardVisits => 'Visits';

  @override
  String get analyticsCardWhatsapp => 'WhatsApp clicks';

  @override
  String get analyticsCardProductViews => 'Product views';

  @override
  String get analyticsCardAddToCart => 'Add to cart';

  @override
  String get analyticsCardCheckout => 'Checkout intent';

  @override
  String get analyticsChartVisits => 'Visits per day';

  @override
  String get analyticsChartWhatsapp => 'WhatsApp clicks per day';

  @override
  String get analyticsTableTitle => 'Recent days';

  @override
  String get refreshButton => 'Refresh';

  @override
  String get analyticsFilterTitle => 'Filter';

  @override
  String get analyticsFilterFrom => 'From';

  @override
  String get analyticsFilterTo => 'To';

  @override
  String get analyticsPeakTitle => 'Peak day';

  @override
  String get analyticsAxisDays => 'Days';

  @override
  String get analyticsAxisCount => 'Count';

  @override
  String get analyticsMonthLabel => 'Month';

  @override
  String get month01 => 'January';

  @override
  String get month02 => 'February';

  @override
  String get month03 => 'March';

  @override
  String get month04 => 'April';

  @override
  String get month05 => 'May';

  @override
  String get month06 => 'June';

  @override
  String get month07 => 'July';

  @override
  String get month08 => 'August';

  @override
  String get month09 => 'September';

  @override
  String get month10 => 'October';

  @override
  String get month11 => 'November';

  @override
  String get month12 => 'December';

  @override
  String get installAppAppleTitle => 'Install App (iOS)';

  @override
  String get installAppAppleStep1 =>
      '1. Tap the Share icon at the bottom of Safari (square with arrow).';

  @override
  String get installAppAppleStep2 =>
      '2. Scroll down and select \'Add to Home Screen\'.';

  @override
  String get installAppAppleStep3 =>
      '3. Confirm by tapping \'Add\' in the top right corner.';

  @override
  String get gotItButton => 'Got it';

  @override
  String analyticsPeakVisits(int count) {
    return '$count visits';
  }

  @override
  String analyticsPeakWhatsapp(int count) {
    return '$count clicks';
  }
}
