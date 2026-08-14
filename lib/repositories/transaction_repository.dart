import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/dates.dart';
import '../models/tx_type.dart';

/// Підсумки місяця по одній валюті. Валюти ніколи не складаються між собою
/// (Функціонал п.5) — тому список, а не одне число.
typedef MonthTotal = ({String currencyCode, int spentMinor, int earnedMinor});

/// Єдина точка доступу UI до транзакцій. UI ніколи не звертається до Drift
/// напряму (тех. спека п.1.2).
class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Стрічка місяця: живі записи, найновіші зверху
  /// (день ↓, момент запису ↓).
  Stream<List<Transaction>> watchMonth(int year, int month) {
    final q = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..where((t) => t.localDateKey.isBetweenValues(
          monthStartKey(year, month), monthEndKey(year, month)))
      ..orderBy([
        (t) => OrderingTerm.desc(t.localDateKey),
        (t) => OrderingTerm.desc(t.createdAtUtc),
      ]);
    return q.watch();
  }

  /// Три метрики за місяць одним проходом, згруповані по валютах
  /// (тех. спека п.3).
  Stream<List<MonthTotal>> watchMonthTotals(int year, int month) {
    final t = _db.transactions;
    final spent = t.amountMinor.sum(
        filter: t.type.equalsValue(TxType.expense));
    final earned = t.amountMinor.sum(
        filter: t.type.equalsValue(TxType.income));
    final q = _db.selectOnly(t)
      ..addColumns([t.currencyCode, spent, earned])
      ..where(t.deletedAt.isNull() &
          t.localDateKey.isBetweenValues(
              monthStartKey(year, month), monthEndKey(year, month)))
      ..groupBy([t.currencyCode]);
    return q.watch().map((rows) => [
          for (final r in rows)
            (
              currencyCode: r.read(t.currencyCode)!,
              spentMinor: r.read(spent) ?? 0,
              earnedMinor: r.read(earned) ?? 0,
            ),
        ]);
  }

  /// «Сьогодні: 450 ₴» — витрачено за день [dateKey].
  Stream<int> watchDayExpenseTotal(String dateKey) {
    final t = _db.transactions;
    final total = t.amountMinor.sum();
    final q = _db.selectOnly(t)
      ..addColumns([total])
      ..where(t.deletedAt.isNull() &
          t.type.equalsValue(TxType.expense) &
          t.localDateKey.equals(dateKey));
    return q.watchSingle().map((r) => r.read(total) ?? 0);
  }

  /// Записує транзакцію. Дата й localDateKey беруться в момент збереження,
  /// не в момент відкриття екрана (Функціонал п.11).
  Future<String> insert({
    required TxType type,
    required int amountMinor,
    required String categoryId,
    required String currencyCode,
    String? note,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: id,
          type: type,
          amountMinor: amountMinor,
          categoryId: categoryId,
          currencyCode: currencyCode,
          createdAtUtc: now.toUtc(),
          localDateKey: localDateKeyOf(now),
          note: Value(note),
        ));
    return id;
  }

  /// М'яке видалення заради Undo (тех. спека п.2.5).
  Future<void> softDelete(String id) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(deletedAt: Value(DateTime.now().toUtc())));
  }

  Future<void> restore(String id) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
        .write(const TransactionsCompanion(deletedAt: Value(null)));
  }

  /// Фонове прибирання при старті: записи, видалені понад 30 днів тому,
  /// стираються фізично. Викликається поза UI-потоком запуску.
  Future<void> purgeDeleted() {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    return (_db.delete(_db.transactions)
          ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
