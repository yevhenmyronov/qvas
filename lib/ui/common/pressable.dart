import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Scale-down ефект натискання (DS п.5.2): все, що натискається, м'яко
/// зменшується до 0.96. Застосовується без винятків — інакше інтерфейс
/// відчувається «дірявим». Стан pressed віддається білдеру, щоб елемент
/// міг також змінити фон.
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

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _set(true) : null,
      onTapUp: widget.enabled ? (_) => _set(false) : null,
      onTapCancel: widget.enabled ? () => _set(false) : null,
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
