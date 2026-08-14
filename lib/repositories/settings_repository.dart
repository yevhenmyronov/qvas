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
          currencyCode: initialCurrencyCode,
          firstLaunchAt: DateTime.now().toUtc(),
        ));
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(_rowId)))
        .getSingle();
  }

  /// Валюта першого запуску. Перевизначається до ensureInitialized()
  /// автовизначенням із локалі (main.dart).
  String initialCurrencyCode = 'UAH';

  Future<AppSetting> get() {
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(_rowId)))
        .getSingle();
  }

  Stream<AppSetting?> watch() {
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(_rowId)))
        .watchSingleOrNull();
  }

  Future<void> _write(AppSettingsCompanion values) {
    return (_db.update(_db.appSettings)..where((s) => s.id.equals(_rowId)))
        .write(values)
        .then((_) {});
  }

  /// Впливає тільки на нові записи (Функціонал п.5).
  Future<void> setCurrency(String code) =>
      _write(AppSettingsCompanion(currencyCode: Value(code)));

  /// null = брати системну мову.
  Future<void> setLocaleOverride(String? locale) =>
      _write(AppSettingsCompanion(localeOverride: Value(locale)));

  Future<void> setHapticsEnabled(bool enabled) =>
      _write(AppSettingsCompanion(hapticsEnabled: Value(enabled)));

  Future<void> setOnboardingDone() =>
      _write(const AppSettingsCompanion(onboardingDone: Value(true)));

  Future<void> markBackupDone() => _write(AppSettingsCompanion(
      lastBackupAt: Value(DateTime.now().toUtc())));

  Future<void> dismissBackupBanner() => _write(
      const AppSettingsCompanion(backupBannerDismissed: Value(true)));
}
