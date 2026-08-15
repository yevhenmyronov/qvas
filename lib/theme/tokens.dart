import 'package:flutter/material.dart';

/// Токени з Design System & UI/UX Guidelines. Єдине джерело правди для
/// кольорів, радіусів, відступів, тривалостей і типографіки.
/// Значення не змінюються локально в екранах — тільки тут.

abstract final class AppColors {
  // ЕКСПЕРИМЕНТ 2026-08-14 (рішення 34): палітра Monobank-стилю з
  // [[Monobank]]. iOS-зелений акцент, насичений синій дохід.
  // Відкат — git revert одного коміта.
  //
  // Рішення 37: фон повернуто до глибокого чорного — шари розділяються
  // яскравістю поверхонь (панель підсумків, плашки), а не лініями.
  // Графітовий #111111 давав замалий контраст із поверхнями.
  static const bgBase = Color(0xFF0D0D0D);
  static const bgSurface = Color(0xFF1E1E1E);
  static const bgSurfaceHigh = Color(0xFF2C2C2E);

  /// Панель підсумків на Екрані 2 — власний рівень: тьмяніша за шторки,
  /// щоб велика площа не світилась, але читалась як окремий шар.
  static const bgPanel = Color(0xFF18181A);
  static const borderHairline = Color(0x14FFFFFF); // white 8%

  // Дія та бренд
  static const accent = Color(0xFF34C759);
  static const accentPressed = Color(0xFF2DB14E);
  static const accentSubtle = Color(0x1F34C759); // 12%
  static const onAccent = Color(0xFF0B0B0D);

  // Дохід. Рішення 50 (2026-08-15, переглядає рішення 07): зелений —
  // звичний користувачам колір доходу. Той самий відтінок, що акцент:
  // один зелений на весь застосунок, тип запису розрізняє знак «+».
  static const income = Color(0xFF34C759);
  static const incomeSubtle = Color(0x1F34C759); // 12%

  // Видалення — червоний означає ТІЛЬКИ видалення
  static const danger = Color(0xFFFF3B30);
  static const dangerSubtle = Color(0x24FF3B30); // 14%
  static const textOnDanger = Color(0xFFFFFFFF);

  // Текст
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF98989D);
  static const textTertiary = Color(0xFF6E6E73);
}

abstract final class AppRadius {
  /// Панель підсумків та великі картки (рішення 37, [[Monobank]] п.4).
  static const card = 24.0;
  static const button = 16.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract final class AppSpace {
  /// Бічні поля екрана.
  static const side = 20.0;

  /// Вертикальний ритм між блоками.
  static const block = 24.0;

  /// Проміжки бульбашок категорій (горизонталь і вертикаль).
  static const bubbleGap = 8.0;

  /// Проміжок між клітинками пада.
  static const padGap = 8.0;
}

abstract final class AppSize {
  /// Мінімальна ціль дотику (вимога Android).
  static const minTouch = 48.0;

  /// Клітинка цифрового пада; на екранах <680dp — small.
  static const padCell = 64.0;
  static const padCellSmall = 56.0;

  /// Капсула категорії. Зменшено 2026-08-14: пріоритет вертикалі — цифрам
  /// і паду, бульбашки стають у два ряди (рішення 32).
  static const bubble = 44.0;
  static const bubbleSmall = 40.0;

  /// Кнопка «Зберегти».
  static const saveButton = 56.0;

  /// Капсула перемикача «Витрата / Дохід».
  static const typeSwitch = 36.0;

  /// Поріг «малого екрана» по висоті.
  static const smallScreenHeight = 680.0;

  /// Зарезервована висота під рядок виразу калькулятора.
  static const expressionRow = 24.0;
}

abstract final class AppDurations {
  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 320);

  /// Поява нового запису в стрічці (рішення 56): рядок розгортається
  /// по висоті + scale + прозорість — ефект зникнення навпаки.
  static const appear = Duration(milliseconds: 300);

  /// «Прибрати анімації» в системі → всі тривалості стають 0 (DS п.6).
  /// Хаптика при цьому лишається.
  static Duration of(BuildContext context, Duration base) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : base;
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  // easeOutBack прибрано: рішення 56 явно відмовилось від overshoot,
  // і в застосунку немає жодного руху, який мав би «перестрибувати».
}

abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  /// Сума на цифровому паді (на низьких екранах — 48).
  static const display = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
    height: 1.1,
  );

  /// Рядок виразу калькулятора під сумою.
  static const expression = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  /// «Різниця» на Екрані 2. Збільшено 40 → 48 (рішення 51, 2026-08-15).
  static const metric = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// «Витрати» / «Доходи» на Екрані 2. Збільшено 24 → 28 (рішення 51).
  static const metricSub = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Заголовки шторок.
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Назва категорії в стрічці, сума в рядку, підписи кнопок.
  static const bodyStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Коментар, підписи.
  static const caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Цифра на клітинці пада.
  static const padDigit = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );
}

/// Глобальна тема. Темна завжди — світлої теми не існує (рішення DS п.1.2).
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.bgBase,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bgBase,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.income,
      error: AppColors.danger,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
