import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/smart_categories.dart';
import '../../models/tx_type.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_button.dart';
import '../common/app_emoji_avatar.dart';
import '../common/app_icon_button.dart';
import '../common/app_row.dart';
import '../common/app_toast.dart';
import '../common/pressable.dart';
import '../sheets/new_category_sheet.dart';

final _allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

Route<void> manageCategoriesRoute() {
  return MaterialPageRoute<void>(
    builder: (_) => const ManageCategoriesScreen(),
  );
}

/// Керування категоріями (Екрани п.6.1): активні списком по типах,
/// архівовані внизу під заголовком «Архів» із можливістю повернути.
/// Кнопка створення закріплена внизу — як у шторці «Всі категорії».
class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(_allCategoriesProvider).value ?? const [];
    List<Category> activeOf(TxType type) => [
      for (final c in all)
        if (!c.isArchived && c.type == type) c,
    ];
    final archivedList = [
      for (final c in all)
        if (c.isArchived) c,
    ];
    final repo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        icon: Icons.chevron_left,
                        semanticLabel: MaterialLocalizations.of(context)
                            .backButtonTooltip,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Text(l.manageCategories, style: AppText.title),
                    ],
                  ),
                  // Витрати й доходи розділені заголовками (рішення 94):
                  // одним списком у два десятки рядків тип категорії
                  // ніяк не читався — його доводилось згадувати.
                  ..._activeSection(
                    context,
                    ref,
                    l.expenses,
                    activeOf(TxType.expense),
                  ),
                  ..._activeSection(
                    context,
                    ref,
                    l.incomes,
                    activeOf(TxType.income),
                  ),
                  if (archivedList.isNotEmpty) ...[
                    // Архів по типах НЕ ділиться: він короткий, а два
                    // майже порожні розділи коштували б більше, ніж
                    // дають.
                    _SectionHeader(l.archiveSection),
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
                                style: AppText.caption.copyWith(
                                  color: AppColors.accent,
                                ),
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
            // Створення тут доступне так само, як у шторці «Всі
            // категорії»: інакше єдиний шлях до нової категорії лежав
            // би через Екран 1 (рішення 93).
            Padding(
              padding: const EdgeInsets.all(AppSpace.side),
              child: AppButton(
                label: '＋ ${l.addCategory}',
                kind: AppButtonKind.neutral,
                // Тип не передається — його нема звідки успадкувати,
                // тож шторка питає сама.
                onTap: () => showNewCategorySheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Видалення (рішення 49): без записів — назавжди (з Undo), із
/// записами — лише архів. Та сама логіка, що у шторці «Всі категорії».
Future<void> _delete(BuildContext context, WidgetRef ref, Category c) async {
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

/// Активні категорії одного типу під власним заголовком. Порожній
/// розділ не показується разом із заголовком: «Доходи» без жодного
/// рядка виглядали б як помилка, а не як «усі заархівовані».
List<Widget> _activeSection(
  BuildContext context,
  WidgetRef ref,
  String title,
  List<Category> categories,
) {
  if (categories.isEmpty) return const [];
  final repo = ref.read(categoryRepositoryProvider);
  final pinnedCount = categories.where((c) => c.isPinned).length;

  return [
    _SectionHeader(title),
    for (final c in categories)
      _CategoryRow(
        category: c,
        trailing: AppIconButton(
          icon: c.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          iconSize: 20,
          color: c.isPinned ? AppColors.accent : AppColors.textTertiary,
          onTap: () {
            // Ліміт рахується в межах типу — слотів по [kSlotCount] на
            // кожен, і розділи тепер збігаються з цією межею.
            if (!c.isPinned && pinnedCount >= kSlotCount) return;
            repo.setPinned(c.id, !c.isPinned);
          },
        ),
        onDelete: () => _delete(context, ref, c),
      ),
  ];
}

/// Заголовок розділу — той самий для «Витрат», «Доходів» і «Архіву»,
/// щоб три однакові написи не розійшлись оформленням.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.side,
        AppSpace.block,
        AppSpace.side,
        8,
      ),
      child: Text(title, style: AppText.caption),
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
