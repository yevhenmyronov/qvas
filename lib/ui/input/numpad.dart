import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/amount_input.dart';
import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Цифровий пад 3×4 (Функціонал п.2.2). Розкладка статична: цифри 1–9,
/// внизу — калькулятор, 0, backspace. Крапки немає і не буде.
/// Хаптики немає ніде на паді (п.2.6).
///
/// Пад працює з будь-яким AmountInput через value/onChanged — той самий
/// компонент живе на Екрані 1 і в шторці швидкого редагування.
class Numpad extends StatelessWidget {
  const Numpad({
    super.key,
    required this.value,
    required this.onChanged,
    this.cellHeight = AppSize.padCell,
  });

  final AmountInput value;
  final ValueChanged<AmountInput> onChanged;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    Widget digit(int d) => _PadCell(
          height: cellHeight,
          onTap: () => onChanged(value.pressDigit(d)),
          child: Text('$d', style: AppText.padDigit),
        );

    final opText = switch (value.op) {
      null => '',
      CalcOp.add => '+',
      CalcOp.sub => '−',
      CalcOp.mul => '×',
      CalcOp.div => '÷',
    };

    final calcChild = switch (value.keyFace) {
      // Спокій — іконка калькулятора (рішення 27). Монохромний вектор,
      // не емодзі: на паді не має бути жодної кольорової плями.
      CalcKeyFace.icon => const Icon(Icons.calculate_outlined,
          size: 22, color: AppColors.textSecondary),
      // Кегль оператора на 20% менший за цифри (DS).
      CalcKeyFace.operator => Text(opText,
          style: AppText.padDigit
              .copyWith(fontSize: 19, color: AppColors.textPrimary)),
      CalcKeyFace.equals => Text('=',
          style: AppText.padDigit.copyWith(color: AppColors.textPrimary)),
    };

    final rows = <List<Widget>>[
      [digit(1), digit(2), digit(3)],
      [digit(4), digit(5), digit(6)],
      [digit(7), digit(8), digit(9)],
      [
        _PadCell(
          height: cellHeight,
          onTap: () => onChanged(value.pressCalcKey()),
          child: Semantics(
            label: context.l10n.a11yCalculator,
            button: true,
            child: calcChild,
          ),
        ),
        digit(0),
        _PadCell(
          height: cellHeight,
          onTap: () => onChanged(value.pressBackspace()),
          // Довге натискання — повне очищення (без вібрації, п.2.6).
          onLongPress: () => onChanged(value.clear()),
          child: Semantics(
            label: context.l10n.a11yBackspace,
            button: true,
            child: const Icon(Icons.backspace_outlined,
                size: 22, color: AppColors.textSecondary),
          ),
        ),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, row) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.padGap),
          Row(
            children: [
              for (final (j, cell) in row.indexed) ...[
                if (j > 0) const SizedBox(width: AppSpace.padGap),
                Expanded(child: cell),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _PadCell extends StatelessWidget {
  const _PadCell({
    required this.height,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final double height;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.micro),
        height: height,
        decoration: BoxDecoration(
          color: pressed ? AppColors.bgPressed : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        // Натиснута клавіша йде вниз і виходить з-під світла.
        foregroundDecoration: EdgeLight.decoration(
          BorderRadius.circular(AppRadius.button),
          on: !pressed,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
