import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Цифра, що добігає до нового значення (рішення 64).
///
/// Метрики Екрана 2 підмінялись новим рядком. Тепер вони добігають —
/// рух тут пояснює саме те, ЩО змінилось: після збереження видно, що
/// «Різниця» поїхала, і на скільки, а не просто інше число на місці.
///
/// Свій контролер, а не [TweenAnimationBuilder], бо той завжди анімує
/// від `tween.begin` і не вміє «цю зміну зріж». А різати треба:
/// перемикання місяця — це не зміна величини, а показ іншої, і воно
/// вже має власний перехід (слайд), тож рахувати там нема чого.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    required this.cutKey,
  });

  /// Цільове значення в основних одиницях.
  final int value;

  /// Малює рядок із проміжного значення. Знак і колір рахуються ТУТ,
  /// а не зовні: тоді перетин нуля природно перекидає «+»/«−» і колір
  /// просто в потрібний момент, без окремої логіки.
  final Widget Function(BuildContext context, int value) builder;

  /// Зміна цього ключа — привід зрізати, а не рахувати.
  final Object? cutKey;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // Одиниця, а не нуль: інакше КОЖЕН вхід на Екран 2 починався б
    // рахунком від нуля — зокрема одразу після збереження, коли вже
    // грають згортання суми й поява рядка. Три анімації на одне
    // прибуття екрана.
    value: 1,
  );

  late int _from = widget.value;
  late int _to = widget.value;

  @override
  void didUpdateWidget(CountUp old) {
    super.didUpdateWidget(old);
    if (widget.cutKey != old.cutKey) {
      _from = _to = widget.value;
      _c.value = 1;
      return;
    }
    if (widget.value == _to) return;

    _from = _current;
    _to = widget.value;
    _c.value = 0;
    _c.animateTo(
      1,
      duration: AppDurations.of(context, AppDurations.count),
      curve: AppCurves.standard,
    );
  }

  int get _current =>
      _from + ((_to - _from) * _c.value).round();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _current),
    );
  }
}
