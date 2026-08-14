import 'package:drift/drift.dart';

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

  /// Одноразове читання активних категорій типу (для розрахунку слотів).
  Future<List<Category>> getActiveOnce(TxType type) {
    final q = _db.select(_db.categories)
      ..where((c) => c.type.equalsValue(type) & c.isArchived.equals(false))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return q.get();
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
