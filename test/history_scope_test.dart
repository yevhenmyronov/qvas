import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/l10n/l10n.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/core_providers.dart';
import 'package:qvas/providers/history_providers.dart';
import 'package:qvas/repositories/transaction_repository.dart';

/// Період Екрана 2 (рішення 102): місяць, 3 чи 6 місяців або весь час,
/// а метрики, стрічка й розкладка йдуть за ним.
///
/// Сценарій із догфудингу: зарплата приходить 2-го, тож вересень
/// закривається в мінус, жовтень — у плюс, і лише разом вони кажуть
/// правду.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> add(String dateKey, TxType type, int amountMinor) async {
    final repo = container.read(transactionRepositoryProvider);
    final id = await repo.insert(
      type: type,
      amountMinor: amountMinor,
      categoryId: builtInCategoryId(
        (type == TxType.income
                ? builtInIncomeCategories
                : builtInExpenseCategories)
            .first
            .nameKey,
      ),
      currencyCode: 'UAH',
    );
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(id))).getSingle();
    await repo.applyEdit(
      original: tx,
      amountMinor: amountMinor,
      categoryId: tx.categoryId,
      note: null,
      dateKey: dateKey,
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        selectedMonthProvider.overrideWith(
          () => SelectedMonthController(now: () => const MonthKey(2026, 10)),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    // Поза трьома місяцями, але в шести.
    await add('2026-06-15', TxType.expense, 500000);
    // Поза шістьма — тільки у «за весь час».
    await add('2026-03-10', TxType.income, 100000);
    await add('2026-09-02', TxType.income, 3000000);
    await add('2026-09-20', TxType.expense, 3200000);
    await add('2026-10-02', TxType.income, 3000000);
    await add('2026-10-05', TxType.expense, 1000000);
  });

  Future<MonthTotal> totals() async {
    final sub = container.listen(monthTotalsProvider, (_, _) {});
    addTearDown(sub.close);
    return container.read(monthTotalsProvider.future);
  }

  test('за замовчуванням — місяць', () async {
    container
        .read(selectedMonthProvider.notifier)
        .show(const MonthKey(2026, 9));
    final t = await totals();
    expect(t.earnedMinor - t.spentMinor, -200000);
  });

  void scope(HistoryScope s) =>
      container.read(historyScopeProvider.notifier).state = s;

  test('3 місяці — серпень–жовтень', () async {
    scope(HistoryScope.months3);
    final t = await totals();
    expect(t.earnedMinor, 6000000);
    expect(t.spentMinor, 4200000);
  });

  test('6 місяців — травень–жовтень', () async {
    scope(HistoryScope.months6);
    final t = await totals();
    expect(t.earnedMinor, 6000000);
    expect(t.spentMinor, 4700000);
  });

  test('весь час складає всі місяці', () async {
    scope(HistoryScope.allTime);
    final t = await totals();
    expect(t.earnedMinor, 6100000);
    expect(t.spentMinor, 4700000);
  });

  test('3 місяці через межу року', () {
    container
        .read(selectedMonthProvider.notifier)
        .show(const MonthKey(2027, 1));
    scope(HistoryScope.months3);
    expect(container.read(periodProvider),
        (start: '2026-11-01', end: '2027-01-31'));
  });

  test('стрічка й розкладка йдуть за періодом', () async {
    scope(HistoryScope.allTime);
    final feedSub = container.listen(monthFeedProvider, (_, _) {});
    final breakdownSub = container.listen(
      categoryBreakdownProvider(TxType.expense),
      (_, _) {},
    );
    addTearDown(feedSub.close);
    addTearDown(breakdownSub.close);

    expect(await container.read(monthFeedProvider.future), hasLength(6));
    final breakdown = await container.read(
      categoryBreakdownProvider(TxType.expense).future,
    );
    expect(breakdown.single.totalMinor, 4700000);
  });

  group('заголовки', () {
    setUpAll(() async {
      await initializeDateFormatting('uk');
      await initializeDateFormatting('en');
    });

    test('діапазон місяців', () {
      expect(
        monthRangeTitle('uk', (year: 2026, month: 8), (year: 2026, month: 10)),
        'Серпень – Жовтень 2026',
      );
      expect(
        monthRangeTitle('uk', (year: 2025, month: 12), (year: 2026, month: 2)),
        'Грудень 2025 – Лютий 2026',
      );
      expect(
        monthRangeTitle('en', (year: 2026, month: 5), (year: 2026, month: 10)),
        'May – October 2026',
      );
    });

    test('день поточного року — без року', () {
      expect(dayTitle('uk', 2026, 8, 13, nowYear: 2026), '13 серпня');
    });

    test('день іншого року — з роком, без «р.»', () {
      expect(dayTitle('uk', 2025, 8, 13, nowYear: 2026), '13 серпня 2025');
      expect(dayTitle('en', 2025, 8, 13, nowYear: 2026), 'August 13, 2025');
    });
  });
}
