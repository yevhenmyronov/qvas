import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/tx_type.dart';
import '../../providers/input_providers.dart';
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isIncome ? '+' : '−',
                style: AppText.bodyStrong.copyWith(color: color)),
            const SizedBox(width: 6),
            Text(isIncome ? AppStrings.income : AppStrings.expense,
                style: AppText.bodyStrong.copyWith(color: color)),
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
