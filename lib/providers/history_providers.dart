import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/currency.dart';
import '../models/dates.dart';
import '../repositories/transaction_repository.dart';
import 'core_providers.dart';

/// Місяць, який зараз відкритий на Екрані 2.
class MonthKey {
  const MonthKey(this.year, this.month);

  final int year;
  final int month;

  factory MonthKey.now() {
    final n = DateTime.now();
    return MonthKey(n.year, n.month);
  }

  MonthKey get prev =>
      month == 1 ? MonthKey(year - 1, 12) : MonthKey(year, month - 1);

  MonthKey get next =>
      month == 12 ? MonthKey(year + 1, 1) : MonthKey(year, month + 1);

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

final selectedMonthProvider =
    StateProvider<MonthKey>((ref) => MonthKey.now());

/// Стрічка вибраного місяця (живі записи, найновіші зверху).
final monthFeedProvider = StreamProvider<List<Transaction>>((ref) {
  final m = ref.watch(selectedMonthProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonth(m.year, m.month);
});

/// Метрики вибраного місяця, згруповані по валютах.
final monthTotalsProvider = StreamProvider<List<MonthTotal>>((ref) {
  final m = ref.watch(selectedMonthProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthTotals(m.year, m.month);
});

/// Фільтр стрічки за категорією (Функціонал п.4.7): id категорії або null.
/// autoDispose — стан ефемерний: вихід з Екрана 2 скидає фільтр.
final categoryFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Стрічка місяця з урахуванням фільтра за категорією.
final filteredFeedProvider =
    Provider.autoDispose<List<Transaction>>((ref) {
  final feed = ref.watch(monthFeedProvider).value ?? const [];
  final filter = ref.watch(categoryFilterProvider);
  if (filter == null) return feed;
  return [
    for (final tx in feed)
      if (tx.categoryId == filter) tx,
  ];
});

/// Підсумок відфільтрованої стрічки по валютах, у порядку першої появи
/// валюти. Валюти ніколи не складаються (Функціонал п.5).
List<CurrencyTotal> filterTotalsOf(Iterable<Transaction> transactions) {
  final order = <String>[];
  final sums = <String, int>{};
  for (final tx in transactions) {
    final code = tx.currencyCode;
    if (!sums.containsKey(code)) order.add(code);
    sums[code] = (sums[code] ?? 0) + tx.amountMinor;
  }
  return [
    for (final code in order)
      (currencyCode: code, totalMinor: sums[code]!),
  ];
}

/// Межі даних для блокування стрілок місяців.
final dataBoundsProvider =
    StreamProvider<({String min, String max})?>((ref) {
  return ref.watch(transactionRepositoryProvider).watchDataBounds();
});

/// Чи є в базі хоч один живий запис — розрізняє «перший запуск»
/// і «порожній місяць» (Екрани п.3.2 / п.3.3).
final hasAnyDataProvider = Provider<bool>((ref) {
  return ref.watch(dataBoundsProvider).value != null;
});

/// Дозволений діапазон місяців: місяці з даними + поточний місяць
/// (стартова точка). Стрілка за межі гасне.
final monthRangeProvider = Provider<({MonthKey first, MonthKey last})>((ref) {
  final bounds = ref.watch(dataBoundsProvider).value;
  final now = MonthKey.now();
  if (bounds == null) return (first: now, last: now);
  final minP = parseDateKey(bounds.min);
  final maxP = parseDateKey(bounds.max);
  final dataFirst = MonthKey(minP.year, minP.month);
  final dataLast = MonthKey(maxP.year, maxP.month);
  return (
    first: _isBefore(dataFirst, now) ? dataFirst : now,
    last: _isBefore(now, dataLast) ? dataLast : now,
  );
});

bool _isBefore(MonthKey a, MonthKey b) =>
    a.year < b.year || (a.year == b.year && a.month < b.month);

/// Банер «давно не було резервної копії» (Функціонал п.7.3): понад 60 днів
/// без бекапу і більше 100 записів. Закривається назавжди одним тапом.
final backupReminderProvider = FutureProvider<bool>((ref) async {
  final s = ref.watch(settingsProvider).value;
  if (s == null || s.backupBannerDismissed) return false;
  final last = s.lastBackupAt;
  final stale = last == null ||
      DateTime.now().toUtc().difference(last) > const Duration(days: 60);
  if (!stale) return false;
  final count =
      await ref.watch(transactionRepositoryProvider).liveCount();
  return count > 100;
});

/// «Сьогодні: 450 ₴» — по валютах, як і решта підсумків.
final todayExpenseProvider = StreamProvider<List<CurrencyTotal>>((ref) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchDayExpenseTotals(localDateKeyOf(DateTime.now()));
});
