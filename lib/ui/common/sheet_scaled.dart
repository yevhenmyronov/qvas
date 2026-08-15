import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'app_sheet.dart';

/// Екран, що відходить назад, коли поверх нього виїжджає шторка
/// (рішення 66).
///
/// Досі позаду шторки лише темнішав скрим, тож глибини не було: два
/// шари стояли в одній площині. Тепер нижній помітно відступає — і вісь
/// Z з'являється без жодної тіні.
///
/// **Чому не в `MaterialApp.builder`.** Його `child` — це Navigator, а
/// в ньому живе Overlay зі шторкою: масштабувалась би й вона разом зі
/// скримом. **І не через `secondaryAnimation` маршруту** —
/// `MaterialPageRoute.canTransitionTo` не пропускає
/// `ModalBottomSheetRoute`, тож шторка ніколи не приводить у рух
/// маршрут під собою. Лишається обгортати вміст `Scaffold`.
class SheetScaled extends StatelessWidget {
  const SheetScaled({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppDurations.of(context, AppDurations.sheet);

    return ValueListenableBuilder<int>(
      valueListenable: sheetDepth,
      child: child,
      builder: (context, depth, child) {
        // Глибина, а не прапорець: шторка категорій відкриває створення
        // поверх себе, а та — пікер емодзі. Вкладені шторки не мають
        // множити відступ, тому дивимось лише «є чи немає».
        final open = depth > 0;
        return AnimatedScale(
          scale: open ? 0.94 : 1,
          duration: duration,
          curve: AppCurves.standard,
          child: AnimatedOpacity(
            opacity: open ? 0.55 : 1,
            duration: duration,
            curve: AppCurves.standard,
            child: child,
          ),
        );
      },
    );
  }
}
