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
}
