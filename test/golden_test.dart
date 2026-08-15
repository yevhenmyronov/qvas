import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/l10n/gen/app_localizations.dart';
import 'package:qvas/models/amount_input.dart';
import 'package:qvas/models/dates.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/category_providers.dart';
import 'package:qvas/providers/core_providers.dart';
import 'package:qvas/providers/history_providers.dart';
import 'package:qvas/providers/input_providers.dart';
import 'package:qvas/theme/tokens.dart';
import 'package:qvas/ui/history/history_screen.dart';
import 'package:qvas/ui/input/input_screen.dart';

/// Знімки верстки — те, чого не ловить жоден інший тест у репозиторії.
///
/// Решта тестів перевіряє логіку й межі: скільки коштує запис, чи можна
/// його зберегти, чи не протік хардкод у палітру. Жоден із них не
/// помітить, якщо відступ поїде на 8dp, кнопка втратить світло по
/// верхній грані або від'ємна «Різниця» знову стане білою. Саме такі
/// регресії й з'їдають візуальну роботу — тихо, по одній, між іншими
/// змінами.
///
/// **Знімки прив'язані до цієї машини.** Порівняння побайтне, а
/// растеризація залежить від версії Skia й платформи. Репозиторій
/// локальний і розробник один, тож це прийнятно; щойно з'явиться CI —
/// знімки треба буде або перегенерувати там, або винести за поріг
/// допуску.
///
/// Оновлювати після НАВМИСНОЇ зміни верстки:
///
///     flutter test test/golden_test.dart --update-goldens
///
/// і обов'язково подивитись на diff очима. Знімок, оновлений не
/// глянувши, гірший за його відсутність: він створює враження, що
/// верстку перевірили.
void main() {
  setUpAll(_loadFonts);

  testWidgets('Екран 1 — порожній', (tester) async {
    await _pump(tester, home: const InputScreen(), overrides: _base());
    await expectLater(
      find.byType(InputScreen),
      matchesGoldenFile('goldens/input_empty.png'),
    );
  });

  testWidgets('Екран 1 — сума й категорія зійшлись', (tester) async {
    // Головна зміна стану Екрана 1: «Зберегти» оживає й заливається
    // кольором (рішення 65). Стан, заради якого існує весь екран.
    await _pump(tester, home: const InputScreen(), overrides: _base());

    final container = ProviderScope.containerOf(
      tester.element(find.byType(InputScreen)),
    );
    container.read(inputProvider.notifier)
      ..setAmount(const AmountInput(current: 450))
      ..setCategory('cat-coffee');
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(InputScreen),
      matchesGoldenFile('goldens/input_ready.png'),
    );
  });

  testWidgets('Екран 2 — місяць у плюсі', (tester) async {
    await _pump(
      tester,
      home: const HistoryScreen(),
      overrides: _base(totals: (spentMinor: 128000, earnedMinor: 340000)),
    );
    await expectLater(
      find.byType(HistoryScreen),
      matchesGoldenFile('goldens/history_positive.png'),
    );
  });

  testWidgets('Екран 2 — від\'ємна «Різниця»', (tester) async {
    // Окремий знімок навмисно: це єдине місце, де колір [AppColors.warn]
    // взагалі з'являється, і саме він зараз порушує правило DS
    // «червоний означає ТІЛЬКИ видалення». Поки правило призупинене,
    // хай принаймні буде видно, на що саме дивимось.
    await _pump(
      tester,
      home: const HistoryScreen(),
      overrides: _base(totals: (spentMinor: 340000, earnedMinor: 128000)),
    );
    await expectLater(
      find.byType(HistoryScreen),
      matchesGoldenFile('goldens/history_negative.png'),
    );
  });

  testWidgets('Екран 2 — фільтр за категорією', (tester) async {
    await _pump(tester, home: const HistoryScreen(), overrides: _base());

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HistoryScreen)),
    );
    container.read(categoryFilterProvider.notifier).state = 'cat-coffee';
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HistoryScreen),
      matchesGoldenFile('goldens/history_filtered.png'),
    );
  });
}

// --- Оточення ------------------------------------------------------------

/// Розмір поверхні. Не «як на POCO», а рівне число: знімок має бути
/// відтворюваним, а не схожим на конкретний апарат.
const _surface = Size(400, 860);

Future<void> _pump(
  WidgetTester tester, {
  required Widget home,
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = _surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('uk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Шрифти в тесті не підвантажуються самі — без цього весь текст на
/// знімку був би порожнечею, а іконки лишились би квадратами.
///
/// Емодзі свідомо НЕ вантажимо. Свого емодзі-шрифту застосунок не несе
/// (на пристрої їх малює система), а підсунути сюди віндовий
/// `seguiemj.ttf` означало б знімати верстку з гліфами, яких на Android
/// не буде. Порожній квадрат чесніший: він каже «тут емодзі» й не
/// вдає, ніби показує те, що побачить користувач.
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

  // Іконки лежать не в проєкті, а в кеші SDK. Саме вони — половина
  // того, що Етап 4 зводив у AppIconButton, тож знімок без них
  // перевіряв би лише порожні 48-точки.
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!icons.existsSync()) return;
  await (FontLoader('MaterialIcons')..addFont(_bytes(icons))).load();
}

Future<ByteData> _bytes(File file) =>
    file.readAsBytes().then((b) => ByteData.view(b.buffer));

// --- Фікстури ------------------------------------------------------------

/// Дата, якої ніколи не буде «сьогодні» вдруге: заголовок другого дня
/// мусить лишатись тим самим рядком через рік після зйомки.
const _pastKey = '2026-03-14';

final _settings = AppSetting(
  id: 1,
  currencyCode: 'UAH',
  localeOverride: 'uk',
  onboardingDone: true,
  firstLaunchAt: DateTime.utc(2026, 1, 1),
  lastBackupAt: DateTime.utc(2026, 8, 1),
  // Банер вимкнений: він з'являється за календарем, а знімок від
  // календаря залежати не має.
  backupBannerDismissed: true,
  hapticsEnabled: true,
);

Category _category(String id, String key, String emoji, {int order = 0}) {
  return Category(
    id: id,
    type: TxType.expense,
    nameKey: key,
    customName: null,
    emoji: emoji,
    isBuiltIn: true,
    isPinned: false,
    isArchived: false,
    sortOrder: order,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

final _categories = [
  _category('cat-coffee', 'cat.coffee', '☕'),
  _category('cat-transport', 'cat.transport', '🚌', order: 1),
  _category('cat-groceries', 'cat.groceries', '🛒', order: 2),
  _category('cat-home', 'cat.home', '🏠', order: 3),
  _category('cat-pharmacy', 'cat.pharmacy', '💊', order: 4),
];

Transaction _tx(
  String id,
  int minor,
  String categoryId,
  String dateKey, {
  String? note,
  TxType type = TxType.expense,
  int hour = 12,
}) {
  return Transaction(
    id: id,
    type: type,
    amountMinor: minor,
    categoryId: categoryId,
    currencyCode: 'UAH',
    createdAtUtc: DateTime.utc(2026, 8, 1, hour),
    localDateKey: dateKey,
    note: note,
    deletedAt: null,
  );
}

/// Перша група — сьогоднішня, щоб знімок ловив і заголовок «Сьогодні», і
/// теплий колір свіжого дня (рішення 71). Друга — з фіксованою датою,
/// тобто від годинника не залежить.
List<Transaction> _feed() {
  final today = localDateKeyOf(DateTime.now());
  return [
    _tx('tx-1', 8500, 'cat-coffee', today, note: 'Кава з другом', hour: 18),
    _tx('tx-2', 24000, 'cat-groceries', today, hour: 14),
    _tx('tx-3', 3200, 'cat-transport', today, hour: 9),
    _tx('tx-4', 120000, 'cat-home', _pastKey, hour: 20),
    _tx('tx-5', 6400, 'cat-coffee', _pastKey, hour: 11),
  ];
}

List<Override> _base({({int spentMinor, int earnedMinor})? totals}) {
  final feed = _feed();
  return [
    settingsProvider.overrideWith((ref) => Stream.value(_settings)),
    categoriesByIdProvider.overrideWith(
      (ref) => Stream.value({for (final c in _categories) c.id: c}),
    ),
    activeCategoriesProvider.overrideWith(
      (ref, type) => Stream.value(_categories),
    ),
    topCategoriesProvider.overrideWith((ref, type) => _categories),

    // Екран 2. Місяць фіксований — інакше заголовок шапки міняється
    // разом із календарем, а стрілки то гаснуть, то ні.
    selectedMonthProvider.overrideWith((ref) => const MonthKey(2026, 8)),
    monthRangeProvider.overrideWith(
      (ref) => (first: const MonthKey(2026, 1), last: const MonthKey(2026, 12)),
    ),
    dataBoundsProvider.overrideWith(
      (ref) => Stream.value((min: '2026-01-01', max: '2026-12-31')),
    ),
    monthFeedProvider.overrideWith((ref) => Stream.value(feed)),
    monthTotalsProvider.overrideWith(
      (ref) => Stream.value(
        totals ?? (spentMinor: 128000, earnedMinor: 340000),
      ),
    ),
    todayExpenseProvider.overrideWith((ref) => Stream.value(35700)),
    backupReminderProvider.overrideWith((ref) => Future.value(false)),
  ];
}
