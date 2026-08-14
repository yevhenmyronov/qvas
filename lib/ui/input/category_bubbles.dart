import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

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
    final top = ref.watch(topCategoriesProvider(type));
    final isIncome = type == TxType.income;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpace.bubbleGap,
      runSpacing: AppSpace.bubbleGap,
      children: [
        for (final c in top)
          _Bubble(
            height: height,
            emoji: c.emoji,
            label: c.nameKey != null
                ? AppStrings.categoryName(c.nameKey!)
                : (c.customName ?? ''),
            selected: c.id == selectedId,
            income: isIncome,
            onTap: () =>
                ref.read(inputProvider.notifier).selectCategory(c.id),
          ),
        // Шоста бульбашка — завжди статична «Більше…». Відкриває шторку
        // з повним списком (Фаза 4).
        _Bubble(
          height: height,
          emoji: '➕',
          label: AppStrings.more,
          selected: false,
          income: isIncome,
          onTap: () {
            // TODO(Фаза 4): шторка «Всі категорії».
          },
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
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
        duration: AppDurations.micro,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
