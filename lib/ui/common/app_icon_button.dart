import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'pressable.dart';

/// Кнопка-іконка без фону: 48dp цілі дотику навколо гліфа.
///
/// Одинадцять місць писали її самотужки, і розійшлись вони не в
/// оформленні, а у відгуку: сім ішли через [Pressable] і зменшувались
/// при натисканні, а чотири (пін і 🗑 у списках категорій) були голими
/// [GestureDetector] — на дотик не реагували взагалі. Помітити це на
/// око важко саме тому, що іконки поруч, і поводяться вони по-різному
/// тільки в русі.
///
/// Відгук — рівно масштаб, як вимагає DS п.5.2 для всього натискного.
/// Кольором гліф не грає навмисно: у половини цих іконок колір уже несе
/// СТАН (пін активний — акцентний, стрілка місяця неактивна —
/// третинна), і другий сенс на тому самому каналі читався б як зміна
/// стану, а не як дотик.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.enabled = true,
    this.color = AppColors.textSecondary,
    this.iconSize = 24,
    this.size = AppSize.minTouch,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Обов'язковий скрізь, де іконка — єдиний носій сенсу.
  final String? semanticLabel;

  /// Неактивна кнопка лишається на місці й не реагує (стрілка місяця на
  /// краю наявних даних).
  final bool enabled;

  final Color color;
  final double iconSize;

  /// Менше за [AppSize.minTouch] — лише для ✕, що стоїть усередині рядка
  /// тексту й не може розсовувати його на півсантиметра.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      enabled: enabled,
      onTap: onTap,
      builder: (context, pressed) => Semantics(
        label: semanticLabel,
        button: true,
        enabled: enabled,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}
