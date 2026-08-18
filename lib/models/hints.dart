/// Підказки, що приходять у момент, коли стають доречними (рішення 89).
///
/// Не тур по інтерфейсу на першому запуску: тур забувають до того, як
/// він знадобиться, і він перериває найкращий момент продукту — перший
/// запис. Замість нього одна коротка репліка, прив'язана до порога,
/// показана **один раз за все життя застосунку**.
///
/// Це і є «поступове розкриття», тільки чесне: нічого не відкривається
/// штучно, функція була там від початку — застосунок лише вказує на неї
/// тоді, коли вона стає потрібною.
library;

/// Максимум три за все життя. Четверта — це вже туторіал.
enum AppHint {
  /// Після першого ж запису: на Екрані 2 рівно один рядок і більше
  /// нічого — найспокійніший і найпорожніший момент у продукті.
  rowActions(1, minMonthRecords: 1),

  /// Коли в місяці набралось на розкладку. Раніше вона безглузда: не
  /// буде чого показувати.
  breakdown(2, minMonthRecords: 10),

  /// Коли в одній категорії набралось стільки, що фільтр має сенс.
  categoryFilter(4, minTopCategoryRecords: 3);

  const AppHint(
    this.bit, {
    this.minMonthRecords = 0,
    this.minTopCategoryRecords = 0,
  });

  /// Позиція в масці `AppSettings.hintsShown`.
  final int bit;

  final int minMonthRecords;
  final int minTopCategoryRecords;
}

/// Яку підказку час показати — або `null`, якщо жодну.
///
/// **Не більше однієї за раз**, у порядку оголошення. При десяти
/// записах умови трьох підказок виконані одночасно, і показати їх усі
/// означало б зробити рівно той туторіал, від якого це рішення
/// відмовляється.
AppHint? pendingHint({
  required int shownMask,
  required int monthRecords,
  required int topCategoryRecords,
}) {
  for (final hint in AppHint.values) {
    final alreadyShown = shownMask & hint.bit != 0;
    if (alreadyShown) continue;
    if (monthRecords < hint.minMonthRecords) continue;
    if (topCategoryRecords < hint.minTopCategoryRecords) continue;
    return hint;
  }
  return null;
}

/// Скільки записів у найбільшій за кількістю категорії.
int topCategoryCount(Iterable<String> categoryIds) {
  final counts = <String, int>{};
  for (final id in categoryIds) {
    counts[id] = (counts[id] ?? 0) + 1;
  }
  return counts.values.fold(0, (a, b) => a > b ? a : b);
}
