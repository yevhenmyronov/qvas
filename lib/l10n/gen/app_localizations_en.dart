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
  String todayTotal(String amount) {
    return 'Today: $amount';
  }

  @override
  String get emptyMonth => 'No records this month';

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
      'Applies to new records only. Old ones keep their currency';

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
  String get instructionSoon => 'The guide is coming soon';

  @override
  String aboutApp(String version) {
    return 'About · $version';
  }

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
