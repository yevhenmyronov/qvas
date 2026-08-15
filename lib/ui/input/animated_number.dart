import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Число, гліфи якого з'являються й зникають поодинці.
///
/// Головний елемент застосунку — сума — не мав жодного руху: цифри
/// просто підмінялись. Тепер нова цифра в'їжджає знизу праворуч, а
/// решта числа їде вліво. Зсув уліво нічим не рахується: хвостовий гліф
/// анімує ВЛАСНУ ширину, а `Row` центрований, тож решта відсувається
/// сама, як наслідок розкладки.
///
/// Примітиви ті самі, що в стрічці (`Align(widthFactor:)`, квадратична
/// прозорість) — просто по горизонталі замість вертикалі. Моторна мова
/// в застосунку одна.
class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, value: 1);

  /// Скільки гліфів на початку числа лишились незмінними. Решта —
  /// ті, що заходять.
  int _stable = 0;

  /// Гліфи, яких у новому числі вже немає: домальовуються праворуч і
  /// згасають. Backspace виходить дзеркалом появи за побудовою, а не
  /// копіюванням її чисел (рішення 56).
  List<String> _ghosts = const [];

  @override
  void initState() {
    super.initState();
    _stable = widget.text.characters.length;
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.text == widget.text) return;

    final before = old.text.characters.toList();
    final after = widget.text.characters.toList();

    // Спільний ПРЕФІКС, а не суфікс: на паді дописують і стирають
    // праворуч, тож незмінна частина — саме початок числа.
    var common = 0;
    while (common < before.length &&
        common < after.length &&
        before[common] == after[common]) {
      common++;
    }
    final entering = after.length - common;
    final leaving = before.sublist(common);

    // Анімуємо лише «одна зайшла» або «одна вийшла». Усе інше —
    // перенесення розряду (999 → 1 000) чи результат калькулятора —
    // міняє півчисла одразу, і погліфовий рух там виглядає як гральний
    // автомат. Такі зміни просто підміняються.
    final simple = (entering == 1 && leaving.isEmpty) ||
        (entering == 0 && leaving.length == 1);
    if (!simple) {
      setState(() {
        _stable = after.length;
        _ghosts = const [];
      });
      _c.value = 1;
      return;
    }

    setState(() {
      _stable = common;
      _ghosts = leaving;
    });
    // Перебивання: контролер перезапускається з нуля, привиди
    // попереднього переходу зникають миттєво. На паді роблять 3–4 тапи
    // в секунду, і це важливіше за докручування анімації.
    _c.value = 0;
    _c.animateTo(
      1,
      duration: AppDurations.of(context, AppDurations.micro),
      curve: AppCurves.standard,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();

    // Число завжди малюється погліфово, і в спокої теж: інакше на
    // завершенні анімації розкладка перескакувала б із «ряду з Text» на
    // «один Text». Табличні цифри роблять ширину гліфа сталою, тож
    // візуальної різниці немає.
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, ch) in chars.indexed)
            _Glyph(
              key: ValueKey('glyph-$i'),
              t: i < _stable ? 1 : _c.value,
              child: Text(ch, style: widget.style),
            ),
          // Привиди живуть рівно доти, доки триває перехід. Без цієї
          // умови вони лишались у дереві назавжди — невидимі
          // (нульова ширина, нульова прозорість), але присутні: текст
          // суми для читача екрана й для тестів містив зайву цифру.
          if (_c.value < 1)
            for (final (i, ch) in _ghosts.indexed)
              _Glyph(
                key: ValueKey('ghost-$i'),
                t: 1 - _c.value,
                child: Text(ch, style: widget.style),
              ),
        ],
      ),
    );
  }
}

/// Гліф, що росте власною шириною: 0 — місця не займає, 1 — на місці.
class _Glyph extends StatelessWidget {
  const _Glyph({super.key, required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (t >= 1) return child;
    // Зсув поверх обрізання, а не всередині: ClipRect ріже по обох осях,
    // тож усередині він з'їв би нижні 4dp гліфа.
    return Transform.translate(
      offset: Offset(0, 4 * (1 - t)),
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: t.clamp(0.0, 1.0),
          child: Opacity(opacity: (t * t).clamp(0.0, 1.0), child: child),
        ),
      ),
    );
  }
}
