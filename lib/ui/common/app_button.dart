import 'package:flutter/material.dart';

import '../../theme/edge_light.dart';
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
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  /// Заливка при оживанні (рішення 65). Момент, коли зійшлись сума й
  /// категорія, — головна зміна стану на Екрані 1, і досі вона була
  /// звичайним перефарбуванням. Тепер колір набігає зліва направо: це
  /// єдина «нагорода» в застосунку, і трапляється вона раз на запис.
  late final AnimationController _fill = AnimationController(
    vsync: this,
    value: widget.enabled ? 1 : 0,
  );

  @override
  void didUpdateWidget(AppButton old) {
    super.didUpdateWidget(old);
    if (old.enabled == widget.enabled) return;
    _fill.animateTo(
      widget.enabled ? 1 : 0,
      duration: AppDurations.of(context, AppDurations.standard),
      curve: AppCurves.standard,
    );
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (background, pressedBackground, foreground) = switch (widget.kind) {
      AppButtonKind.primary => (
        AppColors.accent,
        AppColors.accentPressed,
        AppColors.onAccent,
      ),
      AppButtonKind.neutral => (
        AppColors.bgSurface,
        AppColors.bgPressed,
        AppColors.textPrimary,
      ),
      AppButtonKind.danger => (
        AppColors.danger,
        AppColors.danger,
        AppColors.textOnDanger,
      ),
    };

    const radius = BorderRadius.all(Radius.circular(AppRadius.button));

    return Pressable(
      enabled: widget.enabled,
      onTap: widget.onTap,
      builder: (context, pressed) => AnimatedBuilder(
        animation: _fill,
        builder: (context, _) {
          final t = _fill.value;
          return SizedBox(
            height: AppSize.saveButton,
            width: widget.expand ? double.infinity : null,
            child: DecoratedBox(
              // Світло малюється ПОВЕРХ заливки, тож вона його не
              // перекриває, а обрізання лишається на самій кнопці.
              position: DecorationPosition.foreground,
              decoration: EdgeLight.decoration(radius, on: !pressed),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: AppColors.bgSurface),
                    ),
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: t,
                        child: AnimatedContainer(
                          duration:
                              AppDurations.of(context, AppDurations.micro),
                          color: pressed ? pressedBackground : background,
                        ),
                      ),
                    ),
                    Padding(
                      padding: widget.expand
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.label,
                        style: AppText.bodyStrong.copyWith(
                          // Один лерпнутий текст замість двох шарів із
                          // кросфейдом: посередині заливки половина
                          // підпису лежить на акценті, половина на фоні,
                          // і єдиний змішаний колір за 200 мс не
                          // відрізнити від чесного двошарового переходу.
                          color: Color.lerp(
                            AppColors.textTertiary,
                            foreground,
                            t,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
