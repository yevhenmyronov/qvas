import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/hints.dart';

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
    if (existing != null) {
      await _alignTransactionCurrency(existing.currencyCode);
      return existing;
    }

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

  /// Спадок ери «валюта в кожному записі» (до рішення 57): у базі, що
  /// пережила зміну валюти на старій збірці, лежать записи в обох.
  /// Приводимо їх до поточної один раз — далі інваріант тримає
  /// [setCurrency]. Спершу рахуємо: у нормальній базі це один COUNT
  /// на запуск і жодного запису.
  Future<void> _alignTransactionCurrency(String code) async {
    final t = _db.transactions;
    final count = t.id.count();
    final row = await (_db.selectOnly(t)
          ..addColumns([count])
          ..where(t.currencyCode.equals(code).not()))
        .getSingle();
    if ((row.read(count) ?? 0) == 0) return;
    await _db
        .update(t)
        .write(TransactionsCompanion(currencyCode: Value(code)));
  }

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

  /// Валюта глобальна, як мова (рішення 57): змінилась — змінилась у
  /// всьому застосунку, включно зі старими записами. Конвертації немає
  /// і не буде: суми лишаються ті самі, змінюється лише позначка того,
  /// в чому вони записані.
  ///
  /// Колонка в транзакціях переписується, а не ігнорується при показі:
  /// інакше експорт віддавав би валюту, якої в застосунку вже немає.
  /// Це і є єдине місце, що тримає інваріант «у базі одна валюта».
  Future<void> setCurrency(String code) => _db.transaction(() async {
        await _write(AppSettingsCompanion(currencyCode: Value(code)));
        await _db
            .update(_db.transactions)
            .write(TransactionsCompanion(currencyCode: Value(code)));
      });

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

  /// Позначає підказку показаною — назавжди (рішення 89).
  ///
  /// Дописує біт до поточної маски, а не перезаписує її: інакше дві
  /// підказки, показані в одній сесії, стирали б одна одну.
  Future<void> markHintShown(AppHint hint) => _db.transaction(() async {
        final current = await (_db.select(_db.appSettings)
              ..where((s) => s.id.equals(_rowId)))
            .getSingleOrNull();
        if (current == null) return;
        await _write(AppSettingsCompanion(
            hintsShown: Value(current.hintsShown | hint.bit)));
      });
}
