import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/l10n/gen/app_localizations.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/category_providers.dart';
import 'package:qvas/providers/core_providers.dart';
import 'package:qvas/theme/tokens.dart';
import 'package:qvas/ui/input/amount_display.dart';
import 'package:qvas/ui/input/category_bubbles.dart';
import 'package:qvas/ui/input/input_screen.dart';
import 'package:qvas/ui/input/type_switch.dart';

/// Розкладка Екрана 1 не має залежати від того, ЯКІ саме категорії
/// показані.
///
/// Приводом був живий баг: сума над бульбашками смикалась при кожному
/// перемиканні Витрата ↔ Дохід. Причина не в сумі — ряд бульбашок
/// загорнутий у `FittedBox`, а той масштабує рівномірно, тож ряд, який
/// не влазив по ширині, ставав ще й НИЖЧИМ. Висота блоку виходила
/// функцією від довжини назв: два набори категорій — дві різні висоти —
/// і все, що стоїть вище, з'їжджало на частку пікселя.
///
/// На око така величина не діагностується — її видно тільки як «щось
/// смикнулось». Тому інваріант записаний числом: сума стоїть на місці.
void main() {
  setUpAll(_loadFonts);

  testWidgets('перемикання типу не рухає суму', (tester) async {
    await _pump(tester);

    final before = tester.getRect(find.byType(AmountDisplay));
    final bubblesBefore = tester.getRect(find.byType(CategoryBubbles));

    await tester.tap(find.byType(TypeSwitch));
    await tester.pumpAndSettle();

    // Набір бульбашок мусить справді змінитись — інакше тест перевіряв
    // би, що незмінне лишилось незмінним.
    expect(
      find.text('Зарплата'),
      findsOneWidget,
      reason: 'після перемикання мають бути категорії доходів',
    );
    expect(tester.getRect(find.byType(AmountDisplay)), before);

    // Блок бульбашок звіряється по вертикалі, а не цілим прямокутником:
    // ширина в нього по вмісту й від набору залежати МАЄ. Не має —
    // висота, бо саме через неї зсув доходив до всього, що вище.
    final bubblesAfter = tester.getRect(find.byType(CategoryBubbles));
    expect(bubblesAfter.top, bubblesBefore.top);
    expect(bubblesAfter.height, bubblesBefore.height);
  });

  testWidgets('висота блоку бульбашок не залежить від довжини назв', (
    tester,
  ) async {
    await _pump(tester);
    final short = tester.getRect(find.byType(CategoryBubbles)).height;

    await _pump(tester, longNames: true);
    final long = tester.getRect(find.byType(CategoryBubbles)).height;

    expect(long, short,
        reason: 'ряд, що не влазить по ширині, має стискатись, а не нижчати');
  });
}

Future<void> _pump(WidgetTester tester, {bool longNames = false}) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _base(longNames: longNames),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('uk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const InputScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Без шрифту всі назви мали б нульову ширину, і найширший ряд перестав
/// би бути найширшим — тобто тест перевіряв би порожнечу.
Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final name in const [
    'Inter-Regular',
    'Inter-Medium',
    'Inter-SemiBold',
    'Inter-Bold',
    'Inter-ExtraBold',
  ]) {
    inter.addFont(_bytes(File('assets/fonts/$name.ttf')));
  }
  await inter.load();
}

Future<ByteData> _bytes(File file) =>
    file.readAsBytes().then((b) => ByteData.view(b.buffer));

final _settings = AppSetting(
  id: 1,
  currencyCode: 'UAH',
  localeOverride: 'uk',
  onboardingDone: true,
  firstLaunchAt: DateTime.utc(2026, 1, 1),
  lastBackupAt: DateTime.utc(2026, 8, 1),
  backupBannerDismissed: true,
  hapticsEnabled: true,
  hintsShown: 0,
);

Category _category(
  String id,
  TxType type,
  String? name,
  String emoji, {
  int order = 0,
}) {
  return Category(
    id: id,
    type: type,
    nameKey: null,
    customName: name,
    emoji: emoji,
    isBuiltIn: false,
    isPinned: false,
    isArchived: false,
    sortOrder: order,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

final _expense = [
  _category('e1', TxType.expense, 'Продукти', '🛒'),
  _category('e2', TxType.expense, 'Транспорт', '🚌', order: 1),
  _category('e3', TxType.expense, 'Кава', '☕', order: 2),
  _category('e4', TxType.expense, 'Дім', '🏠', order: 3),
  _category('e5', TxType.expense, 'Аптека', '💊', order: 4),
];

final _income = [
  _category('i1', TxType.income, 'Зарплата', '💰'),
  _category('i2', TxType.income, 'Фріланс', '💻', order: 1),
  _category('i3', TxType.income, 'Подарунок', '🎁', order: 2),
  _category('i4', TxType.income, 'Інвестиції', '📈', order: 3),
  _category('i5', TxType.income, 'Кешбек', '💳', order: 4),
];

/// Свідомо задовгі назви: ряд гарантовано не влазить у 400dp і
/// масштабується — саме той випадок, у якому висота й «попливла».
final _long = [
  _category('l1', TxType.expense, 'Комунальні платежі', '🏠'),
  _category('l2', TxType.expense, 'Громадський транспорт', '🚌', order: 1),
  _category('l3', TxType.expense, 'Продукти й побутове', '🛒', order: 2),
  _category('l4', TxType.expense, 'Медицина та аптека', '💊', order: 3),
  _category('l5', TxType.expense, 'Розваги й підписки', '🎬', order: 4),
];

List<Override> _base({required bool longNames}) {
  List<Category> forType(TxType type) {
    if (longNames) return _long;
    return type == TxType.income ? _income : _expense;
  }

  return [
    settingsProvider.overrideWith((ref) => Stream.value(_settings)),
    categoriesByIdProvider.overrideWith(
      (ref) => Stream.value({
        for (final c in [..._expense, ..._income, ..._long]) c.id: c,
      }),
    ),
    activeCategoriesProvider.overrideWith(
      (ref, type) => Stream.value(forType(type)),
    ),
    topCategoriesProvider.overrideWith((ref, type) => forType(type)),
  ];
}
