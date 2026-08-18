import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/money.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_emoji_avatar.dart';
import '../common/app_row.dart';
import '../common/app_sheet.dart';

/// Розкладка місяця за категоріями: куди пішли гроші, від найбільшого.
///
/// Відповідає на питання, на яке три метрики не відповідають — і саме
/// це, а не бажання «додати статистику», було приводом. Догфудинг
/// показав, що «скільки всього» і «куди саме» — різні питання.
///
/// **Це список, а не діаграма** ([[Scope]]): жодних кілець, стовпчиків
/// і кольорових шкал «багато/мало». Ранг несе порядок, величину —
/// число.
///
/// Місяць не вибирається тут: він успадкований з Екрана 2 через
/// [categoryBreakdownProvider]. Другий перемикач місяців означав би два
/// місця, де стоїть та сама відповідь.
Future<void> showBreakdownSheet(
  BuildContext context, {
  required TxType type,
}) {
  return showAppSheet<void>(
    context,
    heightFactor: 0.7,
    builder: (_) => _BreakdownSheet(type: type),
  );
}

class _BreakdownSheet extends ConsumerWidget {
  const _BreakdownSheet({required this.type});

  final TxType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranked = ref.watch(categoryBreakdownProvider(type)).value ?? const [];
    final categories = ref.watch(categoriesByIdProvider).value ?? const {};
    final format = ref.watch(moneyFormatProvider);
    final l = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          // Місяця в заголовку немає: шторка не накриває панель, і
          // «Серпень 2026» лишається видимим просто над цим рядком.
          child: Text(
            type == TxType.expense ? l.expenses : l.incomes,
            style: AppText.title,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ranked.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.side),
                    child: Text(
                      l.emptyMonth,
                      style: AppText.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: ranked.length,
                  itemBuilder: (context, i) {
                    final s = ranked[i];
                    return SheetStaggered(
                      index: i,
                      child: _ShareRow(
                        emoji: categories[s.categoryId]?.emoji ?? '',
                        name: categoryDisplayName(l, categories[s.categoryId]),
                        amount: format.full(s.totalMinor.toMajor),
                        isIncome: type == TxType.income,
                        // Загальна картина переходить у конкретну наявним
                        // механізмом фільтра (рішення 47), а не власним
                        // екраном категорії.
                        onTap: () {
                          ref.read(categoryFilterProvider.notifier).state =
                              s.categoryId;
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.emoji,
    required this.name,
    required this.amount,
    required this.isIncome,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final String amount;
  final bool isIncome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppRow(
      // Однорівневий рядок: назва й сума в одну лінію. Другий рівень тут
      // тримав частку у відсотках і коштував 12dp висоти на кожну
      // категорію — тобто три категорії з поля зору за список, який
      // існує саме заради «побачити картину цілком».
      onTap: onTap,
      child: Row(
        children: [
          AppEmojiAvatar(emoji: emoji),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppText.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: AppText.bodyStrong.copyWith(
              color: isIncome ? AppColors.income : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
