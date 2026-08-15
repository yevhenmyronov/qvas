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
  });

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  final _held = Stopwatch();
  Timer? _release;

  Duration get _minPress =>
      AppDurations.of(context, AppDurations.micro);

  void _down() {
    _release?.cancel();
    _release = null;
    _held
      ..reset()
      ..start();
    if (!_pressed) setState(() => _pressed = true);
  }

  void _up() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _down() : null,
      onTapUp: widget.enabled ? (_) => _up() : null,
      onTapCancel: widget.enabled ? _up : null,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: AppDurations.of(context, AppDurations.micro),
        curve: AppCurves.standard,
        child: widget.builder(context, _pressed),
      ),
    );
  }
}
