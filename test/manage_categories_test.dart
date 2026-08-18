import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/l10n/emoji_set.dart';
import 'package:qvas/l10n/gen/app_localizations.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/core_providers.dart';
import 'package:qvas/theme/tokens.dart';
import 'package:qvas/ui/common/type_capsule.dart';
import 'package:qvas/ui/settings/manage_categories_screen.dart';

/// Створення категорії з керування категоріями (рішення 93).
///
/// Перевіряється не наявність кнопки, а те, заради чого вона з'явилась:
/// звідси категорія створюється БЕЗ Екрана 1, тобто без режиму, з якого
/// шторка досі успадковувала тип. Тип, що мовчки лишився б витратою, на
/// пристрої виявляється аж тоді, коли дохід не знаходиться у своєму
/// списку, — тож інваріант записаний тут.
void main() {
  setUpAll(_loadFonts);

  testWidgets('нова категорія створюється з типом, обраним у шторці', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());

    await _pump(tester, db);

    await tester.tap(find.text('＋ Додати свою'));
    await tester.pumpAndSettle();

    expect(find.text('Нова категорія'), findsOneWidget);

    // Успадковувати тип нема від чого — замість підпису стоїть капсула.
    final capsule = find.byType(TypeCapsule);
    expect(capsule, findsOneWidget);
    expect(find.text('Витрата'), findsOneWidget);

    await tester.tap(capsule);
    await tester.pumpAndSettle();
    expect(find.text('Дохід'), findsOneWidget);

    final emoji = emojiGroups.first.emojis.first;
    await tester.tap(find.text('🙂'));
    await tester.pumpAndSettle();
    // Саме в сітці пікера: той самий гліф стоїть і в списку категорій
    // під шторкою, і без уточнення тап пішов би туди.
    await tester.tap(
      find
          .descendant(of: find.byType(GridView), matching: find.text(emoji))
          .first,
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Премія');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Створити'));
    await tester.pumpAndSettle();

    final created = await (db.select(
      db.categories,
    )..where((c) => c.customName.equals('Премія'))).getSingle();
    expect(created.type, TxType.income);
    expect(created.emoji, emoji);

    // Шторка закрилась, а список під нею вже показує створене.
    expect(find.text('Нова категорія'), findsNothing);
    expect(find.text('Премія'), findsOneWidget);

    // Рішення 94: розділи по типах, а щойно створена — перша у своєму.
    // Обидва інваріанти про порядок, тож звіряються позиціями.
    double top(String text) => tester.getRect(find.text(text)).top;

    expect(top('Витрати'), lessThan(top('Кава')));
    expect(
      top('Кава'),
      lessThan(top('Доходи')),
      reason: 'витрати йдуть повністю до доходів',
    );
    expect(top('Доходи'), lessThan(top('Премія')));
    expect(
      top('Премія'),
      lessThan(top('Зарплата')),
      reason: 'щойно створену не треба шукати — вона перша у розділі',
    );

    // Дерево знімається й база закривається в тілі тесту: drift при
    // закритті підписок ставить таймер нульової тривалості, а розібраний
    // на прибиранні ProviderScope лишив би його висіти вже після кінця
    // тесту — і прогін падав би на «A Timer is still pending».
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await db.close();
  });
}

Future<void> _pump(WidgetTester tester, AppDatabase db) async {
  // Високе вікно, щоб увесь список був побудований: перевіряються
  // саме взаємні позиції розділів, а не поведінка скролу.
  tester.view.physicalSize = const Size(400, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('uk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ManageCategoriesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Без шрифту кожен гліф має ширину em, і заголовок екрана не влазить у
/// свій рядок — тобто тест ловив би переповнення тестового шрифту.
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
