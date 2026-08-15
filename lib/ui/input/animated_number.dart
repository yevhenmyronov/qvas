import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Що саме змінилось між двома написаннями числа.
///
/// Винесено з віджета навмисно: тут уся складність цієї анімації, і
/// вона перевіряється як чиста функція, без пампів і кадрів.
///
/// **Порівнюються ЦИФРИ, а не гліфи.** Перша версія звіряла гліфи — і
/// анімація вмирала після третьої цифри: на четвертій з'являється
/// розділювач тисяч і зсуває всі наступні позиції, тож `123 → 1 234`
/// виглядало для дифа не як «дописали один гліф», а як перебудова
/// цілого рядка. Далі кожна наступна цифра теж рухала розділювач, і
/// умова «зайшов рівно один» не виконувалась більше ніколи.
@immutable
class GlyphDiff {
  const GlyphDiff({
    required this.stable,
    required this.ghosts,
    required this.animate,
  });

  /// Скільки гліфів нового числа лишаються на місці. Решта — заходять.
  final int stable;

  /// Гліфи, що йдуть: домальовуються праворуч і згасають.
  final List<String> ghosts;

  /// false — зміна надто велика для погліфового руху, просто підміна.
  final bool animate;

  static String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  static GlyphDiff between(String before, String after) {
    final beforeChars = before.characters.toList();
    final afterChars = after.characters.toList();
    final beforeDigits = _digits(before);
    final afterDigits = _digits(after);

    GlyphDiff swap() =>
        GlyphDiff(stable: afterChars.length, ghosts: const [], animate: false);

    if (afterChars.isEmpty || beforeDigits == afterDigits) return swap();

    // Перша цифра поверх нуля: «0» не тане, а одразу заміщується — але
    // сама цифра все одно заходить рухом, бо це найпомітніший момент
    // усього вводу.
    if (beforeDigits == '0' && afterDigits.length == 1) {
      return GlyphDiff(stable: 0, ghosts: const [], animate: true);
    }

    // Дописали одну цифру праворуч.
    if (afterDigits.length == beforeDigits.length + 1 &&
        afterDigits.startsWith(beforeDigits)) {
      return GlyphDiff(
        stable: afterChars.length - 1,
        ghosts: const [],
        animate: true,
      );
    }

    // Стерли одну цифру праворуч.
    if (beforeDigits.length == afterDigits.length + 1 &&
        beforeDigits.startsWith(afterDigits)) {
      return GlyphDiff(
        stable: afterChars.length,
        ghosts: [beforeChars.last],
        animate: true,
      );
    }

    // Результат калькулятора й будь-яка інша довільна зміна: половина
    // числа інша, і погліфовий рух там виглядає як гральний автомат.
    return swap();
  }
}

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

    final diff = GlyphDiff.between(old.text, widget.text);

    // Розряд перейшов межу 64 → 48 → 40: число саме змінює масштаб, і
    // цього переходу достатньо. Разом із погліфовим рухом виходила
    // метушня — найпомітніше на `99 999 → 999 999`, де водночас
    // з'їжджається все число й заходить нова цифра.
    final scaleChanging = old.style.fontSize != widget.style.fontSize;

    if (!diff.animate || scaleChanging) {
      setState(() {
        _stable = widget.text.characters.length;
        _ghosts = const [];
      });
      _c.value = 1;
      return;
    }

    setState(() {
      _stable = diff.stable;
      _ghosts = diff.ghosts;
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
