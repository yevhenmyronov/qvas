import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'pressable.dart';

/// Роль кнопки. Кольору тут рівно стільки, скільки ролей (DS п.1.1):
/// зелений — головна дія, червоний — дія, рівносильна видаленню,
/// нейтральна — все інше.
enum AppButtonKind { primary, neutral, danger }

/// Велика кнопка застосунку.
///
/// До цього та сама розмітка стояла в п'яти місцях («Зберегти» на Екрані 1
/// і в шторці редагування, «Створити», «Почати», «Записати») плюс двічі
/// у підтвердженні імпорту — і встигла розійтись: частина місць анімувала
/// зміну кольору, частина ні, а «Додати свою» мала тернарник, обидві гілки
/// якого повертали один колір.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.kind = AppButtonKind.primary,
    this.enabled = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback onTap;
  final AppButtonKind kind;

  /// Неактивна кнопка лишається в розкладці, але приглушена й не реагує
  /// (Функціонал п.2.5): порожнє місце замість неї змусило б розкладку
  /// стрибати рівно в момент, коли людина цілиться пальцем.
  final bool enabled;

  /// true — на всю ширину, false — по вмісту з полями `32`.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (background, pressedBackground, foreground) = switch (kind) {
      AppButtonKind.primary => (
        AppColors.accent,
        AppColors.accentPressed,
        AppColors.onAccent,
      ),
      AppButtonKind.neutral => (
        AppColors.bgSurface,
        AppColors.bgSurfaceHigh,
        AppColors.textPrimary,
      ),
      AppButtonKind.danger => (
        AppColors.danger,
        AppColors.danger,
        AppColors.textOnDanger,
      ),
    };

    return Pressable(
      enabled: enabled,
      onTap: onTap,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.standard),
        curve: AppCurves.standard,
        height: AppSize.saveButton,
        width: expand ? double.infinity : null,
        padding: expand ? null : const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: enabled
              ? (pressed ? pressedBackground : background)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.bodyStrong.copyWith(
            color: enabled ? foreground : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
