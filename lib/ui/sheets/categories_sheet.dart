import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/smart_categories.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_button.dart';
import '../common/app_emoji_avatar.dart';
import '../common/app_icon_button.dart';
import '../common/app_row.dart';
import '../common/app_sheet.dart';
import '../common/app_toast.dart';
import 'new_category_sheet.dart';

/// Шторка «Всі категорії» (Функціонал п.3, Екрани п.2): повний список
/// поточного типу, pin (макс [kSlotCount]), свайп-архівування, видалення
/// (рішення 49), пошук з >12 категорій, «Додати свою» закріплена внизу.
/// Тап по рядку повертає вибрану категорію.
Future<String?> showCategoriesSheet(
  BuildContext context, {
  required TxType type,
  String? selectedId,
}) {
  return showAppSheet<String>(
    context,
    heightFactor: 0.7,
    builder: (_) => _CategoriesSheet(type: type, selectedId: selectedId),
  );
}

class _CategoriesSheet extends ConsumerStatefulWidget {
  const _CategoriesSheet({required this.type, this.selectedId});

  final TxType type;
  final String? selectedId;

  @override
  ConsumerState<_CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends ConsumerState<_CategoriesSheet> {
  var _query = '';

  String _nameOf(Category c) => categoryDisplayName(context.l10n, c);

  void _togglePin(Category c, int pinnedCount) {
    // Максимум 5 закріплених (Функціонал п.2.4) — рівно стільки, скільки
    // слотів на головному екрані.
    if (!c.isPinned && pinnedCount >= kSlotCount) return;
    ref.read(categoryRepositoryProvider).setPinned(c.id, !c.isPinned);
  }

  void _archive(Category c) {
    final repo = ref.read(categoryRepositoryProvider);
    repo.setArchived(c.id, true);
    // Undo обов'язковий: екрана керування категоріями у v0.1 ще немає,
    // тож випадковий свайп без скасування зробив би категорію недосяжною.
    showAppToast(
      context,
      context.l10n.archived,
      actionLabel: context.l10n.undo,
      onAction: () => repo.setArchived(c.id, false),
      clearance: kSheetFooterHeight,
    );
  }

  /// Видалення (рішення 49): категорія без записів стирається назавжди
  /// (з Undo), категорія із записами лише архівується — історія не
  /// ламається ніколи.
  Future<void> _delete(Category c) async {
    final repo = ref.read(categoryRepositoryProvider);
    final l = context.l10n;
    if (await repo.hasTransactions(c.id)) {
      await repo.setArchived(c.id, true);
      if (!mounted) return;
      showAppToast(
        context,
        l.categoryHasRecords,
        actionLabel: l.undo,
        onAction: () => repo.setArchived(c.id, false),
        clearance: kSheetFooterHeight,
      );
    } else {
      // Якщо видалена була обрана на Екрані 1, вибір знімає слухач
      // у InputController — тут нічого робити не треба.
      await repo.deleteCategory(c.id);
      if (!mounted) return;
      showAppToast(
        context,
        l.deleted,
        actionLabel: l.undo,
        onAction: () => repo.insertExisting(c),
        clearance: kSheetFooterHeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final all =
        ref.watch(activeCategoriesProvider(widget.type)).value ?? const [];
    final pinnedCount = all.where((c) => c.isPinned).length;

    final q = _query.trim().toLowerCase();
    final visible = q.isEmpty
        ? all
        : [
            for (final c in all)
              if (_nameOf(c).toLowerCase().contains(q)) c,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: Text(context.l10n.categoriesTitle, style: AppText.title),
        ),
        const SizedBox(height: 12),
        // Пошук з'являється, коли категорій більше 12 (Функціонал п.3).
        if (all.length > 12)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.side,
              0,
              AppSpace.side,
              8,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppText.body,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: context.l10n.search,
                hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        Expanded(
          child: all.isEmpty
              // Усі категорії заархівовані (Функціонал п.11) —
              // підказка створити нову.
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.side),
                    child: Text(
                      context.l10n.allArchivedHint,
                      style: AppText.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final c = visible[i];
                    return SheetStaggered(
                      index: i,
                      child: _CategoryRow(
                        category: c,
                        name: _nameOf(c),
                        selected: c.id == widget.selectedId,
                        onTap: () => Navigator.of(context).pop(c.id),
                        onPin: () => _togglePin(c, pinnedCount),
                        onArchive: () => _archive(c),
                        onDelete: () => _delete(c),
                      ),
                    );
                  },
                ),
        ),
        // «Додати свою» — закріплена внизу, не скролиться
        // (Функціонал п.3).
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.side),
            child: AppButton(
              label: '＋ ${context.l10n.addCategory}',
              kind: AppButtonKind.neutral,
              onTap: () async {
                final id = await showNewCategorySheet(
                  context,
                  type: widget.type,
                );
                if (id != null && context.mounted) {
                  // Створена категорія одразу обирається.
                  Navigator.of(context).pop(id);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.name,
    required this.selected,
    required this.onTap,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  final Category category;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onArchive(),
      background: Container(
        color: AppColors.dangerSubtle,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
        child: const Icon(
          Icons.archive_outlined,
          color: AppColors.danger,
          size: 22,
        ),
      ),
      // Ліворуч поля немає: риска вибору стоїть впритул до краю, а
      // бічний відступ добирає SizedBox після неї.
      child: AppRow(
        onTap: onTap,
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            // Обрана зараз категорія — тонка м'ятна риска ліворуч
            // (Екрани п.2).
            Container(
              width: 3,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: AppSpace.side - 3),
            AppEmojiAvatar(emoji: category.emoji),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: AppText.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppIconButton(
              icon: category.isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              iconSize: 20,
              color: category.isPinned
                  ? AppColors.accent
                  : AppColors.textTertiary,
              onTap: onPin,
            ),
            // Видалення (рішення 49) — поряд із піном. Іконка
            // третинна, не червона: червоний спалахує тільки на
            // самій дії (свайп, кнопки підтвердження).
            AppIconButton(
              icon: Icons.delete_outline,
              iconSize: 20,
              color: AppColors.textTertiary,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
