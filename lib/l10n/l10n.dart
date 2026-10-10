import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Вбудовані категорії зберігаються ключем і перекладаються на льоту
/// (Функціонал п.6). Кастомні не перекладаються ніколи.
String categoryDisplayName(AppLocalizations l, Category? category) {
  if (category == null) return '';
  final key = category.nameKey;
  if (key == null) return category.customName ?? '';
  return builtInCategoryName(l, key);
}

String builtInCategoryName(AppLocalizations l, String nameKey) {
  return switch (nameKey) {
    'cat.coffee' => l.catCoffee,
    'cat.groceries' => l.catGroceries,
    'cat.cafe' => l.catCafe,
    'cat.transport' => l.catTransport,
    'cat.car' => l.catCar,
    'cat.home' => l.catHome,
    'cat.utilities' => l.catUtilities,
    'cat.pharmacy' => l.catPharmacy,
    'cat.clothes' => l.catClothes,
    'cat.gifts' => l.catGifts,
    'cat.entertainment' => l.catEntertainment,
    'cat.phone' => l.catPhone,
    'cat.pets' => l.catPets,
    'cat.beauty' => l.catBeauty,
    'cat.sport' => l.catSport,
    'cat.education' => l.catEducation,
    'cat.kids' => l.catKids,
    'cat.other' => l.catOther,
    'cat.salary' => l.catSalary,
    'cat.freelance' => l.catFreelance,
    'cat.income_gift' => l.catIncomeGift,
    'cat.cashback' => l.catCashback,
    'cat.investments' => l.catInvestments,
    'cat.refund' => l.catRefund,
    'cat.sale' => l.catSale,
    'cat.income_other' => l.catIncomeOther,
    _ => nameKey,
  };
}

/// «Серпень 2026» — шапка Екрана 2. Назви місяців дає intl (дані
/// ініціалізує GlobalMaterialLocalizations), перша літера — велика.
String monthTitle(String localeTag, int year, int month) {
  final raw = DateFormat('LLLL yyyy', localeTag).format(DateTime(year, month));
  return toBeginningOfSentenceCase(raw);
}

/// «Серпень – Жовтень 2026» — шапка Екрана 2 для періоду в кілька
/// місяців (рішення 102). Межі року рік несуть обидві сторони:
/// «Грудень 2025 – Лютий 2026».
String monthRangeTitle(
  String localeTag,
  ({int year, int month}) first,
  ({int year, int month}) last,
) {
  String name(int y, int m, String pattern) => toBeginningOfSentenceCase(
      DateFormat(pattern, localeTag).format(DateTime(y, m)));
  final end = name(last.year, last.month, 'LLLL yyyy');
  final start = first.year == last.year
      ? name(first.year, first.month, 'LLLL')
      : name(first.year, first.month, 'LLLL yyyy');
  return '$start – $end';
}

/// «13 серпня» / «August 13» — заголовок дня в стрічці.
///
/// День не з поточного року несе рік: «13 серпня 2025». Досі стрічка
/// завжди була одним місяцем, і рік стояв у шапці; у «За весь час»
/// (рішення 102) два різні серпні інакше читались би однаково.
/// [nowYear] підміняється в тестах.
String dayTitle(
  String localeTag,
  int year,
  int month,
  int day, {
  int? nowYear,
}) {
  final date = DateTime(year, month, day);
  if (year == (nowYear ?? DateTime.now().year)) {
    return DateFormat.MMMMd(localeTag).format(date);
  }
  // Український yMMMMd додає «р.» — у шапці місяця («Серпень 2026») його
  // немає, і заголовки дня не мають звучати офіційніше за неї.
  return DateFormat.yMMMMd(localeTag)
      .format(date)
      .replaceFirst(RegExp(r'\s*р\.$'), '');
}
