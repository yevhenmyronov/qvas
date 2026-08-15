import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/amount_input.dart';
import '../../models/dates.dart';
import '../../models/money.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../../theme/top_light.dart';
import '../common/app_button.dart';
import '../common/app_sheet.dart';
import '../common/pressable.dart';
import '../input/amount_display.dart';
import '../input/category_bubbles.dart';
import '../input/numpad.dart';

/// Шторка швидкого редагування (Функціонал п.4.5, Екрани п.4): сума з тим
/// самим падом і калькулятором, категорія стрічкою, коментар, дата
/// календарем — без вибору часу. Жодних окремих екранів редагування.
Future<void> showQuickEditSheet(BuildContext context, Transaction tx) {
  return showAppSheet<void>(
    context,
    resizeForKeyboard: true,
    safeAreaBottom: true,
    builder: (_) => _QuickEditSheet(tx: tx),
  );
}

class _QuickEditSheet extends ConsumerStatefulWidget {
  const _QuickEditSheet({required this.tx});

  final Transaction tx;

  @override
  ConsumerState<_QuickEditSheet> createState() => _QuickEditSheetState();
}

class _QuickEditSheetState extends ConsumerState<_QuickEditSheet> {
  late AmountInput _amount;
  late String _categoryId;
  late String _dateKey;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _amount = AmountInput(current: widget.tx.amountMinor.toMajor);
    _categoryId = widget.tx.categoryId;
    _dateKey = widget.tx.localDateKey;
    _note = TextEditingController(text: widget.tx.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _canSave => _amount.resolvedAmount > 0;

  Future<void> _pickDate() async {
    final p = parseDateKey(_dateKey);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(p.year, p.month, p.day),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateKey = localDateKeyOf(picked));
    }
  }

  Future<void> _save() async {
    final repo = ref.read(transactionRepositoryProvider);
    final navigator = Navigator.of(context);
    final noteText = _note.text.trim();
    await repo.applyEdit(
      original: widget.tx,
      amountMinor: _amount.resolvedAmount * 100,
      categoryId: _categoryId,
      note: noteText.isEmpty ? null : noteText,
      dateKey: _dateKey,
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(activeCategoriesProvider(widget.tx.type)).value ??
        const <Category>[];
    final p = parseDateKey(_dateKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.editTitle, style: AppText.title),
          const SizedBox(height: 12),
          Center(
            child: AmountDisplay(
              amount: _amount,
              format: ref.watch(moneyFormatProvider),
              baseSize: 48,
            ),
          ),
          SizedBox(
            height: AppSize.bubbleSmall,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, c) in categories.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpace.bubbleGap),
                  CategoryBubble(
                    height: AppSize.bubbleSmall,
                    emoji: c.emoji,
                    label: categoryDisplayName(context.l10n, c),
                    selected: c.id == _categoryId,
                    income: false,
                    onTap: () => setState(() => _categoryId = c.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLength: 60,
            style: AppText.body,
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: context.l10n.commentHint,
              hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
              counterText: '',
              filled: true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Дата — чіп з іконкою календаря: видно, що це кнопка
          // (відгук догфудингу: голий текст не читався як натискний).
          // Тільки календар, без другого кроку з годинником
          // (рішення 29).
          Align(
            alignment: Alignment.centerLeft,
            child: Pressable(
              onTap: _pickDate,
              builder: (context, pressed) => AnimatedContainer(
                duration: AppDurations.of(context, AppDurations.micro),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: pressed ? AppColors.bgPressed : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                foregroundDecoration: TopLight.decoration(
                  BorderRadius.circular(AppRadius.pill),
                  on: !pressed,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dayTitle(
                        ref.watch(localeTagProvider),
                        p.year,
                        p.month,
                        p.day,
                      ),
                      style: AppText.bodyStrong.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(label: context.l10n.save, enabled: _canSave, onTap: _save),
          const SizedBox(height: 12),
          // Плита без витягування: шторка вже має власні поля.
          NumpadWell(
            value: _amount,
            onChanged: (v) => setState(() => _amount = v),
            cellHeight: AppSize.padCellSmall,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
