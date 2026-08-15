import 'package:flutter/material.dart';

import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';

/// Скільки шторок відкрито просто зараз. Потрібне екранам під ними:
/// вкладені шторки (категорії → створення → пікер емодзі) не мають
/// множити затемнення, тому це лічильник, а не прапорець.
final sheetDepth = ValueNotifier<int>(0);

/// Висота закріпленої знизу дії у шторці: кнопка плюс поля навколо неї.
/// Тост має підніматись рівно на стільки, щоб її не перекривати
/// (Екрани п.0.2).
const kSheetFooterHeight = AppSize.saveButton + AppSpace.side * 2;

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
  final transition = AppDurations.of(context, AppDurations.sheet);
  final controller = AnimationController(
    vsync: navigator,
    duration: transition,
    reverseDuration: transition,
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
    _disposeWhenDismissed(controller);
  });
}

/// Викидає контролер переходу — але тільки після того, як анімація
/// закриття справді дограла.
///
/// Це не педантизм. Future від [showModalBottomSheet] завершується
/// раніше, ніж шторка доїжджає вниз, а зворотний хід грає саме на
/// цьому контролері. Викинутий за таймером «тривалість + запас», він
/// однаково встигав під руку: шторка зберігала зміни й лишалась висіти
/// на екрані — виглядало як логічний баг кнопки, а було керуванням
/// часом життя. Тому орієнтир — стан самого контролера, а не годинник.
///
/// Саме викидання відкладене на наступний кадр: робити це всередині
/// нотифікації слухачів не можна.
void _disposeWhenDismissed(AnimationController controller) {
  void disposeNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  if (controller.status == AnimationStatus.dismissed) {
    disposeNextFrame();
    return;
  }

  void onStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    controller.removeStatusListener(onStatus);
    disposeNextFrame();
  }

  controller.addStatusListener(onStatus);
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
    final child = _SheetEntry(
      animation: ModalRoute.of(context)!.animation!,
      child: this.child,
    );

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DragHandle(),
        if (factor == null)
          // Шторки «по вмісту» мусять уміти скролитись. Коли виїжджає
          // клавіатура, доступна висота падає на 300+ dp, а вміст
          // (пад у шторці редагування, поле назви у створенні
          // категорії) лишається тим самим — і Column просто
          // переповнювався жовто-чорною смугою.
          Flexible(child: SingleChildScrollView(child: child))
        else
          Expanded(child: child),
      ],
    );

    if (safeAreaBottom) {
      body = SafeArea(top: false, child: body);
    }

    const radius = BorderRadius.vertical(top: Radius.circular(AppRadius.sheet));

    Widget sheet = Container(
      height: factor == null
          ? null
          : MediaQuery.sizeOf(context).height * factor,
      decoration: const BoxDecoration(
        color: AppColors.bgSheet,
        borderRadius: radius,
      ),
      // Верхня грань шторки — там, де вона виїжджає з-під екрана,
      // світло падає першим.
      foregroundDecoration: EdgeLight.decoration(radius),
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

/// Анімація виїзду самої шторки, роздана вниз по дереву — щоб рядки
/// могли прибувати разом із нею, а не жити власним таймером.
class _SheetEntry extends InheritedWidget {
  const _SheetEntry({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SheetEntry old) => old.animation != animation;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheetEntry>()?.animation;
}

/// Рядок шторки, що прибуває з невеликим запізненням від попереднього
/// (рішення 67).
///
/// Вміст шторки з'являвся весь одразу — готовим, ніби він там уже був.
/// Невеликий каскад читається як «вміст прибуває» й коштує кілька
/// десятків мілісекунд, які й так минають, поки шторка виїжджає.
///
/// **Прив'язано до анімації самої шторки, а не до власного таймера.**
/// Наївний варіант — `Future.delayed(i * 14)` на рядок — у шторці валют
/// завів би півтори сотні таймерів, а рядки, збудовані вже після
/// скролу, анімувались би посеред нього. Тут запізнення виражене
/// інтервалом усередині наявної анімації: рядок із індексом
/// [_maxRows] і далі обгортки не отримує взагалі, а коли шторка
/// доїхала — множник дорівнює одиниці й обгортка знімається сама.
class SheetStaggered extends StatelessWidget {
  const SheetStaggered({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  /// Далі каскад не має сенсу: ці рядки все одно нижче краю екрана.
  static const _maxRows = 8;

  /// Крок і довжина — частки від виїзду шторки (320 мс), тобто ~14 мс
  /// на рядок при ~128 мс на сам прояв.
  static const _step = 0.045;
  static const _span = 0.4;

  @override
  Widget build(BuildContext context) {
    if (index >= _maxRows) return child;
    final animation = _SheetEntry.maybeOf(context);
    if (animation == null) return child;

    final begin = index * _step;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final raw = ((animation.value - begin) / _span).clamp(0.0, 1.0);
        final t = AppCurves.standard.transform(raw);
        if (t >= 1) return child!;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 4 * (1 - t)),
            child: child,
          ),
        );
      },
    );
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
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
