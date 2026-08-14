import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/app_strings.dart';
import '../../models/dates.dart';
import '../../models/format.dart';
import '../../models/money.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';

/// Стрічка (Функціонал п.4.3): групування за днями, найновіші зверху.
/// Часу немає ніде (рішення 29). Другий рівень рядка — тільки коментар.
class Feed extends ConsumerWidget {
  const Feed({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesByIdProvider).value ?? const {};

    final todayKey = localDateKeyOf(DateTime.now());
    final yesterdayKey = localDateKeyOf(
        DateTime.now().subtract(const Duration(days: 1)));

    // Групування за localDateKey — порядок уже правильний із запиту.
    final items = <Widget>[];
    String? currentDay;
    var dayExpense = 0;
    final dayBuffer = <Transaction>[];

    void flushDay() {
      final key = currentDay;
      if (key == null) return;
      final p = parseDateKey(key);
      final title = key == todayKey
          ? AppStrings.today
          : key == yesterdayKey
              ? AppStrings.yesterday
              : AppStrings.dayTitle(p.day, p.month);
      items.add(_DayHeader(title: title, expenseMajor: dayExpense.toMajor));
      for (final tx in dayBuffer) {
        items.add(TransactionTile(tx: tx, category: categories[tx.categoryId]));
      }
      dayBuffer.clear();
      dayExpense = 0;
    }

    for (final tx in transactions) {
      if (tx.localDateKey != currentDay) {
        flushDay();
        currentDay = tx.localDateKey;
      }
      dayBuffer.add(tx);
      if (tx.type == TxType.expense) dayExpense += tx.amountMinor;
    }
    flushDay();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpace.block),
      children: items,
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.title, required this.expenseMajor});

  final String title;
  final int expenseMajor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.side, AppSpace.side, AppSpace.side, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppText.caption),
          if (expenseMajor > 0)
            Text(formatMoney(expenseMajor), style: AppText.caption),
        ],
      ),
    );
  }
}

/// Рядок стрічки: один рівень; другий з'являється тільки якщо є коментар.
class TransactionTile extends ConsumerStatefulWidget {
  const TransactionTile({super.key, required this.tx, this.category});

  final Transaction tx;
  final Category? category;

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile> {
  bool _highlight = false;

  @override
  void initState() {
    super.initState();
    // Підсвічування нового рядка (Функціонал п.4.6): одноразове, згасає
    // за --d-highlight. Провайдер споживається, щоб не спалахувати повторно.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lastId = ref.read(lastSavedTxIdProvider);
      if (lastId == widget.tx.id) {
        ref.read(lastSavedTxIdProvider.notifier).state = null;
        setState(() => _highlight = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final c = widget.category;
    final isIncome = tx.type == TxType.income;
    final note = tx.note;
    final hasNote = note != null && note.isNotEmpty;

    final name = c == null
        ? ''
        : (c.nameKey != null
            ? AppStrings.categoryName(c.nameKey!)
            : (c.customName ?? ''));

    final amountText =
        '${isIncome ? '+' : '−'} ${formatMoney(tx.amountMinor.toMajor)}';

    final row = Container(
      height: hasNote ? 68 : 56,
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
            child: Text(c?.emoji ?? '', style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppText.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (hasNote)
                  Text(note,
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountText,
            style: AppText.bodyStrong.copyWith(
              color:
                  isIncome ? AppColors.income : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (!_highlight) return row;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: AppDurations.highlight,
      onEnd: () => setState(() => _highlight = false),
      builder: (context, t, child) => ColoredBox(
        color: Color.lerp(
          Colors.transparent,
          widget.tx.type == TxType.income
              ? AppColors.incomeSubtle
              : AppColors.accentSubtle,
          t,
        )!,
        child: child,
      ),
      child: row,
    );
  }
}
