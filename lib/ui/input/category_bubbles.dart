import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';
import '../sheets/categories_sheet.dart';

/// Бульбашки категорій — капсули з емодзі й назвою в один рядок, вільний
/// потік із переносом, ряди по центру (рішення 21, Функціонал п.2.3).
/// Без спільного контейнера: висять просто на фоні.
/// Ніколи не скролляться й не ховаються.
class CategoryBubbles extends ConsumerWidget {
  const CategoryBubbles({super.key, this.height = AppSize.bubble});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(inputProvider.select((s) => s.type));
    final selectedId = ref.watch(inputProvider.select((s) => s.categoryId));
    final isIncome = type == TxType.income;

    // Категорія, обрана зі шторки й відсутня в п'ятірці, тимчасово посідає
    // місце останньої бульбашки і підсвічується (рішення 31) — інакше після
    // шторки не видно, що саме обрано. Після скидання вибору склад
    // повертається.
    final top = [...ref.watch(topCategoriesProvider(type))];
    if (selectedId != null && !top.any((c) => c.id == selectedId)) {
      final picked =
          ref.watch(categoriesByIdProvider).value?[selectedId];
      if (picked != null && top.isNotEmpty) {
        top[top.length - 1] = picked;
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpace.bubbleGap,
      runSpacing: AppSpace.bubbleGap,
      children: [
        for (final c in top)
          CategoryBubble(
            height: height,
            emoji: c.emoji,
            label: categoryDisplayName(context.l10n, c),
            selected: c.id == selectedId,
            income: isIncome,
            onTap: () =>
                ref.read(inputProvider.notifier).selectCategory(c.id),
          ),
        // Шоста бульбашка — завжди статична «Більше…»: шторка з повним
        // списком. Вибір повертається вже обраною категорією.
        CategoryBubble(
          height: height,
          emoji: '➕',
          label: context.l10n.more,
          selected: false,
          income: isIncome,
          onTap: () async {
            final picked = await showCategoriesSheet(
              context,
              type: type,
              selectedId: selectedId,
            );
            if (picked != null) {
              ref.read(inputProvider.notifier).setCategory(picked);
            }
          },
        ),
      ],
    );
  }
}

/// Одна капсула категорії — використовується в бульбашках Екрана 1
/// і в горизонтальній стрічці шторки редагування.
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.height,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.income,
    required this.onTap,
  });

  final double height;
  final String emoji;
  final String label;
  final bool selected;
  final bool income;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = income ? AppColors.income : AppColors.accent;
    final subtle = income ? AppColors.incomeSubtle : AppColors.accentSubtle;

    return Pressable(
      onTap: onTap,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.micro),
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? subtle
              : (pressed ? AppColors.bgSurfaceHigh : AppColors.bgSurface),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          // Розмір при виборі не змінюється — межа малюється завжди,
          // просто прозора, щоб ряд не «дихав» (DS п.2).
          border: Border.all(
            width: 1.5,
            color: selected ? accent : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              // Кегль зменшений разом із капсулою (рішення 32).
              style: AppText.bodyStrong.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
