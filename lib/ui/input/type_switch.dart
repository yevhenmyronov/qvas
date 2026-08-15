import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/tx_type.dart';
import '../../providers/input_providers.dart';
import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Перемикач «Витрата / Дохід» — одна капсула, яка показує поточний стан
/// і перемикається тапом (Функціонал п.2.1, рішення 28).
/// Витрата — нейтральна (норма не потребує кольору), дохід — синій.
/// Без вібрації; відгук візуальний за --d-micro.
class TypeSwitch extends ConsumerWidget {
  const TypeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(inputProvider.select((s) => s.type));
    final isIncome = type == TxType.income;

    final color =
        isIncome ? AppColors.income : AppColors.textPrimary;

    return Pressable(
      onTap: () => ref.read(inputProvider.notifier).toggleType(),
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.micro),
        height: AppSize.typeSwitch,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isIncome ? AppColors.incomeSubtle : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        foregroundDecoration:
            EdgeLight.decoration(BorderRadius.circular(AppRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isIncome ? '+' : '−',
                style: AppText.bodyStrong.copyWith(color: color)),
            const SizedBox(width: 6),
            // Ширина капсули береться по ДОВШОМУ з двох підписів, інакше
            // вона стрибає при кожному перемиканні: «Витрата» і «Дохід»
            // різної довжини, і елемент смикався під пальцем.
            _FixedWidthLabel(
              text: isIncome ? context.l10n.income : context.l10n.expense,
              alternative:
                  isIncome ? context.l10n.expense : context.l10n.income,
              style: AppText.bodyStrong.copyWith(color: color),
            ),
            const SizedBox(width: 6),
            // Гліф ⇄ обов'язковий: без нього капсула читається як статичний
            // підпис, а не як щось натискне (DS п.2).
            const Icon(Icons.swap_horiz,
                size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Підпис, що займає ширину найдовшого зі своїх можливих значень.
///
/// Обидва варіанти малюються один поверх одного в [Stack]: невидимий
/// задає ширину, видимий її заповнює. Це дешевше й точніше за ручний
/// обмір через TextPainter — ширина рахується тим самим кодом, що й
/// малює текст, тож не розійдеться ні на іншому шрифті, ні на іншому
/// масштабі системного тексту.
class _FixedWidthLabel extends StatelessWidget {
  const _FixedWidthLabel({
    required this.text,
    required this.alternative,
    required this.style,
  });

  final String text;
  final String alternative;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(alternative, style: style),
        ),
        Text(text, style: style),
      ],
    );
  }
}
