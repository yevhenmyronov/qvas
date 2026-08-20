import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('uk'),
  ];

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @incomes.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomes;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @emptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No records this month'**
  String get emptyMonth;

  /// No description provided for @recapClosed.
  ///
  /// In en, this message translates to:
  /// **'{month} wrapped up'**
  String recapClosed(String month);

  /// No description provided for @recapRecords.
  ///
  /// In en, this message translates to:
  /// **'Records: {count}'**
  String recapRecords(int count);

  /// No description provided for @recapTop.
  ///
  /// In en, this message translates to:
  /// **'Biggest — {category}'**
  String recapTop(String category);

  /// No description provided for @hintRowActions.
  ///
  /// In en, this message translates to:
  /// **'Tap a record to edit, swipe to delete'**
  String get hintRowActions;

  /// No description provided for @hintBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Tap “Expenses” to see where the money went'**
  String get hintBreakdown;

  /// No description provided for @hintCategoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Tap a category circle for its records only'**
  String get hintCategoryFilter;

  /// No description provided for @howtoSectionInput.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get howtoSectionInput;

  /// No description provided for @howtoAmount.
  ///
  /// In en, this message translates to:
  /// **'Type the amount on the pad. No cents — and no decimal point'**
  String get howtoAmount;

  /// No description provided for @howtoClear.
  ///
  /// In en, this message translates to:
  /// **'Long-press ⌫ to clear the amount and the expression'**
  String get howtoClear;

  /// No description provided for @howtoCalc.
  ///
  /// In en, this message translates to:
  /// **'The bottom-left key is a calculator: + − × ÷ and =. It works left to right, with no operator precedence'**
  String get howtoCalc;

  /// No description provided for @howtoType.
  ///
  /// In en, this message translates to:
  /// **'Tap the capsule on top to switch between expense and income. Categories switch with it'**
  String get howtoType;

  /// No description provided for @howtoMore.
  ///
  /// In en, this message translates to:
  /// **'“More” opens every category. That is also where you create your own and pin 📌 it to the main screen'**
  String get howtoMore;

  /// No description provided for @howtoSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to open history without saving anything'**
  String get howtoSwipeUp;

  /// No description provided for @howtoSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get howtoSectionHistory;

  /// No description provided for @howtoEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap a record to edit its amount, category, note or date'**
  String get howtoEdit;

  /// No description provided for @howtoDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete. “Undo” stays for a few seconds'**
  String get howtoDelete;

  /// No description provided for @howtoFilter.
  ///
  /// In en, this message translates to:
  /// **'Tap a category circle to see only its records for the month'**
  String get howtoFilter;

  /// No description provided for @howtoBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Tap “Expenses” or “Income” for a breakdown by category, largest first'**
  String get howtoBreakdown;

  /// No description provided for @howtoMonths.
  ///
  /// In en, this message translates to:
  /// **'The arrows beside the month move between months. Tap the month name to return to the current one'**
  String get howtoMonths;

  /// No description provided for @howtoSectionData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get howtoSectionData;

  /// No description provided for @howtoLocal.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this device. No account, no server, no sync'**
  String get howtoLocal;

  /// No description provided for @howtoBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore live in Settings. That is the only way to move your data to another phone'**
  String get howtoBackup;

  /// No description provided for @howtoArchive.
  ///
  /// In en, this message translates to:
  /// **'A category with records is archived rather than deleted, so history keeps its meaning'**
  String get howtoArchive;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record your first expense — it is quick'**
  String get emptySubtitle;

  /// No description provided for @emptyAction.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get emptyAction;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again'**
  String get saveFailed;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentHint;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your own'**
  String get addCategory;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @allArchivedHint.
  ///
  /// In en, this message translates to:
  /// **'All categories are archived — create a new one'**
  String get allArchivedHint;

  /// No description provided for @backupReminder.
  ///
  /// In en, this message translates to:
  /// **'It has been a while since the last backup'**
  String get backupReminder;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTitle;

  /// No description provided for @currencyChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Applies to every record, old and new. Amounts stay as they are — nothing is converted'**
  String get currencyChangeNote;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Expenses in two seconds'**
  String get onboardingTagline;

  /// No description provided for @onboardingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Your currency: {symbol}'**
  String onboardingCurrency(String symbol);

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'change'**
  String get change;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get haptics;

  /// No description provided for @saveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get saveBackup;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @archiveSection.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveSection;

  /// No description provided for @restoreCategory.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreCategory;

  /// No description provided for @categoryHasRecords.
  ///
  /// In en, this message translates to:
  /// **'Category has records — archived instead'**
  String get categoryHasRecords;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About · {version}'**
  String aboutApp(String version);

  /// Settings row that opens the third-party license page
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @importInfo.
  ///
  /// In en, this message translates to:
  /// **'The file has {count} transactions for {from} – {to}. Replace current data?'**
  String importInfo(int count, String from, String to);

  /// No description provided for @importReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplace;

  /// No description provided for @importAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get importAdd;

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is not a QVAS backup file'**
  String get importInvalid;

  /// No description provided for @groupFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get groupFood;

  /// No description provided for @groupTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get groupTransport;

  /// No description provided for @groupHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get groupHome;

  /// No description provided for @groupHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get groupHealth;

  /// No description provided for @groupFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get groupFun;

  /// No description provided for @groupMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get groupMoney;

  /// No description provided for @groupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get groupOther;

  /// No description provided for @a11yBackspace.
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get a11yBackspace;

  /// No description provided for @a11yCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get a11yCalculator;

  /// No description provided for @a11yPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get a11yPrevMonth;

  /// No description provided for @a11yNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get a11yNextMonth;

  /// No description provided for @a11yFilterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get a11yFilterByCategory;

  /// No description provided for @a11yClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get a11yClearFilter;

  /// No description provided for @catCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get catCoffee;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get catCafe;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get catCar;

  /// No description provided for @catHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get catHome;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get catPharmacy;

  /// No description provided for @catClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get catClothes;

  /// No description provided for @catGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get catGifts;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get catPhone;

  /// No description provided for @catPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get catPets;

  /// No description provided for @catBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get catBeauty;

  /// No description provided for @catSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get catSport;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get catKids;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catIncomeGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catIncomeGift;

  /// No description provided for @catCashback.
  ///
  /// In en, this message translates to:
  /// **'Cashback'**
  String get catCashback;

  /// No description provided for @catInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get catInvestments;

  /// No description provided for @catRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get catRefund;

  /// No description provided for @catSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get catSale;

  /// No description provided for @catIncomeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catIncomeOther;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
