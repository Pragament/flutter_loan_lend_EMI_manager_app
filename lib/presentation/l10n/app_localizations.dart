import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan & Lending EMI Manager'**
  String get appTitle;

  /// No description provided for @emi.
  ///
  /// In en, this message translates to:
  /// **'E.M.I'**
  String get emi;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan Amount'**
  String get loanAmount;

  /// No description provided for @tenure.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get tenure;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate'**
  String get interestRate;

  /// No description provided for @interestAmount.
  ///
  /// In en, this message translates to:
  /// **'Interest Amount'**
  String get interestAmount;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @completeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete Onboarding'**
  String get completeOnboarding;

  /// No description provided for @caroselHeading.
  ///
  /// In en, this message translates to:
  /// **'EMI Breakdown'**
  String get caroselHeading;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loan;

  /// No description provided for @lend.
  ///
  /// In en, this message translates to:
  /// **'Lend'**
  String get lend;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @contactPersonName.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name'**
  String get contactPersonName;

  /// No description provided for @contactPersonPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Phone'**
  String get contactPersonPhone;

  /// No description provided for @contactPersonEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Email'**
  String get contactPersonEmail;

  /// No description provided for @otherInfo.
  ///
  /// In en, this message translates to:
  /// **'Other Information'**
  String get otherInfo;

  /// No description provided for @processingFee.
  ///
  /// In en, this message translates to:
  /// **'Processing Fee'**
  String get processingFee;

  /// No description provided for @otherCharges.
  ///
  /// In en, this message translates to:
  /// **'Other Charges'**
  String get otherCharges;

  /// No description provided for @partPayment.
  ///
  /// In en, this message translates to:
  /// **'Part Payment'**
  String get partPayment;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment'**
  String get advancePayment;

  /// No description provided for @insuranceCharges.
  ///
  /// In en, this message translates to:
  /// **'Insurance Charges'**
  String get insuranceCharges;

  /// No description provided for @moratorium.
  ///
  /// In en, this message translates to:
  /// **'Moratorium'**
  String get moratorium;

  /// No description provided for @moratoriumMonth.
  ///
  /// In en, this message translates to:
  /// **'Moratorium Month'**
  String get moratoriumMonth;

  /// No description provided for @moratoriumType.
  ///
  /// In en, this message translates to:
  /// **'Moratorium Type'**
  String get moratoriumType;

  /// No description provided for @monthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'Monthly EMI'**
  String get monthlyEmi;

  /// No description provided for @totalEmi.
  ///
  /// In en, this message translates to:
  /// **'Total EMI'**
  String get totalEmi;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get enterAmount;

  /// No description provided for @enterInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter the interest rate'**
  String get enterInterestRate;

  /// No description provided for @enterStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter the start date'**
  String get enterStartDate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @legendInterestAmount.
  ///
  /// In en, this message translates to:
  /// **'Interest Amount'**
  String get legendInterestAmount;

  /// No description provided for @legendPrincipalAmount.
  ///
  /// In en, this message translates to:
  /// **'Principal Amount'**
  String get legendPrincipalAmount;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this EMI?'**
  String get areYouSure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @switchToMonths.
  ///
  /// In en, this message translates to:
  /// **'Switch to Months'**
  String get switchToMonths;

  /// No description provided for @switchToYears.
  ///
  /// In en, this message translates to:
  /// **'Switch to Years'**
  String get switchToYears;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @legendBalanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Balance Amount'**
  String get legendBalanceAmount;

  /// No description provided for @noTenure.
  ///
  /// In en, this message translates to:
  /// **'No Tenure'**
  String get noTenure;

  /// No description provided for @addEmi.
  ///
  /// In en, this message translates to:
  /// **'Add EMI'**
  String get addEmi;

  /// No description provided for @principalAmount.
  ///
  /// In en, this message translates to:
  /// **'principalAmount'**
  String get principalAmount;

  /// No description provided for @deleteEmi.
  ///
  /// In en, this message translates to:
  /// **'deleteEmi'**
  String get deleteEmi;

  /// No description provided for @emiPerMonth.
  ///
  /// In en, this message translates to:
  /// **'emiPerMonth'**
  String get emiPerMonth;

  /// No description provided for @aggregate.
  ///
  /// In en, this message translates to:
  /// **'aggregate'**
  String get aggregate;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'noDataAvailable'**
  String get noDataAvailable;

  /// No description provided for @noEmiMessage.
  ///
  /// In en, this message translates to:
  /// **'noEmiMessage'**
  String get noEmiMessage;

  /// No description provided for @amortizationTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Amortization Table'**
  String get amortizationTableTitle;

  /// No description provided for @manageTags.
  ///
  /// In en, this message translates to:
  /// **'manageTags'**
  String get manageTags;

  /// No description provided for @noEmis.
  ///
  /// In en, this message translates to:
  /// **'noEmis'**
  String get noEmis;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'selectLanguage'**
  String get selectLanguage;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get next;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the English version of our app. Here you can manage your loans and EMIs efficiently.'**
  String get welcome;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'te': return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
