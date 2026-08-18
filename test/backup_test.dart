import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/services/backup.dart';

void main() {
  final settings = AppSetting(
    id: 1,
    currencyCode: 'UAH',
    localeOverride: null,
    onboardingDone: true,
    firstLaunchAt: DateTime.utc(2026, 8, 1),
    lastBackupAt: null,
    backupBannerDismissed: false,
    hapticsEnabled: true,
    hintsShown: 0,
  );

  final category = Category(
    id: 'cat-1',
    type: TxType.expense,
    nameKey: 'cat.coffee',
    customName: null,
    emoji: '☕',
    isBuiltIn: true,
    isPinned: true,
    isArchived: false,
    sortOrder: 0,
    createdAt: DateTime.utc(2026, 8, 1, 10),
  );

  final tx = Transaction(
    id: 'tx-1',
    type: TxType.expense,
    amountMinor: 8500,
    categoryId: 'cat-1',
    currencyCode: 'UAH',
    createdAtUtc: DateTime.utc(2026, 8, 13, 11, 32, 4),
    localDateKey: '2026-08-13',
    note: 'Кава з другом',
    deletedAt: null,
  );

  test('round-trip: серіалізація → розбір без втрат', () {
    final map = buildBackupMap(
      settings: settings,
      categories: [category],
      transactions: [tx],
      exportedAt: DateTime.utc(2026, 8, 14, 18),
    );
    final parsed = parseBackupMap(map);

    expect(parsed.currencyCode, 'UAH');
    expect(parsed.count, 1);
    expect(parsed.period, (from: '08.2026', to: '08.2026'));

    final c = parsed.categories.single;
    expect(c.id.value, 'cat-1');
    expect(c.type.value, TxType.expense);
    expect(c.nameKey.value, 'cat.coffee');
    expect(c.isPinned.value, isTrue);

    final t = parsed.transactions.single;
    expect(t.id.value, 'tx-1');
    expect(t.amountMinor.value, 8500);
    expect(t.createdAtUtc.value, DateTime.utc(2026, 8, 13, 11, 32, 4));
    expect(t.localDateKey.value, '2026-08-13');
    expect(t.note.value, 'Кава з другом');
  });

  test('чужий файл відхиляється', () {
    expect(() => parseBackupMap({'app': 'other'}),
        throwsA(isA<FormatException>()));
  });

  test('новіша схема відхиляється, стара приймається', () {
    expect(
      () => parseBackupMap({'app': 'qvas', 'schemaVersion': 99}),
      throwsA(isA<FormatException>()),
    );
    final parsed = parseBackupMap({
      'app': 'qvas',
      'schemaVersion': 1,
      'settings': <String, Object?>{},
    });
    expect(parsed.count, 0);
    expect(parsed.period, isNull);
  });

  test('CSV: колонки за спекою, мажорні одиниці, екранування ком', () {
    final withComma = Transaction(
      id: 'tx-2',
      type: TxType.income,
      amountMinor: 200000,
      categoryId: 'cat-1',
      currencyCode: 'UAH',
      createdAtUtc: DateTime.utc(2026, 8, 13, 12),
      localDateKey: '2026-08-13',
      note: 'аванс, серпень',
      deletedAt: null,
    );
    final csv = buildCsv(
      [tx, withComma],
      {'cat-1': category},
      (c) => c?.nameKey == 'cat.coffee' ? 'Кава' : '?',
    );
    final lines = csv.trim().split('\r\n');
    expect(lines.first, 'date,type,category,amount,currency,note');
    expect(lines[1], '2026-08-13,expense,Кава,85,UAH,Кава з другом');
    expect(lines[2], '2026-08-13,income,Кава,2000,UAH,"аванс, серпень"');
  });
}
