import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Scale-down ефект натискання (DS п.5.2): все, що натискається, м'яко
/// зменшується до 0.96. Застосовується без винятків — інакше інтерфейс
/// відчувається «дірявим». Стан pressed віддається білдеру, щоб елемент
/// міг також змінити фон.
///
/// **Мінімальна тривалість натиснутого стану (2026-08-16).** Раніше
/// стан знімався одразу по `onTapUp`. На паді реальний тап триває
/// 40–60 мс, а перехід — 120 мс, тож анімація розверталась, ледве
/// почавшись: щоб побачити відгук, доводилось спеціально ТРИМАТИ
/// клавішу. При швидкому наборі — тобто в головному сценарії
/// застосунку — візуального відгуку не було взагалі.
///
/// Тепер натиснутий стан живе не менше за тривалість самого переходу.
/// Під системним «Прибрати анімації» ця затримка теж стає нульовою:
/// вона рахується через [AppDurations.of], а не константою.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.pressDelay = Duration.zero,
    this.scaleOnPress = true,
  });

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  /// Скільки чекати, перш ніж ПОКАЗАТИ натиснутий стан.
  ///
  /// Потрібне рядкам, які лежать у скролі або в [Dismissible]. На початку
  /// горизонтального перетягування tap-розпізнавач спрацьовує ПЕРШИМ і
  /// програє арену лише за кілька кадрів — тобто без затримки кожен свайп
  /// і кожен скрол починався б спалахом підсвітки, яка одразу гасне.
  ///
  /// Затримка не робить відгук менш чутливим: якщо арену виграв тап
  /// ([_onTapUp]), стан показується однаково, навіть коли палець пішов
  /// раніше за неї. Мовчки пропускається тільки скасований жест — тобто
  /// рівно той випадок, заради якого затримка й існує.
  ///
  /// Свідомо НЕ йде через [AppDurations.of]: це не анімація, а час на
  /// вирішення арени жестів. Під «Прибрати анімації» спалах на початку
  /// свайпу нікуди не дівається — навпаки, стає різкішим.
  final Duration pressDelay;

  /// Чи зменшувати елемент при натисканні (DS п.5.2).
  ///
  /// Рядок на всю ширину — виняток: при 0.96 його краї зсуваються на
  /// ~8dp усередину, і це читається як «рядок тікає від пальця», а не
  /// «втискається». Такі елементи лишають тільки підсвітку фону.
  final bool scaleOnPress;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  final _held = Stopwatch();
  Timer? _release;

  /// Тікає, поки натиснутий стан ще не показаний — див. [Pressable.pressDelay].
  /// Не-null означає «палець на елементі, але жест ще не наш».
  Timer? _arm;

  Duration get _minPress =>
      AppDurations.of(context, AppDurations.micro);

  void _down() {
    _release?.cancel();
    _release = null;
    _arm?.cancel();
    if (widget.pressDelay == Duration.zero) {
      _show();
    } else {
      _arm = Timer(widget.pressDelay, _show);
    }
  }

  void _show() {
    _arm = null;
    _held
      ..reset()
      ..start();
    if (mounted && !_pressed) setState(() => _pressed = true);
  }

  /// Тап відбувся. Якщо стан ще не встиг показатись — показуємо його
  /// зараз: тап уже виграв арену, тобто затримці більше нема чого
  /// чекати. Без цього кожен рядок із [Pressable.pressDelay] лишався б
  /// без відгуку взагалі, бо реальний тап (40–60 мс) коротший за неї.
  void _onTapUp() {
    if (_arm != null) {
      _arm!.cancel();
      _show();
    }
    _startRelease();
  }

  /// Жест став чимось іншим — скролом або свайпом. Якщо стан не
  /// показувався, він і не покажеться.
  void _onTapCancel() {
    if (_arm != null) {
      _arm!.cancel();
      _arm = null;
      return;
    }
    _startRelease();
  }

  void _startRelease() {
    _held.stop();
    final remaining = _minPress - _held.elapsed;
    if (remaining <= Duration.zero) {
      _clear();
    } else {
      _release = Timer(remaining, _clear);
    }
  }

  void _clear() {
    _release = null;
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  @override
  void dispose() {
    _release?.cancel();
    _arm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _pressed);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _down() : null,
      onTapUp: widget.enabled ? (_) => _onTapUp() : null,
      onTapCancel: widget.enabled ? _onTapCancel : null,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: widget.scaleOnPress
          ? AnimatedScale(
              scale: _pressed ? 0.96 : 1.0,
              duration: AppDurations.of(context, AppDurations.micro),
              curve: AppCurves.standard,
              child: child,
            )
          : child,
    );
  }
}
