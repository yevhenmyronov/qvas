import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
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

/// «Сьогодні: 450 ₴».
final todayExpenseProvider = StreamProvider<int>((ref) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchDayExpenseTotal(localDateKeyOf(DateTime.now()));
});
