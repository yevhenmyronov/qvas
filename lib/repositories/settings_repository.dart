import 'package:drift/drift.dart';

import '../db/database.dart';

/// Налаштування — один рядок з id = 1.
class SettingsRepository {
  SettingsRepository(this._db);

  static const _rowId = 1;

  final AppDatabase _db;

  /// Створює рядок при першому запуску (v0.1: валюта UAH захардкожена,
  /// firstLaunchAt ставиться один раз і більше не змінюється).
  Future<AppSetting> ensureInitialized() async {
    final existing = await (_db.select(_db.appSettings)
          ..where((s) => s.id.equals(_rowId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await _db.into(_db.appSettings).insert(AppSettingsCompanion.insert(
          id: const Value(_rowId),
          currencyCode: 'UAH',
          firstLaunchAt: DateTime.now().toUtc(),
        ));
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(_rowId)))
        .getSingle();
  }
}
