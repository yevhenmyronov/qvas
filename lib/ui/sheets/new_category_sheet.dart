import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/emoji_set.dart';
import '../../l10n/l10n.dart';
import '../../models/tx_type.dart';
import '../../providers/core_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Створення власної категорії (Функціонал п.3.1, Екрани п.2.1):
/// емодзі + назва (20 символів, лічильник з 15-го) + успадкований тип.
/// Повертає id створеної категорії.
Future<String?> showNewCategorySheet(BuildContext context,
    {required TxType type}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _NewCategorySheet(type: type),
  );
}

class _NewCategorySheet extends ConsumerStatefulWidget {
  const _NewCategorySheet({required this.type});

  final TxType type;

  @override
  ConsumerState<_NewCategorySheet> createState() =>
      _NewCategorySheetState();
}

class _NewCategorySheetState extends ConsumerState<_NewCategorySheet> {
  String? _emoji;
  late final TextEditingController _name = TextEditingController()
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canCreate =>
      _emoji != null && _name.text.trim().isNotEmpty;

  Future<void> _pickEmoji() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const _EmojiPicker(),
    );
    if (picked != null) setState(() => _emoji = picked);
  }

  Future<void> _create() async {
    final id = await ref.read(categoryRepositoryProvider).createCustom(
          type: widget.type,
          name: _name.text.trim(),
          emoji: _emoji!,
        );
    if (mounted) Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final length = _name.text.characters.length;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSurfaceHigh,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpace.side),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(l.newCategoryTitle, style: AppText.title),
                const SizedBox(height: AppSpace.side),
                Center(
                  child: Pressable(
                    onTap: _pickEmoji,
                    builder: (context, pressed) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: pressed
                            ? AppColors.bgSurface
                            : AppColors.bgSurface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.button),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _emoji ?? '🙂',
                        style: TextStyle(
                          fontSize: 28,
                          color: _emoji == null
                              ? AppColors.textTertiary
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.side),
                TextField(
                  controller: _name,
                  maxLength: 20,
                  style: AppText.body,
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: l.categoryNameHint,
                    hintStyle: AppText.body
                        .copyWith(color: AppColors.textTertiary),
                    // Лічильник тільки з 15-го символу (Екрани п.2.1).
                    counterText: length >= 15 ? '$length/20' : '',
                    counterStyle: AppText.caption,
                    filled: true,
                    fillColor: AppColors.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                // Тип успадкований, не редагується — прибирає цілий
                // клас плутанини (Функціонал п.3.1).
                Text(
                  widget.type == TxType.expense ? l.expense : l.income,
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpace.side),
                Pressable(
                  enabled: _canCreate,
                  onTap: _create,
                  builder: (context, pressed) => Container(
                    height: AppSize.saveButton,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _canCreate
                          ? (pressed
                              ? AppColors.accentPressed
                              : AppColors.accent)
                          : AppColors.bgSurface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l.create,
                      style: AppText.bodyStrong.copyWith(
                        color: _canCreate
                            ? AppColors.onAccent
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Пікер емодзі (Екрани п.2.2): сітка 6 у ряд, групи з заголовками,
/// без пошуку — гортати ~200 гліфів швидше, ніж набирати назву.
/// Власний і обмежений вшитим набором: системна клавіатура могла б
/// вставити гліф, якого не буде в сабсеті шрифту (тех. спека п.7).
class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker();

  String _groupName(BuildContext context, String key) {
    final l = context.l10n;
    return switch (key) {
      'food' => l.groupFood,
      'transport' => l.groupTransport,
      'home' => l.groupHome,
      'health' => l.groupHealth,
      'fun' => l.groupFun,
      'money' => l.groupMoney,
      _ => l.groupOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.bgSurfaceHigh,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.side, vertical: 8),
              children: [
                for (final group in emojiGroups) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_groupName(context, group.key),
                        style: AppText.caption),
                  ),
                  GridView.count(
                    crossAxisCount: 6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final e in group.emojis)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(e),
                          child: Center(
                            child: Text(e,
                                style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
