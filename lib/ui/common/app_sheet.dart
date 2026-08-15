import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Скільки шторок відкрито просто зараз. Потрібне екранам під ними:
/// вкладені шторки (категорії → створення → пікер емодзі) не мають
/// множити затемнення, тому це лічильник, а не прапорець.
final sheetDepth = ValueNotifier<int>(0);

/// Єдина шторка застосунку (DS п.5.4, Екрани п.0.1).
///
/// До цього хрома — фон, верхні кути, драг-хендл, скрим — була скопійована
/// в семи місцях і в семи місцях розходилась. Тут вона одна.
///
/// Окремо важливе: [showModalBottomSheet] без власного контролера бере
/// свою типову тривалість і **не реагує** на системне «Прибрати анімації».
/// Власний контролер із [AppDurations.of] закриває це для всіх шторок
/// одразу.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,

  /// Частка висоти екрана для шторок із внутрішнім скролом (0.7).
  /// null — висота по вмісту.
  double? heightFactor,

  /// Піднімати над системною клавіатурою (шторки з текстовим полем).
  bool resizeForKeyboard = false,

  /// Обгортати вміст у SafeArea знизу. Фон при цьому все одно заходить
  /// під системну панель — відступ отримує лише вміст.
  bool safeAreaBottom = false,
}) {
  final navigator = Navigator.of(context);
  final controller = AnimationController(
    vsync: navigator,
    duration: AppDurations.of(context, AppDurations.sheet),
    reverseDuration: AppDurations.of(context, AppDurations.sheet),
    debugLabel: 'AppSheet',
  );

  sheetDepth.value++;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    transitionAnimationController: controller,
    builder: (context) => _AppSheetChrome(
      heightFactor: heightFactor,
      resizeForKeyboard: resizeForKeyboard,
      safeAreaBottom: safeAreaBottom,
      child: builder(context),
    ),
  ).whenComplete(() {
    sheetDepth.value--;
    controller.dispose();
  });
}

class _AppSheetChrome extends StatelessWidget {
  const _AppSheetChrome({
    required this.child,
    required this.heightFactor,
    required this.resizeForKeyboard,
    required this.safeAreaBottom,
  });

  final Widget child;
  final double? heightFactor;
  final bool resizeForKeyboard;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final factor = heightFactor;

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DragHandle(),
        if (factor == null) Flexible(child: child) else Expanded(child: child),
      ],
    );

    if (safeAreaBottom) {
      body = SafeArea(top: false, child: body);
    }

    Widget sheet = Container(
      height: factor == null
          ? null
          : MediaQuery.sizeOf(context).height * factor,
      decoration: const BoxDecoration(
        color: AppColors.bgSurfaceHigh,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: body,
    );

    if (resizeForKeyboard) {
      sheet = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: sheet,
      );
    }

    return sheet;
  }
}

/// Драг-хендл обов'язковий (DS п.5.4): без нього шторка не читається
/// як щось, що можна змахнути.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
