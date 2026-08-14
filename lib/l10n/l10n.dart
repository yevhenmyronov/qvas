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

/// «13 серпня» / «August 13» — заголовок дня в стрічці.
String dayTitle(String localeTag, int year, int month, int day) {
  return DateFormat.MMMMd(localeTag).format(DateTime(year, month, day));
}
