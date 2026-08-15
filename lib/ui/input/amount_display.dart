import 'package:flutter/material.dart';

import '../../models/amount_input.dart';
import '../../models/currency.dart';
import '../../theme/tokens.dart';

/// Сума з символом валюти + зарезервований рядок виразу калькулятора.
/// Розкладка статична: під вираз завжди відведено 24dp, тому нічого
/// не стрибає (Екрани п.1.6). Число форматується за локаллю, символ і
/// його позиція — за валютою (тех. спека п.11.1).
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.format,
    this.income = false,
    this.baseSize = 64,
  });

  final AmountInput amount;
  final MoneyFormat format;
  final bool income;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    final value = amount.displayValue;
    final isZero = value == 0;

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

    // Символ валюти на 30% менший і вторинним кольором, щоб число
    // домінувало (DS п.3).
    final symbolSpan = TextSpan(
      text: format.symbolFirst
          ? '${format.symbol} '
          : ' ${format.symbol}',
      style: AppText.display.copyWith(
        fontSize: fontSize * 0.7,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );

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
                if (income)
                  TextSpan(
                    text: '+ ',
                    style: AppText.display.copyWith(
                        fontSize: fontSize, color: AppColors.income),
                  ),
                if (format.symbolFirst) symbolSpan,
                TextSpan(
                  text: format.number(value),
                  style: AppText.display
                      .copyWith(fontSize: fontSize, color: numberColor),
                ),
                if (!format.symbolFirst) symbolSpan,
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
