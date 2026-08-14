/// Усі рядки інтерфейсу в одному місці. v0.1 — тільки українська (хардкод,
/// рішення плану v0.1). Міграція на ARB у v0.2 буде механічною, бо жоден
/// рядок не живе в екранах.
abstract final class AppStrings {
  // Екран 1
  static const save = 'Зберегти';
  static const expense = 'Витрата';
  static const income = 'Дохід';
  static const more = 'Більше';
  static const history = 'Історія';

  // Екран 2
  static const difference = 'Різниця';
  static const expenses = 'Витрати';
  static const incomes = 'Доходи';
  static const today = 'Сьогодні';
  static const yesterday = 'Учора';
  static String todayTotal(String amount) => 'Сьогодні: $amount';
  static const emptyMonth = 'У цьому місяці записів немає';
  static const emptyTitle = 'Тут поки порожньо';
  static const emptySubtitle = 'Запиши першу витрату — це швидко';
  static const emptyAction = 'Записати';

  // Видалення
  static const deleted = 'Видалено';
  static const undo = 'Скасувати';
  static const delete = 'Видалити';

  // Помилки
  static const saveFailed = 'Не вдалося зберегти. Спробуй ще раз';

  // Шторки
  static const categoriesTitle = 'Категорії';
  static const archived = 'Архівовано';
  static const editTitle = 'Редагувати';
  static const search = 'Пошук';
  static const commentHint = 'Коментар';

  // Місяці. Хардкод замість intl-даних: нуль ініціалізації на старті,
  // повний контроль над відмінками.
  static const monthsNominative = [
    'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
    'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень',
  ];
  static const monthsGenitive = [
    'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
    'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
  ];

  /// «Серпень 2026» — шапка Екрана 2.
  static String monthTitle(int year, int month) =>
      '${monthsNominative[month - 1]} $year';

  /// «13 серпня» — заголовок дня в стрічці.
  static String dayTitle(int day, int month) =>
      '$day ${monthsGenitive[month - 1]}';

  // Назви вбудованих категорій: nameKey → мітка.
  static const categoryNames = <String, String>{
    // Витрати
    'cat.coffee': 'Кава',
    'cat.groceries': 'Продукти',
    'cat.cafe': 'Кафе',
    'cat.transport': 'Транспорт',
    'cat.car': 'Авто',
    'cat.home': 'Дім',
    'cat.utilities': 'Комуналка',
    'cat.pharmacy': 'Аптека',
    'cat.clothes': 'Одяг',
    'cat.gifts': 'Подарунки',
    'cat.entertainment': 'Розваги',
    'cat.phone': 'Звʼязок',
    'cat.pets': 'Тварини',
    'cat.beauty': 'Краса',
    'cat.sport': 'Спорт',
    'cat.education': 'Освіта',
    'cat.kids': 'Діти',
    'cat.other': 'Інше',
    // Доходи
    'cat.salary': 'Зарплата',
    'cat.freelance': 'Фріланс',
    'cat.income_gift': 'Подарунок',
    'cat.cashback': 'Кешбек',
    'cat.investments': 'Інвестиції',
    'cat.refund': 'Повернення',
    'cat.sale': 'Продаж',
    'cat.income_other': 'Інше',
  };

  static String categoryName(String nameKey) =>
      categoryNames[nameKey] ?? nameKey;
}
