import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/tx_type.dart';
import '../../providers/input_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import 'amount_display.dart';

/// «Сума приземляється в рядок» (рішення 53).
///
/// При збереженні велика сума з Екрана 1 не зникає, а летить оверлеєм
/// у позицію суми свого нового рядка на Екрані 2, зменшуючись з Display
/// до кегля рядка. Ціль трекається щокадру за GlobalKey — рядок їде
/// вгору разом із в'їжджаючим екраном, і сума наздоганяє його наживо.
/// Рядок увесь політ ховає власну суму ([landingTxIdProvider]), а перед
/// самою посадкою відкриває її — перехресне розчинення замість підміни.
class AmountFlight {
  AmountFlight()
    : _controller = AnimationController(
        // НЕ vsync Екрана 1: коли Екран 2 повністю накриває ввід
        // (320мс), TickerMode заморожує тікери невидимого екрана — і
        // політ (480мс) застигав у повітрі сірою сумою назавжди.
        // Сирий Ticker живе поза деревом і не м'ютиться.
        vsync: const _RawTickerProvider(),
        duration: AppDurations.flight,
      );

  final AnimationController _controller;
  OverlayEntry? _entry;
  VoidCallback? _revealListener;

  /// Запускає політ. false — стартова геометрія недоступна; тоді
  /// показуйте старий шлях (слайд-згортання суми).
  bool start({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey sourceKey,
    required InputState snapshot,
    VoidCallback? onDone,
  }) {
    final box = sourceKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return false;

    final source = (box.localToGlobal(Offset.zero) & box.size).centerRight;
    final value = snapshot.amount.resolvedAmount;
    final small = MediaQuery.sizeOf(context).height < AppSize.smallScreenHeight;
    final startSize = AmountDisplay.fontSizeFor(value, small ? 48 : 64);
    final income = snapshot.type == TxType.income;
    final format = ref.read(moneyFormatProvider);
    final targetKey = ref.read(newRowAmountKeyProvider);
    final landing = ref.read(landingTxIdProvider.notifier);
    landing.state = ref.read(lastSavedTxIdProvider);

    // Сума рядка відкривається на 85% польоту — оверлей ще догорає
    // останні кадри поверх неї, і підміна читається як розчинення,
    // а не як стрибок.
    void reveal() {
      if (_controller.value >= 0.85 && landing.state != null) {
        landing.state = null;
      }
    }

    _revealListener = reveal;
    _controller.addListener(reveal);

    final entry = OverlayEntry(
      // Material(transparency) обов'язковий: без нього Text в оверлеї
      // отримує аварійний стиль із жовтим підкресленням.
      builder: (context) => IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = AppCurves.standard.transform(_controller.value);

              // Жива ціль: права середина суми нового рядка. Поки рядок
              // ще не зʼявився у стрічці — просто падаємо вниз, як у
              // старій анімації.
              var target = source + const Offset(0, 300);
              final tb = targetKey.currentContext?.findRenderObject();
              if (tb is RenderBox && tb.attached && tb.hasSize) {
                target = (tb.localToGlobal(Offset.zero) & tb.size).centerRight;
              }

              final pos = Offset.lerp(source, target, t)!;
              final fontSize = startSize + (16 - startSize) * t;
              final opacity = t < 0.85
                  ? 1.0
                  : (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0);

              return Stack(
                children: [
                  Positioned(
                    left: pos.dx,
                    top: pos.dy,
                    // Якір — права середина тексту: колонка сум у стрічці
                    // вирівняна по правому краю.
                    child: FractionalTranslation(
                      translation: const Offset(-1, -0.5),
                      child: Opacity(
                        opacity: opacity,
                        child: Text.rich(
                          AmountDisplay.span(
                            value: value,
                            format: format,
                            income: income,
                            fontSize: fontSize,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _controller.forward(from: 0).whenCompleteOrCancel(() {
      final l = _revealListener;
      if (l != null) _controller.removeListener(l);
      _revealListener = null;
      _entry?.remove();
      _entry = null;
      if (landing.state != null) landing.state = null;
      onDone?.call();
    });
    return true;
  }

  /// Переривання (помилка запису): прибирає оверлей через той самий
  /// whenCompleteOrCancel.
  void abort() => _controller.stop();

  void dispose() {
    _entry?.remove();
    _entry = null;
    _controller.dispose();
  }
}

/// Тікер-провайдер поза деревом віджетів: не підпорядкований TickerMode,
/// тому анімація оверлея доживає до кінця, навіть коли екран-власник
/// уже накритий іншим route.
class _RawTickerProvider implements TickerProvider {
  const _RawTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
