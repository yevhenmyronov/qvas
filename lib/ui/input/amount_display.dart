import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../models/amount_input.dart';
import '../../models/currency.dart';
import '../../theme/tokens.dart';
import 'animated_number.dart';

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
    final symbol = Text(
      format.symbolFirst ? '${format.symbol} ' : ' ${format.symbol}',
      style: AppText.display.copyWith(
        fontSize: fontSize * 0.7,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Зміна кеглю (рішення 62, переглянуто того ж дня).
        //
        // Спершу анімувався САМ кегль. Виглядало зламано, і не через
        // криву: текст перерозкладався щокадру, тобто за 120 мс
        // проходив вісім різних растеризацій і вісім разів переставляв
        // гліфи. На швидкості це читається не як плавна зміна розміру,
        // а як накладання двох розмірів один на одного.
        //
        // Тепер текст розкладається ОДИН раз, одразу під цільовий
        // кегль, а плавність дає масштаб уже готового набору гліфів.
        _ScaleStep(
          size: fontSize,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            // Анімується ТІЛЬКИ слот числа. Саме це рятує локалі з
            // символом попереду: інакше провідний «$» щоразу потрапляв
            // би в діф як новий гліф.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Знак «+» у режимі доходу — другий, незалежний від
                // капсули сигнал там, куди спрямований погляд
                // (Екрани п.1.4).
                if (income)
                  Text(
                    '+ ',
                    style: AppText.display
                        .copyWith(fontSize: fontSize, color: AppColors.income),
                  ),
                if (format.symbolFirst) symbol,
                AnimatedNumber(
                  text: format.number(value),
                  style: AppText.display
                      .copyWith(fontSize: fontSize, color: numberColor),
                ),
                if (!format.symbolFirst) symbol,
              ],
            ),
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

/// Міняє кегль стрибком у РОЗКЛАДЦІ, а плавність дає масштабуванням
/// уже розкладеного тексту.
///
/// Різниця принципова. Анімація самого кеглю змушує движок щокадру
/// заново розкладати й растеризувати гліфи — це послідовність різних
/// зображень, а не один об'єкт, що змінює розмір. [Transform.scale]
/// бере ОДИН готовий набір гліфів і масштабує його, тож перехід
/// читається як рух, а не як мерехтіння.
///
/// Побічна вигода: розкладка одразу стоїть у цільовому розмірі, тож
/// [FittedBox] під час переходу не втручається — інакше він стискав би
/// завелике проміжне число, і до зміни кеглю додавалось би друге,
/// незалежне масштабування.
class _ScaleStep extends StatefulWidget {
  const _ScaleStep({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  State<_ScaleStep> createState() => _ScaleStepState();
}

class _ScaleStepState extends State<_ScaleStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, value: 1);
  double _from = 1;

  @override
  void didUpdateWidget(_ScaleStep old) {
    super.didUpdateWidget(old);
    if (old.size == widget.size) return;
    // Стартуємо з відношення старого кеглю до нового: у першому кадрі
    // число візуально того ж розміру, що й було, далі сходиться до 1.
    _from = old.size / widget.size;
    _c.value = 0;
    _c.animateTo(
      1,
      duration: AppDurations.of(context, AppDurations.standard),
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
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final scale = lerpDouble(_from, 1, _c.value)!;
        if ((scale - 1).abs() < 0.001) return child!;
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}
