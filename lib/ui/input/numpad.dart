import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/amount_input.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Цифровий пад 3×4 (Функціонал п.2.2). Розкладка статична: цифри 1–9,
/// внизу — калькулятор, 0, backspace. Крапки немає і не буде.
/// Хаптики немає ніде на паді (п.2.6).
class Numpad extends ConsumerWidget {
  const Numpad({super.key, this.cellHeight = AppSize.padCell});

  final double cellHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(inputProvider.notifier);
    final keyFace =
        ref.watch(inputProvider.select((s) => s.amount.keyFace));
    final opText = ref.watch(inputProvider.select((s) {
      final op = s.amount.op;
      if (op == null) return '';
      return switch (op) {
        CalcOp.add => '+',
        CalcOp.sub => '−',
        CalcOp.mul => '×',
        CalcOp.div => '÷',
      };
    }));

    Widget digit(int d) => _PadCell(
          height: cellHeight,
          onTap: () => ctrl.pressDigit(d),
          child: Text('$d', style: AppText.padDigit),
        );

    final calcChild = switch (keyFace) {
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
          onTap: ctrl.pressCalcKey,
          child: calcChild,
        ),
        digit(0),
        _PadCell(
          height: cellHeight,
          onTap: ctrl.pressBackspace,
          // Довге натискання — повне очищення (без вібрації, Функціонал п.2.6).
          onLongPress: ctrl.clearAmount,
          child: const Icon(Icons.backspace_outlined,
              size: 22, color: AppColors.textSecondary),
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
        duration: AppDurations.micro,
        height: height,
        decoration: BoxDecoration(
          color: pressed ? AppColors.bgSurfaceHigh : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
