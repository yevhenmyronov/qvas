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

/// «Сьогодні: 450 ₴».
final todayExpenseProvider = StreamProvider<int>((ref) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchDayExpenseTotal(localDateKeyOf(DateTime.now()));
});
