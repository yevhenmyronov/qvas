import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/dates.dart';
import '../models/smart_categories.dart';
import '../models/tx_type.dart';

/// Підсумки місяця. Валюта в застосунку одна (рішення 57), тож групувати
/// нічого — беремо її з налаштувань уже при показі.
typedef MonthTotal = ({int spentMinor, int earnedMinor});

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

  /// Три метрики за місяць одним проходом (тех. спека п.3).
  Stream<MonthTotal> watchMonthTotals(int year, int month) {
    final t = _db.transactions;
    final spent = t.amountMinor.sum(
        filter: t.type.equalsValue(TxType.expense));
    final earned = t.amountMinor.sum(
        filter: t.type.equalsValue(TxType.income));
    final q = _db.selectOnly(t)
      ..addColumns([spent, earned])
      ..where(t.deletedAt.isNull() &
          t.localDateKey.isBetweenValues(
              monthStartKey(year, month), monthEndKey(year, month)));
    return q.watchSingle().map((r) => (
          spentMinor: r.read(spent) ?? 0,
          earnedMinor: r.read(earned) ?? 0,
        ));
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
  /// [id] можна передати ззовні — підсвічування нового рядка має знати
  /// його ще до завершення запису.
  Future<String> insert({
    required TxType type,
    required int amountMinor,
    required String categoryId,
    required String currencyCode,
    String? note,
    String? id,
  }) async {
    id ??= _uuid.v4();
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

  /// Ранжування Smart Categories за 30 днів (тех. спека п.3):
  /// кількість транзакцій і остання дата використання по категоріях.
  Future<List<CategoryRank>> rankSince(TxType type, String sinceKey) async {
    final t = _db.transactions;
    final count = t.id.count();
    final lastUsed = t.createdAtUtc.max();
    final q = _db.selectOnly(t)
      ..addColumns([t.categoryId, count, lastUsed])
      ..where(t.deletedAt.isNull() &
          t.type.equalsValue(type) &
          t.localDateKey.isBiggerOrEqualValue(sinceKey))
      ..groupBy([t.categoryId]);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          categoryId: r.read(t.categoryId)!,
          rank: r.read(count) ?? 0,
          lastUsed: r.read(lastUsed),
        ),
    ];
  }

  /// Межі наявних даних (min/max localDateKey живих записів) — для
  /// блокування стрілок навігації по місяцях (Функціонал п.4.1).
  /// null — записів немає взагалі.
  Stream<({String min, String max})?> watchDataBounds() {
    final t = _db.transactions;
    final minKey = t.localDateKey.min();
    final maxKey = t.localDateKey.max();
    final q = _db.selectOnly(t)
      ..addColumns([minKey, maxKey])
      ..where(t.deletedAt.isNull());
    return q.watchSingle().map((r) {
      final min = r.read(minKey);
      final max = r.read(maxKey);
      if (min == null || max == null) return null;
      return (min: min, max: max);
    });
  }

  /// Редагування зі шторки (Функціонал п.4.5). При зміні дати запис
  /// переноситься на новий день зі збереженням часу доби: createdAtUtc
  /// зсувається на різницю днів, localDateKey перераховується
  /// (тех. спека п.2.3).
  Future<void> applyEdit({
    required Transaction original,
    required int amountMinor,
    required String categoryId,
    required String? note,
    required String dateKey,
  }) {
    var createdAtUtc = original.createdAtUtc;
    if (dateKey != original.localDateKey) {
      final o = parseDateKey(original.localDateKey);
      final n = parseDateKey(dateKey);
      final dayDiff = DateTime(n.year, n.month, n.day)
          .difference(DateTime(o.year, o.month, o.day));
      createdAtUtc = createdAtUtc.add(dayDiff);
    }
    return (_db.update(_db.transactions)
          ..where((t) => t.id.equals(original.id)))
        .write(TransactionsCompanion(
      amountMinor: Value(amountMinor),
      categoryId: Value(categoryId),
      note: Value(note),
      localDateKey: Value(dateKey),
      createdAtUtc: Value(createdAtUtc),
    ));
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

  /// Усі живі записи для експорту, хронологічно (найновіші зверху).
  Future<List<Transaction>> getAllLive() {
    final q = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.localDateKey),
        (t) => OrderingTerm.desc(t.createdAtUtc),
      ]);
    return q.get();
  }

  /// Кількість живих записів — для банера-нагадування про бекап.
  Future<int> liveCount() async {
    final t = _db.transactions;
    final count = t.id.count();
    final q = _db.selectOnly(t)
      ..addColumns([count])
      ..where(t.deletedAt.isNull());
    final row = await q.getSingle();
    return row.read(count) ?? 0;
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
