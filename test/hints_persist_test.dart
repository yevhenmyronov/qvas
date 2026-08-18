import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/models/hints.dart';
import 'package:qvas/repositories/settings_repository.dart';

/// Збереження маски підказок (рішення 89).
///
/// Пороги перевіряє `hints_test.dart`, але правильні пороги нічого не
/// варті, якщо факт показу не доїжджає до бази: підказка тоді
/// показується щоразу заново, а наступні не приходять ніколи.
void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
    await repo.ensureInitialized();
  });

  tearDown(() => db.close());

  Future<int> mask() async =>
      (await db.select(db.appSettings).getSingle()).hintsShown;

  test('нова база не має показаних підказок', () async {
    expect(await mask(), 0);
  });

  test('позначення зберігається', () async {
    await repo.markHintShown(AppHint.rowActions);
    expect(await mask(), AppHint.rowActions.bit);
  });

  test('друга підказка не стирає першу', () async {
    // Заради цього метод читає поточну маску перед записом, а не
    // перезаписує її числом.
    await repo.markHintShown(AppHint.rowActions);
    await repo.markHintShown(AppHint.breakdown);

    final m = await mask();
    expect(m & AppHint.rowActions.bit, isNonZero);
    expect(m & AppHint.breakdown.bit, isNonZero);
  });

  test('повторне позначення нічого не ламає', () async {
    await repo.markHintShown(AppHint.rowActions);
    await repo.markHintShown(AppHint.rowActions);
    expect(await mask(), AppHint.rowActions.bit);
  });

  test('після позначення pendingHint віддає наступну', () async {
    await repo.markHintShown(AppHint.rowActions);
    expect(
      pendingHint(
        shownMask: await mask(),
        monthRecords: 12,
        topCategoryRecords: 4,
      ),
      AppHint.breakdown,
    );
  });
}
