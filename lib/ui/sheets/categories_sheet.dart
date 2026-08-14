import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../common/pressable.dart';
import 'new_category_sheet.dart';

/// Шторка «Всі категорії» (Функціонал п.3, Екрани п.2): повний список
/// поточного типу, pin (макс 5), свайп-архівування, пошук з >12 категорій.
/// Тап по рядку повертає вибрану категорію.
///
/// Кнопки «Додати свою» у v0.1 немає — створення кастомних категорій
/// відкладено до v0.2 (План розробки).
Future<String?> showCategoriesSheet(
  BuildContext context, {
  required TxType type,
  String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
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
    // Максимум 5 закріплених (Функціонал п.2.4).
    if (!c.isPinned && pinnedCount >= 5) return;
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
    );
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

    // Шторка — 70% екрана, далі внутрішній скрол (Екрани п.2).
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.bgSurfaceHigh,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpace.side),
            child:
                Text(context.l10n.categoriesTitle, style: AppText.title),
          ),
          const SizedBox(height: 12),
          // Пошук з'являється, коли категорій більше 12 (Функціонал п.3).
          if (all.length > 12)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.side, 0, AppSpace.side, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppText.body,
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: context.l10n.search,
                  hintStyle:
                      AppText.body.copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
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
                      child: Text(context.l10n.allArchivedHint,
                          style: AppText.caption,
                          textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final c = visible[i];
                      return _CategoryRow(
                        category: c,
                        name: _nameOf(c),
                        selected: c.id == widget.selectedId,
                        onTap: () => Navigator.of(context).pop(c.id),
                        onPin: () => _togglePin(c, pinnedCount),
                        onArchive: () => _archive(c),
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
              child: Pressable(
                onTap: () async {
                  final id = await showNewCategorySheet(context,
                      type: widget.type);
                  if (id != null && context.mounted) {
                    // Створена категорія одразу обирається.
                    Navigator.of(context).pop(id);
                  }
                },
                builder: (context, pressed) => Container(
                  height: AppSize.saveButton,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pressed
                        ? AppColors.bgSurface
                        : AppColors.bgSurface,
                    borderRadius:
                        BorderRadius.circular(AppRadius.button),
                  ),
                  alignment: Alignment.center,
                  child: Text('＋ ${context.l10n.addCategory}',
                      style: AppText.bodyStrong),
                ),
              ),
            ),
          ),
        ],
      ),
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
  });

  final Category category;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;

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
        child: const Icon(Icons.archive_outlined,
            color: AppColors.danger, size: 22),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              // Обрана зараз категорія — тонка м'ятна риска ліворуч
              // (Екрани п.2).
              Container(
                width: 3,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpace.side - 3),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.bgSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(category.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: AppText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: onPin,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: AppSize.minTouch,
                  height: AppSize.minTouch,
                  child: Icon(
                    category.isPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    size: 20,
                    color: category.isPinned
                        ? AppColors.accent
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
