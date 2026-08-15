import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/smart_categories.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_emoji_avatar.dart';
import '../common/app_icon_button.dart';
import '../common/app_row.dart';
import '../common/app_toast.dart';
import '../common/pressable.dart';

final _allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

Route<void> manageCategoriesRoute() {
  return MaterialPageRoute<void>(
      builder: (_) => const ManageCategoriesScreen());
}

/// Керування категоріями (Екрани п.6.1): активні списком по типах,
/// архівовані внизу під заголовком «Архів» із можливістю повернути.
class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  /// Видалення (рішення 49): без записів — назавжди (з Undo), із
  /// записами — лише архів. Та сама логіка, що у шторці «Всі категорії».
  Future<void> _delete(
      BuildContext context, WidgetRef ref, Category c) async {
    final repo = ref.read(categoryRepositoryProvider);
    final l = context.l10n;
    if (await repo.hasTransactions(c.id)) {
      await repo.setArchived(c.id, true);
      if (!context.mounted) return;
      showAppToast(
        context,
        l.categoryHasRecords,
        actionLabel: l.undo,
        onAction: () => repo.setArchived(c.id, false),
      );
    } else {
      // Вибір на Екрані 1 знімає слухач у InputController.
      await repo.deleteCategory(c.id);
      if (!context.mounted) return;
      showAppToast(
        context,
        l.deleted,
        actionLabel: l.undo,
        onAction: () => repo.insertExisting(c),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(_allCategoriesProvider).value ?? const [];
    final active = [
      for (final c in all)
        if (!c.isArchived) c,
    ];
    final archivedList = [
      for (final c in all)
        if (c.isArchived) c,
    ];
    final repo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              children: [
                AppIconButton(
                  icon: Icons.chevron_left,
                  semanticLabel:
                      MaterialLocalizations.of(context).backButtonTooltip,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Text(l.manageCategories, style: AppText.title),
              ],
            ),
            const SizedBox(height: AppSpace.side),
            for (final c in active)
              _CategoryRow(
                category: c,
                trailing: AppIconButton(
                  icon: c.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  iconSize: 20,
                  color: c.isPinned
                      ? AppColors.accent
                      : AppColors.textTertiary,
                  onTap: () {
                    final pinnedCount = active
                        .where((x) => x.type == c.type && x.isPinned)
                        .length;
                    if (!c.isPinned && pinnedCount >= kSlotCount) return;
                    repo.setPinned(c.id, !c.isPinned);
                  },
                ),
                onDelete: () => _delete(context, ref, c),
              ),
            if (archivedList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.side, AppSpace.block, AppSpace.side, 8),
                child:
                    Text(l.archiveSection, style: AppText.caption),
              ),
              for (final c in archivedList)
                _CategoryRow(
                  category: c,
                  muted: true,
                  // Текстова дія, а не кнопка-іконка: «Повернути» треба
                  // саме прочитати. Тому [AppIconButton] тут не підходить
                  // — спільний у них лише відгук на дотик.
                  trailing: Pressable(
                    onTap: () => repo.setArchived(c.id, false),
                    builder: (context, pressed) => SizedBox(
                      height: AppSize.minTouch,
                      child: Center(
                        child: Text(
                          l.restoreCategory,
                          style: AppText.caption
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                  onDelete: () => _delete(context, ref, c),
                ),
            ],
            const SizedBox(height: AppSpace.block),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({
    required this.category,
    required this.trailing,
    required this.onDelete,
    this.muted = false,
  });

  final Category category;
  final Widget trailing;
  final VoidCallback onDelete;
  final bool muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = categoryDisplayName(context.l10n, category);
    // Сам рядок не натискний: усі дії тут — на кнопках праворуч.
    return AppRow(
      padding: AppRow.actionPadding,
      child: Row(
        children: [
          AppEmojiAvatar(emoji: category.emoji),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: muted
                  ? AppText.body.copyWith(color: AppColors.textTertiary)
                  : AppText.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
          AppIconButton(
            icon: Icons.delete_outline,
            iconSize: 20,
            color: AppColors.textTertiary,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
