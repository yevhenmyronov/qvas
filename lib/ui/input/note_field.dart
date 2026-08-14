import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Поле нотатки на Екрані 1 (Функціонал п.2.7): тихий рядок без рамки
/// між бульбашками й «Зберегти». Праворуч у тому самому рядку живуть
/// чіпи-підказки частих нотаток — висота екрана не змінюється ніколи.
///
/// Чіпи видно, поки нотатка порожня або поставлена чіпом; ручний набір
/// їх ховає. Єдина IME на екрані: клавіатура накриває пад (він у цей
/// момент не потрібен), «Done» закриває її.
class NoteField extends ConsumerStatefulWidget {
  const NoteField({super.key});

  static const height = 36.0;

  @override
  ConsumerState<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends ConsumerState<NoteField> {
  late final TextEditingController _controller = TextEditingController(
      text: ref.read(inputProvider.select((s) => s.note)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Зовнішні зміни нотатки (чіп, restore зі знімка, reset після
    // збереження) — у контролер поля. Ручний набір іде навпаки.
    ref.listen(inputProvider.select((s) => s.note), (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    final note = ref.watch(inputProvider.select((s) => s.note));
    final fromSuggestion =
        ref.watch(inputProvider.select((s) => s.noteFromSuggestion));
    final suggestions =
        ref.watch(noteSuggestionsProvider).value ?? const <String>[];
    final chipsVisible =
        suggestions.isNotEmpty && (note.isEmpty || fromSuggestion);

    return SizedBox(
      height: NoteField.height,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: ref.read(inputProvider.notifier).setNote,
              maxLength: 60,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: AppText.body,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: context.l10n.commentHint,
                hintStyle:
                    AppText.body.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          if (chipsVisible) ...[
            const SizedBox(width: 8),
            for (final s in suggestions) ...[
              const SizedBox(width: 6),
              _SuggestionChip(
                text: s,
                selected: fromSuggestion && note == s,
                onTap: () => ref
                    .read(inputProvider.notifier)
                    .toggleSuggestedNote(s),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Чіп-підказка: капсула з текстом нотатки. Обраний — заливка й обводка
/// акцентом, як у вибраної бульбашки категорії.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      builder: (context, pressed) => Container(
        height: 28,
        constraints: const BoxConstraints(maxWidth: 110),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSubtle : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: selected
              ? Border.all(color: AppColors.accent, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption.copyWith(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary),
        ),
      ),
    );
  }
}
