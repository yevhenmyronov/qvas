import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/format.dart';
import '../../models/tx_type.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';

/// Сума з символом валюти + зарезервований рядок виразу калькулятора.
/// Розкладка статична: під вираз завжди відведено 24dp, тому нічого
/// не стрибає (Екрани п.1.6).
class AmountDisplay extends ConsumerWidget {
  const AmountDisplay({super.key, this.baseSize = 64});

  final double baseSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(inputProvider.select((s) => s.amount));
    final type = ref.watch(inputProvider.select((s) => s.type));

    final value = amount.displayValue;
    final isZero = value == 0;
    final isIncome = type == TxType.income;

    // 7 розрядів не влазять у кегль 64 → плавне зменшення 64 → 48 → 40
    // (Екрани п.1.5). Перенесення на другий рядок немає ніколи.
    final digits = value.toString().length;
    final fontSize = digits <= 5
        ? baseSize
        : digits == 6
            ? 48.0
            : 40.0;

    final numberColor =
        isZero ? AppColors.textTertiary : AppColors.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              children: [
                // Знак «+» у режимі доходу — другий, незалежний від капсули
                // сигнал там, куди спрямований погляд (Екрани п.1.4).
                if (isIncome)
                  TextSpan(
                    text: '+ ',
                    style: AppText.display.copyWith(
                        fontSize: fontSize, color: AppColors.income),
                  ),
                TextSpan(
                  text: groupDigits(value),
                  style: AppText.display
                      .copyWith(fontSize: fontSize, color: numberColor),
                ),
                // Символ валюти на 30% менший і вторинним кольором,
                // щоб число домінувало (DS п.3).
                TextSpan(
                  text: ' $kCurrencySymbol',
                  style: AppText.display.copyWith(
                    fontSize: fontSize * 0.7,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
        SizedBox(
          height: AppSize.expressionRow,
          child: Center(
            child: Text(
              amount.expressionText ?? '',
              style: AppText.expression,
            ),
          ),
        ),
      ],
    );
  }
}
