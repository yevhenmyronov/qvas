import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/tx_type.dart';

/// Єдина точка доступу UI до категорій.
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  /// Неархівовані категорії типу [type], у порядку sortOrder.
  Stream<List<Category>> watchActive(TxType type) {
    final q = _db.select(_db.categories)
      ..where((c) => c.type.equalsValue(type) & c.isArchived.equals(false))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return q.watch();
  }

  /// Усі категорії (включно з архівованими) за id — для відображення
  /// стрічки: архівована категорія має коректно показуватись у старих
  /// записах (Функціонал п.3).
  Stream<Map<String, Category>> watchAllById() {
    return _db.select(_db.categories).watch().map(
        (rows) => {for (final c in rows) c.id: c});
  }

  Future<Category> getById(String id) {
    return (_db.select(_db.categories)..where((c) => c.id.equals(id)))
        .getSingle();
  }

  /// Живий список усіх категорій (керування категоріями в налаштуваннях).
  Stream<List<Category>> watchAll() {
    final q = _db.select(_db.categories)
      ..orderBy([
        (c) => OrderingTerm.asc(c.type),
        (c) => OrderingTerm.asc(c.sortOrder),
      ]);
    return q.watch();
  }

  /// Усі категорії одним списком (для експорту й керування).
  Future<List<Category>> getAllOnce() {
    final q = _db.select(_db.categories)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return q.get();
  }

  /// Одноразове читання активних категорій типу (для розрахунку слотів).
  Future<List<Category>> getActiveOnce(TxType type) {
    final q = _db.select(_db.categories)
      ..where((c) => c.type.equalsValue(type) & c.isArchived.equals(false))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return q.get();
  }

  /// Створення власної категорії (Функціонал п.3.1). Тип успадковується
  /// з поточного режиму; назва не перекладається ніколи.
  Future<String> createCustom({
    required TxType type,
    required String name,
    required String emoji,
  }) async {
    final id = const Uuid().v4();
    final maxOrder = await (_db.selectOnly(_db.categories)
          ..addColumns([_db.categories.sortOrder.max()]))
        .getSingle()
        .then((r) => r.read(_db.categories.sortOrder.max()) ?? 0);
    await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          id: id,
          type: type,
          customName: Value(name),
          emoji: emoji,
          sortOrder: Value(maxOrder + 1),
          createdAt: DateTime.now().toUtc(),
        ));
    return id;
  }

  /// Закріплення — максимум 5 перевіряє UI перед викликом.
  Future<void> setPinned(String id, bool pinned) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id)))
        .write(CategoriesCompanion(isPinned: Value(pinned)));
  }

  /// Архівування замість видалення — історія транзакцій не ламається
  /// ніколи (Функціонал п.3).
  Future<void> setArchived(String id, bool archived) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id)))
        .write(CategoriesCompanion(isArchived: Value(archived)));
  }

  /// Чи має категорія хоч один запис. М'яко видалені теж рахуються —
  /// вони можуть повернутись через Undo, і їхня категорія мусить жити.
  Future<bool> hasTransactions(String id) async {
    final t = _db.transactions;
    final count = t.id.count();
    final q = _db.selectOnly(t)
      ..addColumns([count])
      ..where(t.categoryId.equals(id));
    final row = await q.getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  /// Фізичне видалення (рішення 49). Дозволене тільки для категорій без
  /// жодного запису — UI перевіряє hasTransactions перед викликом;
  /// категорія із записами лише архівується, історія не ламається ніколи.
  Future<void> deleteCategory(String id) {
    return (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  /// Повернення щойно видаленої категорії — Undo тосту видалення.
  Future<void> insertExisting(Category category) {
    return _db.into(_db.categories).insert(category);
  }

  /// Кеш Smart Categories (тех. спека п.4): при старті читається готовий
  /// склад, агрегація не виконується.
  Future<({List<String> ids, String computedOn})?> readRankingCache(
      TxType type) async {
    final q = _db.select(_db.categoryRankingCache)
      ..where((r) => r.type.equalsValue(type))
      ..orderBy([(r) => OrderingTerm.asc(r.position)]);
    final rows = await q.get();
    if (rows.isEmpty) return null;
    return (
      ids: [for (final r in rows) r.categoryId],
      computedOn: rows.first.computedOn,
    );
  }

  Future<void> writeRankingCache(
    TxType type,
    List<String> ids,
    Map<String, int> ranks,
    String computedOn,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.categoryRankingCache)
            ..where((r) => r.type.equalsValue(type)))
          .go();
      await _db.batch((b) {
        b.insertAll(_db.categoryRankingCache, [
          for (final (i, id) in ids.indexed)
            CategoryRankingCacheCompanion.insert(
              type: type,
              position: i,
              categoryId: id,
              rank: ranks[id] ?? 0,
              computedOn: computedOn,
            ),
        ]);
      });
    });
  }
}
