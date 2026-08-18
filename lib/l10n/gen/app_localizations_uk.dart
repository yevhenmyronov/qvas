// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get save => 'Зберегти';

  @override
  String get expense => 'Витрата';

  @override
  String get income => 'Дохід';

  @override
  String get more => 'Більше';

  @override
  String get difference => 'Різниця';

  @override
  String get expenses => 'Витрати';

  @override
  String get incomes => 'Доходи';

  @override
  String get today => 'Сьогодні';

  @override
  String get yesterday => 'Учора';

  @override
  String get emptyMonth => 'У цьому місяці записів немає';

  @override
  String recapClosed(String month) {
    return '$month закрито';
  }

  @override
  String recapRecords(int count) {
    return 'Записів: $count';
  }

  @override
  String recapTop(String category) {
    return 'Найбільше — $category';
  }

  @override
  String get hintRowActions => 'Тап по запису — редагувати, свайп — видалити';

  @override
  String get hintBreakdown => 'Тап по «Витрати» — куди пішли гроші';

  @override
  String get hintCategoryFilter =>
      'Тап по кружечку категорії — тільки її записи';

  @override
  String get howtoSectionInput => 'Запис';

  @override
  String get howtoAmount =>
      'Сума набирається падом. Копійок немає — крапки на паді теж';

  @override
  String get howtoClear => 'Довге натискання ⌫ — очистити суму й вираз';

  @override
  String get howtoCalc =>
      'Ліва нижня клітинка — калькулятор: + − × ÷ і =. Рахує зліва направо, без пріоритету операцій';

  @override
  String get howtoType =>
      'Тап по капсулі вгорі перемикає витрату й дохід. Категорії міняються разом із нею';

  @override
  String get howtoMore =>
      '«Більше» відкриває всі категорії. Там же створюється своя і закріплюється 📌 на головний екран';

  @override
  String get howtoSwipeUp =>
      'Свайп угору відкриває історію, нічого не зберігаючи';

  @override
  String get howtoSectionHistory => 'Історія';

  @override
  String get howtoEdit =>
      'Тап по запису — редагувати суму, категорію, коментар або дату';

  @override
  String get howtoDelete =>
      'Свайп вліво — видалити. Кілька секунд буде «Скасувати»';

  @override
  String get howtoFilter =>
      'Тап по кружечку категорії — тільки її записи за місяць';

  @override
  String get howtoBreakdown =>
      'Тап по «Витрати» або «Доходи» — розкладка за категоріями, від найбільшої';

  @override
  String get howtoMonths =>
      'Стрілки біля назви місяця гортають місяці. Тап по назві повертає до поточного';

  @override
  String get howtoSectionData => 'Дані';

  @override
  String get howtoLocal =>
      'Усе зберігається лише на цьому пристрої. Немає ні акаунта, ні сервера, ні синхронізації';

  @override
  String get howtoBackup =>
      'Резервна копія й відновлення — у Налаштуваннях. Це єдиний спосіб перенести дані на інший телефон';

  @override
  String get howtoArchive =>
      'Категорія із записами не видаляється, а архівується — щоб історія не втратила сенс';

  @override
  String get emptyTitle => 'Тут поки порожньо';

  @override
  String get emptySubtitle => 'Запиши першу витрату — це швидко';

  @override
  String get emptyAction => 'Записати';

  @override
  String get deleted => 'Видалено';

  @override
  String get undo => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get archived => 'Архівовано';

  @override
  String get saveFailed => 'Не вдалося зберегти. Спробуй ще раз';

  @override
  String get categoriesTitle => 'Категорії';

  @override
  String get editTitle => 'Редагувати';

  @override
  String get search => 'Пошук';

  @override
  String get commentHint => 'Коментар';

  @override
  String get addCategory => 'Додати свою';

  @override
  String get newCategoryTitle => 'Нова категорія';

  @override
  String get categoryNameHint => 'Назва';

  @override
  String get create => 'Створити';

  @override
  String get allArchivedHint => 'Усі категорії заархівовані — створи нову';

  @override
  String get backupReminder => 'Давно не було резервної копії';

  @override
  String get currencyTitle => 'Валюта';

  @override
  String get currencyChangeNote =>
      'Змінюється для всіх записів — і старих, і нових. Суми лишаються ті самі, перерахунку за курсом немає';

  @override
  String get onboardingTagline => 'Витрати за дві секунди';

  @override
  String onboardingCurrency(String symbol) {
    return 'Твоя валюта: $symbol';
  }

  @override
  String get change => 'змінити';

  @override
  String get start => 'Почати';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Системна';

  @override
  String get haptics => 'Вібрація';

  @override
  String get saveBackup => 'Зберегти резервну копію';

  @override
  String get exportCsv => 'Експортувати в CSV';

  @override
  String get restoreBackup => 'Відновити з резервної копії';

  @override
  String get manageCategories => 'Керування категоріями';

  @override
  String get archiveSection => 'Архів';

  @override
  String get restoreCategory => 'Повернути';

  @override
  String get categoryHasRecords => 'У категорії є записи — заархівовано';

  @override
  String get howToUse => 'Як користуватися';

  @override
  String aboutApp(String version) {
    return 'Про застосунок · $version';
  }

  @override
  String importInfo(int count, String from, String to) {
    return 'У файлі $count транзакцій за період $from – $to. Замінити поточні дані?';
  }

  @override
  String get importReplace => 'Замінити';

  @override
  String get importAdd => 'Додати';

  @override
  String get importInvalid => 'Це не файл резервної копії QVAS';

  @override
  String get groupFood => 'Їжа';

  @override
  String get groupTransport => 'Транспорт';

  @override
  String get groupHome => 'Дім';

  @override
  String get groupHealth => 'Здоров\'я';

  @override
  String get groupFun => 'Розваги';

  @override
  String get groupMoney => 'Гроші';

  @override
  String get groupOther => 'Інше';

  @override
  String get a11yBackspace => 'Стерти цифру';

  @override
  String get a11yCalculator => 'Калькулятор';

  @override
  String get a11yPrevMonth => 'Попередній місяць';

  @override
  String get a11yNextMonth => 'Наступний місяць';

  @override
  String get a11yFilterByCategory => 'Фільтр за категорією';

  @override
  String get a11yClearFilter => 'Скинути фільтр';

  @override
  String get catCoffee => 'Кава';

  @override
  String get catGroceries => 'Продукти';

  @override
  String get catCafe => 'Кафе';

  @override
  String get catTransport => 'Транспорт';

  @override
  String get catCar => 'Авто';

  @override
  String get catHome => 'Дім';

  @override
  String get catUtilities => 'Комуналка';

  @override
  String get catPharmacy => 'Аптека';

  @override
  String get catClothes => 'Одяг';

  @override
  String get catGifts => 'Подарунки';

  @override
  String get catEntertainment => 'Розваги';

  @override
  String get catPhone => 'Звʼязок';

  @override
  String get catPets => 'Тварини';

  @override
  String get catBeauty => 'Краса';

  @override
  String get catSport => 'Спорт';

  @override
  String get catEducation => 'Освіта';

  @override
  String get catKids => 'Діти';

  @override
  String get catOther => 'Інше';

  @override
  String get catSalary => 'Зарплата';

  @override
  String get catFreelance => 'Фріланс';

  @override
  String get catIncomeGift => 'Подарунок';

  @override
  String get catCashback => 'Кешбек';

  @override
  String get catInvestments => 'Інвестиції';

  @override
  String get catRefund => 'Повернення';

  @override
  String get catSale => 'Продаж';

  @override
  String get catIncomeOther => 'Інше';
}
