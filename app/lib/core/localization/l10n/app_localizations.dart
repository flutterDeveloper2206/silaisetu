import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SilaiSetu'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Tailoring Business, Connected.'**
  String get tagline;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create Your Shop'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email or mobile number'**
  String get emailOrMobile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobile;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @altMobile.
  ///
  /// In en, this message translates to:
  /// **'Alternate mobile (optional)'**
  String get altMobile;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Forgot email or mobile number?'**
  String get forgotIdentifier;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @sendReset.
  ///
  /// In en, this message translates to:
  /// **'Send reset instructions'**
  String get sendReset;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get verifyAccount;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterOtp;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get saveDraft;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveContinue;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finish;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email/mobile number or password'**
  String get invalidCredentials;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get weakPassword;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get invalidPhone;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of SilaiSetu?'**
  String get logoutConfirm;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your login has expired. Please sign in again.'**
  String get sessionExpiredBody;

  /// No description provided for @sessionExpiredOk.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sessionExpiredOk;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @shopSettings.
  ///
  /// In en, this message translates to:
  /// **'Shop settings'**
  String get shopSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @selectShop.
  ///
  /// In en, this message translates to:
  /// **'Select shop'**
  String get selectShop;

  /// No description provided for @onboardingShopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop profile'**
  String get onboardingShopProfile;

  /// No description provided for @onboardingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shop address'**
  String get onboardingAddress;

  /// No description provided for @onboardingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Business preferences'**
  String get onboardingPreferences;

  /// No description provided for @onboardingSettings.
  ///
  /// In en, this message translates to:
  /// **'Shop settings'**
  String get onboardingSettings;

  /// No description provided for @onboardingReview.
  ///
  /// In en, this message translates to:
  /// **'Review & finish'**
  String get onboardingReview;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopName;

  /// No description provided for @shopPhone.
  ///
  /// In en, this message translates to:
  /// **'Shop mobile'**
  String get shopPhone;

  /// No description provided for @shopEmail.
  ///
  /// In en, this message translates to:
  /// **'Shop email'**
  String get shopEmail;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Shop owner name'**
  String get ownerName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Business description (optional)'**
  String get description;

  /// No description provided for @address1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get address1;

  /// No description provided for @address2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2 (optional)'**
  String get address2;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area / locality'**
  String get area;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pincode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @garments.
  ///
  /// In en, this message translates to:
  /// **'Garments'**
  String get garments;

  /// No description provided for @unitInches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get unitInches;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'Centimetres'**
  String get unitCm;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @receiptHeader.
  ///
  /// In en, this message translates to:
  /// **'Receipt header'**
  String get receiptHeader;

  /// No description provided for @receiptFooter.
  ///
  /// In en, this message translates to:
  /// **'Receipt footer'**
  String get receiptFooter;

  /// No description provided for @welcomeShop.
  ///
  /// In en, this message translates to:
  /// **'Your shop is ready. Welcome to SilaiSetu!'**
  String get welcomeShop;

  /// No description provided for @resumeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Continue shop setup'**
  String get resumeOnboarding;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get empty;

  /// No description provided for @todayDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Today\'s deliveries'**
  String get todayDeliveries;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New to SilaiSetu?'**
  String get newHere;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get passwordStrength;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @devCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Dev code (local only)'**
  String get devCodeHint;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, recovery instructions were sent.'**
  String get resetSent;

  /// No description provided for @supportHelp.
  ///
  /// In en, this message translates to:
  /// **'Contact support if you cannot access your account.'**
  String get supportHelp;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @startSetup.
  ///
  /// In en, this message translates to:
  /// **'Start shop setup'**
  String get startSetup;

  /// No description provided for @onboardingIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your tailoring shop'**
  String get onboardingIntroTitle;

  /// No description provided for @onboardingIntroBody.
  ///
  /// In en, this message translates to:
  /// **'A few short steps and your shop will be ready for customers, measurements, and orders.'**
  String get onboardingIntroBody;

  /// No description provided for @onboardingIntroNote.
  ///
  /// In en, this message translates to:
  /// **'You can save as draft and continue later after signing in.'**
  String get onboardingIntroNote;

  /// No description provided for @onboardingHintProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop name, contact details, and description'**
  String get onboardingHintProfile;

  /// No description provided for @onboardingHintAddress.
  ///
  /// In en, this message translates to:
  /// **'Where customers find your shop'**
  String get onboardingHintAddress;

  /// No description provided for @onboardingHintPreferences.
  ///
  /// In en, this message translates to:
  /// **'Garments, units, language, and currency'**
  String get onboardingHintPreferences;

  /// No description provided for @onboardingHintSettings.
  ///
  /// In en, this message translates to:
  /// **'Receipts and payment preferences'**
  String get onboardingHintSettings;

  /// No description provided for @navTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get navTotal;

  /// No description provided for @navPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get navPending;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get receivePayment;

  /// No description provided for @dateFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get dateFilter;

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @rangeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rangeYesterday;

  /// No description provided for @rangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rangeThisWeek;

  /// No description provided for @rangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rangeThisMonth;

  /// No description provided for @rangePreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get rangePreviousMonth;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @ordersThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersThisPeriod;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get statusCutting;

  /// No description provided for @statusStitching.
  ///
  /// In en, this message translates to:
  /// **'Stitching'**
  String get statusStitching;

  /// No description provided for @statusTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get statusTrial;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @kindAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get kindAdvance;

  /// No description provided for @kindBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get kindBalance;

  /// No description provided for @kindFull.
  ///
  /// In en, this message translates to:
  /// **'Full payment'**
  String get kindFull;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @methodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get methodUpi;

  /// No description provided for @methodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get methodCard;

  /// No description provided for @methodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get methodBank;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer info'**
  String get customerInfo;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyLabel;

  /// No description provided for @measurementVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} · v{version}'**
  String measurementVersionLabel(String name, String version);

  /// No description provided for @garmentLineTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} × {qty}'**
  String garmentLineTitle(String name, String qty);

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @recentCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recent customers'**
  String get recentCustomers;

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get searchOrders;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get searchCustomers;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerDetails;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @confirmArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive this customer? Order history is kept.'**
  String get confirmArchive;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore this customer?'**
  String get confirmRestore;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @garmentTemplates.
  ///
  /// In en, this message translates to:
  /// **'Garment templates'**
  String get garmentTemplates;

  /// No description provided for @tasksProduction.
  ///
  /// In en, this message translates to:
  /// **'Tasks & production'**
  String get tasksProduction;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @workerPayments.
  ///
  /// In en, this message translates to:
  /// **'Worker payments'**
  String get workerPayments;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @stitchGallery.
  ///
  /// In en, this message translates to:
  /// **'Stitch gallery'**
  String get stitchGallery;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sectionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sectionWork;

  /// No description provided for @sectionMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get sectionMoney;

  /// No description provided for @sectionStock.
  ///
  /// In en, this message translates to:
  /// **'Stock & design'**
  String get sectionStock;

  /// No description provided for @sectionInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get sectionInsights;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @garmentName.
  ///
  /// In en, this message translates to:
  /// **'Garment name'**
  String get garmentName;

  /// No description provided for @garmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Green shirt, White pant'**
  String get garmentNameHint;

  /// No description provided for @garmentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one garment name'**
  String get garmentNameRequired;

  /// No description provided for @addGarment.
  ///
  /// In en, this message translates to:
  /// **'Add garment'**
  String get addGarment;

  /// No description provided for @orderGarments.
  ///
  /// In en, this message translates to:
  /// **'Garments in this order'**
  String get orderGarments;

  /// No description provided for @noMeasurementYet.
  ///
  /// In en, this message translates to:
  /// **'No measurement yet'**
  String get noMeasurementYet;

  /// No description provided for @updateMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Update measurement'**
  String get updateMeasurement;

  /// No description provided for @customerAdded.
  ///
  /// In en, this message translates to:
  /// **'Customer saved'**
  String get customerAdded;

  /// No description provided for @customerAddedOrderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create an order for this customer now?'**
  String get customerAddedOrderPrompt;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet — tap New order to start'**
  String get noOrdersYet;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @trialDate.
  ///
  /// In en, this message translates to:
  /// **'Trial date'**
  String get trialDate;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get deliveryDate;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance payment'**
  String get advancePayment;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get balanceDue;

  /// No description provided for @workflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get workflow;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversed;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @paymentKind.
  ///
  /// In en, this message translates to:
  /// **'Payment kind'**
  String get paymentKind;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @receiptJsonNote.
  ///
  /// In en, this message translates to:
  /// **'Receipt data from the server (PDF sharing not configured yet).'**
  String get receiptJsonNote;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add staff'**
  String get addStaff;

  /// No description provided for @upcomingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Upcoming deliveries & trials'**
  String get upcomingDeliveries;

  /// No description provided for @orderValue.
  ///
  /// In en, this message translates to:
  /// **'Order value'**
  String get orderValue;

  /// No description provided for @ordersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by status'**
  String get ordersByStatus;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @moduleNotReady.
  ///
  /// In en, this message translates to:
  /// **'Backend not ready'**
  String get moduleNotReady;

  /// No description provided for @moduleNotReadyHint.
  ///
  /// In en, this message translates to:
  /// **'UI is wired; this module needs Nest/Prisma APIs before end-to-end use.'**
  String get moduleNotReadyHint;

  /// No description provided for @manageShopHint.
  ///
  /// In en, this message translates to:
  /// **'Manage measurements, orders, staff, payments, and reports from here.'**
  String get manageShopHint;

  /// No description provided for @measurementsHint.
  ///
  /// In en, this message translates to:
  /// **'Add and view customer body measurements'**
  String get measurementsHint;

  /// No description provided for @templatesHint.
  ///
  /// In en, this message translates to:
  /// **'Shirt, blouse, and custom garment fields'**
  String get templatesHint;

  /// No description provided for @staffHint.
  ///
  /// In en, this message translates to:
  /// **'Invite managers and tailors'**
  String get staffHint;

  /// No description provided for @paymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Record advances and balances'**
  String get paymentsHint;

  /// No description provided for @calendarHint.
  ///
  /// In en, this message translates to:
  /// **'Trials and delivery dates'**
  String get calendarHint;

  /// No description provided for @reportsHint.
  ///
  /// In en, this message translates to:
  /// **'Collections and order totals'**
  String get reportsHint;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Order and payment alerts'**
  String get notificationsHint;

  /// No description provided for @comingSoonHint.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — screen opens with status'**
  String get comingSoonHint;

  /// No description provided for @shopSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Shop details and receipt settings'**
  String get shopSettingsHint;

  /// No description provided for @profileHint.
  ///
  /// In en, this message translates to:
  /// **'Your name, mobile, and photo'**
  String get profileHint;

  /// No description provided for @settingsHint.
  ///
  /// In en, this message translates to:
  /// **'Language and theme'**
  String get settingsHint;

  /// No description provided for @expensesHint.
  ///
  /// In en, this message translates to:
  /// **'Track daily shop expenses'**
  String get expensesHint;

  /// No description provided for @inventoryHint.
  ///
  /// In en, this message translates to:
  /// **'Fabric and material stock'**
  String get inventoryHint;

  /// No description provided for @stitchGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Save work photos and designs'**
  String get stitchGalleryHint;

  /// No description provided for @workerPaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Amounts paid to workers'**
  String get workerPaymentsHint;

  /// No description provided for @tasksProductionHint.
  ///
  /// In en, this message translates to:
  /// **'Cutting and stitching tasks'**
  String get tasksProductionHint;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet. Tap Add customer to start.'**
  String get noCustomersYet;

  /// No description provided for @measurementCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get measurementCategory;

  /// No description provided for @measurementCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one garment type — only its measurements will show'**
  String get measurementCategoryHint;

  /// No description provided for @addComponent.
  ///
  /// In en, this message translates to:
  /// **'Add component'**
  String get addComponent;

  /// No description provided for @componentName.
  ///
  /// In en, this message translates to:
  /// **'Component name'**
  String get componentName;

  /// No description provided for @componentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Elbow, Cuff width'**
  String get componentNameHint;

  /// No description provided for @helpTextOptional.
  ///
  /// In en, this message translates to:
  /// **'Help text (optional)'**
  String get helpTextOptional;

  /// No description provided for @selectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a category first'**
  String get selectCategoryFirst;

  /// No description provided for @catManShirt.
  ///
  /// In en, this message translates to:
  /// **'Man Shirt'**
  String get catManShirt;

  /// No description provided for @catManPant.
  ///
  /// In en, this message translates to:
  /// **'Man Pant'**
  String get catManPant;

  /// No description provided for @catManTshirt.
  ///
  /// In en, this message translates to:
  /// **'Man T-Shirt'**
  String get catManTshirt;

  /// No description provided for @catManPolo.
  ///
  /// In en, this message translates to:
  /// **'Man Polo'**
  String get catManPolo;

  /// No description provided for @catWomanBlouse.
  ///
  /// In en, this message translates to:
  /// **'Woman Blouse'**
  String get catWomanBlouse;

  /// No description provided for @catWomanKurta.
  ///
  /// In en, this message translates to:
  /// **'Woman Kurta'**
  String get catWomanKurta;

  /// No description provided for @pomHalfChest.
  ///
  /// In en, this message translates to:
  /// **'½ Chest'**
  String get pomHalfChest;

  /// No description provided for @pomHalfWaist.
  ///
  /// In en, this message translates to:
  /// **'½ Waist'**
  String get pomHalfWaist;

  /// No description provided for @pomShoulderHps.
  ///
  /// In en, this message translates to:
  /// **'Shoulder (HPS)'**
  String get pomShoulderHps;

  /// No description provided for @pomShoulderLength.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Length'**
  String get pomShoulderLength;

  /// No description provided for @pomSleeveLength.
  ///
  /// In en, this message translates to:
  /// **'Sleeve Length'**
  String get pomSleeveLength;

  /// No description provided for @pomHalfBicep.
  ///
  /// In en, this message translates to:
  /// **'½ Bicep'**
  String get pomHalfBicep;

  /// No description provided for @pomSleeveOpening.
  ///
  /// In en, this message translates to:
  /// **'Sleeve Opening'**
  String get pomSleeveOpening;

  /// No description provided for @pomArmhole.
  ///
  /// In en, this message translates to:
  /// **'Arm Hole'**
  String get pomArmhole;

  /// No description provided for @pomArmholeLength.
  ///
  /// In en, this message translates to:
  /// **'Arm Hole Length'**
  String get pomArmholeLength;

  /// No description provided for @pomBodyLength.
  ///
  /// In en, this message translates to:
  /// **'Body Length'**
  String get pomBodyLength;

  /// No description provided for @pomBodyLengthHps.
  ///
  /// In en, this message translates to:
  /// **'Body Length (HPS)'**
  String get pomBodyLengthHps;

  /// No description provided for @pomNeckCollar.
  ///
  /// In en, this message translates to:
  /// **'Neck / Collar'**
  String get pomNeckCollar;

  /// No description provided for @pomNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get pomNeck;

  /// No description provided for @pomNeckOpening.
  ///
  /// In en, this message translates to:
  /// **'Neck Opening'**
  String get pomNeckOpening;

  /// No description provided for @pomCollarStandLength.
  ///
  /// In en, this message translates to:
  /// **'Collar Stand Length'**
  String get pomCollarStandLength;

  /// No description provided for @pomCollarHeight.
  ///
  /// In en, this message translates to:
  /// **'Collar Height'**
  String get pomCollarHeight;

  /// No description provided for @pomCollarLength.
  ///
  /// In en, this message translates to:
  /// **'Collar Length'**
  String get pomCollarLength;

  /// No description provided for @pomCuff.
  ///
  /// In en, this message translates to:
  /// **'Cuff'**
  String get pomCuff;

  /// No description provided for @pomYoke.
  ///
  /// In en, this message translates to:
  /// **'Yoke'**
  String get pomYoke;

  /// No description provided for @pomHip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get pomHip;

  /// No description provided for @pomHalfThigh.
  ///
  /// In en, this message translates to:
  /// **'½ Thigh'**
  String get pomHalfThigh;

  /// No description provided for @pomThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get pomThigh;

  /// No description provided for @pomKnee.
  ///
  /// In en, this message translates to:
  /// **'Knee'**
  String get pomKnee;

  /// No description provided for @pomWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get pomWaist;

  /// No description provided for @pomLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get pomLength;

  /// No description provided for @pomChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get pomChest;

  /// No description provided for @pomShoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get pomShoulder;

  /// No description provided for @pomSleeve.
  ///
  /// In en, this message translates to:
  /// **'Sleeve'**
  String get pomSleeve;

  /// No description provided for @pomLegOpening.
  ///
  /// In en, this message translates to:
  /// **'Leg Opening'**
  String get pomLegOpening;

  /// No description provided for @pomOutseamLength.
  ///
  /// In en, this message translates to:
  /// **'Length (Outseam)'**
  String get pomOutseamLength;

  /// No description provided for @pomInseam.
  ///
  /// In en, this message translates to:
  /// **'Inseam'**
  String get pomInseam;

  /// No description provided for @pomFrontRise.
  ///
  /// In en, this message translates to:
  /// **'Front Rise'**
  String get pomFrontRise;

  /// No description provided for @pomBackRise.
  ///
  /// In en, this message translates to:
  /// **'Back Rise'**
  String get pomBackRise;

  /// No description provided for @pomBottomHem.
  ///
  /// In en, this message translates to:
  /// **'Bottom Hem'**
  String get pomBottomHem;

  /// No description provided for @pomBottomHemWidth.
  ///
  /// In en, this message translates to:
  /// **'Bottom Hem Width'**
  String get pomBottomHemWidth;

  /// No description provided for @pomPlacketLength.
  ///
  /// In en, this message translates to:
  /// **'Placket Length'**
  String get pomPlacketLength;

  /// No description provided for @pomBust.
  ///
  /// In en, this message translates to:
  /// **'Bust'**
  String get pomBust;

  /// No description provided for @pomFrontNeckDrop.
  ///
  /// In en, this message translates to:
  /// **'Front Neck Drop'**
  String get pomFrontNeckDrop;

  /// No description provided for @pomBackNeckDrop.
  ///
  /// In en, this message translates to:
  /// **'Back Neck Drop'**
  String get pomBackNeckDrop;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introGetStarted;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Measure with clarity'**
  String get intro1Title;

  /// No description provided for @intro1Tagline.
  ///
  /// In en, this message translates to:
  /// **'Capture every customer fit — chest, sleeve, waist — in one clean place.'**
  String get intro1Tagline;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Orders under control'**
  String get intro2Title;

  /// No description provided for @intro2Tagline.
  ///
  /// In en, this message translates to:
  /// **'Track cutting, stitching, trials, and delivery dates without paper chaos.'**
  String get intro2Tagline;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Grow your silai shop'**
  String get intro3Title;

  /// No description provided for @intro3Tagline.
  ///
  /// In en, this message translates to:
  /// **'Payments, customers, and reports — your tailoring business, connected.'**
  String get intro3Tagline;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your shop account in a minute.'**
  String get signUpSubtitle;

  /// No description provided for @uploadLogoOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload your logo or photo'**
  String get uploadLogoOrPhoto;

  /// No description provided for @uploadLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone only — shown on home & profile.'**
  String get uploadLogoHint;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @debugFill.
  ///
  /// In en, this message translates to:
  /// **'Debug fill'**
  String get debugFill;

  /// No description provided for @revenueOverview.
  ///
  /// In en, this message translates to:
  /// **'Revenue overview'**
  String get revenueOverview;

  /// No description provided for @statusChart.
  ///
  /// In en, this message translates to:
  /// **'Status chart'**
  String get statusChart;

  /// No description provided for @selectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected day'**
  String get selectedDay;

  /// No description provided for @trialMarker.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get trialMarker;

  /// No description provided for @deliveryMarker.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryMarker;

  /// No description provided for @noEventsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No trials or deliveries on this day'**
  String get noEventsOnDay;

  /// No description provided for @showAllUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Show all upcoming'**
  String get showAllUpcoming;

  /// No description provided for @addTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get addTemplate;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateName;

  /// No description provided for @templateCode.
  ///
  /// In en, this message translates to:
  /// **'Code (e.g. kurta)'**
  String get templateCode;

  /// No description provided for @templateCreated.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateCreated;

  /// No description provided for @templateExists.
  ///
  /// In en, this message translates to:
  /// **'A template with this code already exists'**
  String get templateExists;

  /// No description provided for @templateFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Starter measurement fields will be added. You can edit them later.'**
  String get templateFieldsHint;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get noInternet;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// No description provided for @shareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @whatsAppOrder.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get whatsAppOrder;

  /// No description provided for @phoneRequiredForWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Add the customer\'s phone number first'**
  String get phoneRequiredForWhatsApp;

  /// No description provided for @whatsAppOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get whatsAppOpenFailed;

  /// No description provided for @pdfCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create PDF'**
  String get pdfCreateFailed;

  /// No description provided for @pdfShared.
  ///
  /// In en, this message translates to:
  /// **'Invoice ready to share'**
  String get pdfShared;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated;
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
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
