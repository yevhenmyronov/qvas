import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
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
                Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  builder: (context, pressed) => const SizedBox(
                    width: AppSize.minTouch,
                    height: AppSize.minTouch,
                    child: Icon(Icons.chevron_left,
                        size: 24, color: AppColors.textSecondary),
                  ),
                ),
                Text(l.manageCategories, style: AppText.title),
              ],
            ),
            const SizedBox(height: AppSpace.side),
            for (final c in active)
              _CategoryRow(
                category: c,
                trailing: Icon(
                  c.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 20,
                  color: c.isPinned
                      ? AppColors.accent
                      : AppColors.textTertiary,
                ),
                onTrailingTap: () {
                  final pinnedCount = active
                      .where((x) => x.type == c.type && x.isPinned)
                      .length;
                  if (!c.isPinned && pinnedCount >= 5) return;
                  repo.setPinned(c.id, !c.isPinned);
                },
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
                  trailing: Text(
                    l.restoreCategory,
                    style: AppText.caption
                        .copyWith(color: AppColors.accent),
                  ),
                  onTrailingTap: () => repo.setArchived(c.id, false),
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
    required this.onTrailingTap,
    this.muted = false,
  });

  final Category category;
  final Widget trailing;
  final VoidCallback onTrailingTap;
  final bool muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = categoryDisplayName(context.l10n, category);
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
        child: Row(
          children: [
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
              child: Text(
                name,
                style: muted
                    ? AppText.body
                        .copyWith(color: AppColors.textTertiary)
                    : AppText.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: AppSize.minTouch,
                child: Center(child: trailing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
