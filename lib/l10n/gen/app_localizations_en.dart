// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get save => 'Save';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get more => 'More';

  @override
  String get difference => 'Difference';

  @override
  String get expenses => 'Expenses';

  @override
  String get incomes => 'Income';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get emptyMonth => 'No records this month';

  @override
  String recapClosed(String month) {
    return '$month wrapped up';
  }

  @override
  String recapRecords(int count) {
    return 'Records: $count';
  }

  @override
  String recapTop(String category) {
    return 'Biggest — $category';
  }

  @override
  String get hintRowActions => 'Tap a record to edit, swipe to delete';

  @override
  String get hintBreakdown => 'Tap “Expenses” to see where the money went';

  @override
  String get hintCategoryFilter => 'Tap a category circle for its records only';

  @override
  String get howtoSectionInput => 'Recording';

  @override
  String get howtoAmount =>
      'Type the amount on the pad. No cents — and no decimal point';

  @override
  String get howtoClear =>
      'Long-press ⌫ to clear the amount and the expression';

  @override
  String get howtoCalc =>
      'The bottom-left key is a calculator: + − × ÷ and =. It works left to right, with no operator precedence';

  @override
  String get howtoType =>
      'Tap the capsule on top to switch between expense and income. Categories switch with it';

  @override
  String get howtoMore =>
      '“More” opens every category. That is also where you create your own and pin 📌 it to the main screen';

  @override
  String get howtoSwipeUp => 'Swipe up to open history without saving anything';

  @override
  String get howtoSectionHistory => 'History';

  @override
  String get howtoEdit =>
      'Tap a record to edit its amount, category, note or date';

  @override
  String get howtoDelete =>
      'Swipe left to delete. “Undo” stays for a few seconds';

  @override
  String get howtoFilter =>
      'Tap a category circle to see only its records for the month';

  @override
  String get howtoBreakdown =>
      'Tap “Expenses” or “Income” for a breakdown by category, largest first';

  @override
  String get howtoMonths =>
      'The arrows beside the month move between months. Tap the month name to return to the current one';

  @override
  String get howtoSectionData => 'Your data';

  @override
  String get howtoLocal =>
      'Everything stays on this device. No account, no server, no sync';

  @override
  String get howtoBackup =>
      'Backup and restore live in Settings. That is the only way to move your data to another phone';

  @override
  String get howtoArchive =>
      'A category with records is archived rather than deleted, so history keeps its meaning';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptySubtitle => 'Record your first expense — it is quick';

  @override
  String get emptyAction => 'Record';

  @override
  String get deleted => 'Deleted';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String get archived => 'Archived';

  @override
  String get saveFailed => 'Could not save. Try again';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get editTitle => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get commentHint => 'Comment';

  @override
  String get addCategory => 'Add your own';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get categoryNameHint => 'Name';

  @override
  String get create => 'Create';

  @override
  String get allArchivedHint =>
      'All categories are archived — create a new one';

  @override
  String get backupReminder => 'It has been a while since the last backup';

  @override
  String get currencyTitle => 'Currency';

  @override
  String get currencyChangeNote =>
      'Applies to every record, old and new. Amounts stay as they are — nothing is converted';

  @override
  String get onboardingTagline => 'Expenses in two seconds';

  @override
  String onboardingCurrency(String symbol) {
    return 'Your currency: $symbol';
  }

  @override
  String get change => 'change';

  @override
  String get start => 'Start';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get haptics => 'Vibration';

  @override
  String get saveBackup => 'Save backup';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get archiveSection => 'Archive';

  @override
  String get restoreCategory => 'Restore';

  @override
  String get categoryHasRecords => 'Category has records — archived instead';

  @override
  String get howToUse => 'How to use';

  @override
  String aboutApp(String version) {
    return 'About · $version';
  }

  @override
  String get licenses => 'Licenses';

  @override
  String importInfo(int count, String from, String to) {
    return 'The file has $count transactions for $from – $to. Replace current data?';
  }

  @override
  String get importReplace => 'Replace';

  @override
  String get importAdd => 'Add';

  @override
  String get importInvalid => 'This is not a QVAS backup file';

  @override
  String get groupFood => 'Food';

  @override
  String get groupTransport => 'Transport';

  @override
  String get groupHome => 'Home';

  @override
  String get groupHealth => 'Health';

  @override
  String get groupFun => 'Fun';

  @override
  String get groupMoney => 'Money';

  @override
  String get groupOther => 'Other';

  @override
  String get a11yBackspace => 'Delete digit';

  @override
  String get a11yCalculator => 'Calculator';

  @override
  String get a11yPrevMonth => 'Previous month';

  @override
  String get a11yNextMonth => 'Next month';

  @override
  String get a11yFilterByCategory => 'Filter by category';

  @override
  String get a11yClearFilter => 'Clear filter';

  @override
  String get catCoffee => 'Coffee';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catCafe => 'Cafe';

  @override
  String get catTransport => 'Transport';

  @override
  String get catCar => 'Car';

  @override
  String get catHome => 'Home';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catPharmacy => 'Pharmacy';

  @override
  String get catClothes => 'Clothes';

  @override
  String get catGifts => 'Gifts';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catPhone => 'Phone';

  @override
  String get catPets => 'Pets';

  @override
  String get catBeauty => 'Beauty';

  @override
  String get catSport => 'Sport';

  @override
  String get catEducation => 'Education';

  @override
  String get catKids => 'Kids';

  @override
  String get catOther => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catIncomeGift => 'Gift';

  @override
  String get catCashback => 'Cashback';

  @override
  String get catInvestments => 'Investments';

  @override
  String get catRefund => 'Refund';

  @override
  String get catSale => 'Sale';

  @override
  String get catIncomeOther => 'Other';
}
