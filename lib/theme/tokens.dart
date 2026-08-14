import 'package:flutter/material.dart';

/// Токени з Design System & UI/UX Guidelines. Єдине джерело правди для
/// кольорів, радіусів, відступів, тривалостей і типографіки.
/// Значення не змінюються локально в екранах — тільки тут.

abstract final class AppColors {
  // Фони
  static const bgBase = Color(0xFF0B0B0D);
  static const bgSurface = Color(0xFF17171A);
  static const bgSurfaceHigh = Color(0xFF212126);
  static const borderHairline = Color(0x14FFFFFF); // white 8%

  // Дія та бренд
  static const accent = Color(0xFF00E676);
  static const accentPressed = Color(0xFF00C853);
  static const accentSubtle = Color(0x1F00E676); // 12%
  static const onAccent = Color(0xFF0B0B0D);

  // Дохід
  static const income = Color(0xFF4DA3FF);
  static const incomeSubtle = Color(0x1F4DA3FF); // 12%

  // Видалення — червоний означає ТІЛЬКИ видалення
  static const danger = Color(0xFFFF453A);
  static const dangerSubtle = Color(0x24FF453A); // 14%
  static const textOnDanger = Color(0xFFFFFFFF);

  // Текст
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF5A5A5F);
}

abstract final class AppRadius {
  static const card = 20.0;
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
  static const bubbleGap = 10.0;

  /// Проміжок між клітинками пада.
  static const padGap = 8.0;
}

abstract final class AppSize {
  /// Мінімальна ціль дотику (вимога Android).
  static const minTouch = 48.0;

  /// Клітинка цифрового пада; на екранах <680dp — small.
  static const padCell = 64.0;
  static const padCellSmall = 56.0;

  /// Капсула категорії.
  static const bubble = 52.0;
  static const bubbleSmall = 48.0;

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
  static const highlight = Duration(milliseconds: 600);
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const enter = Curves.easeOutBack;
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

  /// «Різниця» на Екрані 2.
  static const metric = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// «Витрати» / «Доходи» на Екрані 2.
  static const metricSub = TextStyle(
    fontSize: 24,
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
