import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../providers/input_providers.dart';
import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Висота рядка коментаря під сумою. Стала, щоб порожній і заповнений
/// стани займали те саме місце: сума над ним не має смикатись від того,
/// набрано щось чи ні (той самий інваріант, що в `input_layout_test`).
const double kNoteRowHeight = 32;

/// Ліміт той самий, що в шторці редагування (Функціонал п.4.5): коментар
/// живе в одному рядку стрічки.
const int kNoteMaxLength = 60;

/// Коментар на Екрані 1 (Функціонал п.2.7) — тихий рядок прямо під сумою.
///
/// Друга спроба після рішення 48. Тоді поле стояло окремим рядком між
/// бульбашками й «Зберегти», тобто посеред шляху «сума → категорія →
/// зберегти», і читалось як ще один крок. Тут воно стоїть там, де й так
/// порожньо, і належить сумі: це підпис до неї, а не окремий блок. Без
/// рамки й заливки — до першого тапу це просто сірий напис.
///
/// Текст живе в [inputProvider], а не в контролері: так його підхоплюють
/// знімок вводу, скидання після запису й підказки — все, що вже вміє
/// працювати зі станом Екрана 1.
class NoteField extends ConsumerStatefulWidget {
  const NoteField({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  ConsumerState<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends ConsumerState<NoteField> {
  late final TextEditingController _text = TextEditingController(
    text: ref.read(inputProvider).note,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Стан міняється й без поля: скидання після запису, відновлення
    // знімка, тап по підказці. Контролер наздоганяє, курсор — у кінець.
    ref.listen(inputProvider.select((s) => s.note), (_, next) {
      if (next == _text.text) return;
      _text.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });

    return SizedBox(
      height: kNoteRowHeight,
      child: TextField(
        controller: _text,
        focusNode: widget.focusNode,
        onChanged: ref.read(inputProvider.notifier).setNote,
        onTapOutside: (_) => widget.focusNode.unfocus(),
        onSubmitted: (_) => widget.focusNode.unfocus(),
        maxLength: kNoteMaxLength,
        maxLines: 1,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        style: AppText.body.copyWith(color: AppColors.textSecondary),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          // Напис — запрошення, а не зразок: коли людина вже пише, він
          // заважає (відгук догфудингу 2026-10-05). Фокус перебудовує
          // поле через слухача на Екрані 1.
          hintText: widget.focusNode.hasFocus ? null : context.l10n.commentHint,
          hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
          counterText: '',
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// Висота слоту підказок під коментарем.
const double kNoteSuggestionsHeight = 36;

/// Підказки коментарів під полем (Функціонал п.2.7): що людина вже писала
/// в цій категорії. Тап підставляє текст і ховає клавіатуру — вибір із
/// підказки і є «готово».
///
/// Перша версія ставила їх на верхню грань клавіатури, і там вони лягали
/// поверх «Зберегти» — клавіатура накриває пад, а не стискає екран.
/// Під полем вони там, де людина вже дивиться, і нічого не накривають.
/// Слот під них зарезервований завжди ([visible] лише гасить вміст):
/// інакше поява чіпів зсувала б суму вгору посеред набору.
///
/// Чіпи загорнуті в [TextFieldTapRegion]: інакше дотик до них рахувався
/// б тапом повз поле, поле втрачало б фокус ще на натисканні, і чіп
/// зникав би з-під пальця раніше, ніж тап встигне відбутись.
class NoteSuggestions extends ConsumerWidget {
  const NoteSuggestions({
    super.key,
    required this.focusNode,
    required this.visible,
  });

  final FocusNode focusNode;
  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(inputProvider.select((s) => s.note.trim()));
    // Запит — лише поки поле у фокусі: слот стоїть на екрані завжди, але
    // питати базу про підказки, яких ніхто не побачить, нема чого.
    final all = visible
        ? ref.watch(noteSuggestionsProvider).value ?? const <String>[]
        : const <String>[];
    final suggestions = [
      for (final s in all)
        if (s != current) s,
    ];
    final shown = visible && suggestions.isNotEmpty;

    return SizedBox(
      height: kNoteSuggestionsHeight,
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: AppDurations.of(context, AppDurations.micro),
          child: shown ? _chips(ref, suggestions) : null,
        ),
      ),
    );
  }

  /// По центру, поки влазять; ширший за екран ряд гортається.
  Widget _chips(WidgetRef ref, List<String> suggestions) {
    return TextFieldTapRegion(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, s) in suggestions.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpace.bubbleGap),
                  _NoteChip(
                    label: s,
                    onTap: () {
                      ref.read(inputProvider.notifier).setNote(s);
                      focusNode.unfocus();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Капсула підказки — та сама хрома, що в чіпа дати у шторці
/// редагування: піднята поверхня з EdgeLight, натиснута темніє.
class _NoteChip extends StatelessWidget {
  const _NoteChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill);
    return Pressable(
      onTap: onTap,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.micro),
        height: kNoteSuggestionsHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? AppColors.bgPressed : AppColors.bgSurface,
          borderRadius: radius,
        ),
        foregroundDecoration: EdgeLight.decoration(radius, on: !pressed),
        child: Text(
          label,
          style: AppText.bodyStrong.copyWith(fontSize: 14),
          maxLines: 1,
        ),
      ),
    );
  }
}
