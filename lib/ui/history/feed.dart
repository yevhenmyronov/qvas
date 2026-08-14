import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../models/dates.dart';
import '../../models/money.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/input_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../sheets/quick_edit_sheet.dart';

/// Стрічка (Функціонал п.4.3): групування за днями, найновіші зверху.
/// Часу немає ніде (рішення 29). Другий рівень рядка — тільки коментар.
class Feed extends ConsumerWidget {
  const Feed({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesByIdProvider).value ?? const {};
    final mainFormat = ref.watch(moneyFormatProvider);

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
          ? context.l10n.today
          : key == yesterdayKey
              ? context.l10n.yesterday
              : dayTitle(ref.watch(localeTagProvider), p.year, p.month,
                  p.day);
      items.add(_DayHeader(
          title: title,
          totalText: dayExpense > 0
              ? mainFormat.full(dayExpense.toMajor)
              : null));
      for (final tx in dayBuffer) {
        // Ключ обов'язковий: без нього Flutter перевикористовує стан
        // рядка на тій самій позиції, і підсвічування нового запису
        // (п.4.6) ніколи не запускається.
        items.add(TransactionTile(
          key: ValueKey(tx.id),
          tx: tx,
          category: categories[tx.categoryId],
        ));
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
  const _DayHeader({required this.title, this.totalText});

  final String title;
  final String? totalText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.side, AppSpace.side, AppSpace.side, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppText.caption),
          if (totalText != null)
            Text(totalText!, style: AppText.caption),
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
  ProviderSubscription<String?>? _sub;

  @override
  void initState() {
    super.initState();
    // Підсвічування нового рядка (Функціонал п.4.6): одноразове, згасає
    // за --d-highlight. Рядок і перевіряє поточне значення при народженні,
    // і слухає пізніші зміни — порядок «стрічка оновилась / id виставлено»
    // не гарантований.
    _sub = ref.listenManual<String?>(lastSavedTxIdProvider,
        (_, next) => _maybeHighlight(next));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeHighlight(ref.read(lastSavedTxIdProvider));
    });
  }

  void _maybeHighlight(String? lastId) {
    if (lastId != widget.tx.id || _highlight) return;
    // Провайдер споживається, щоб не спалахувати повторно; скидання —
    // поза фазою нотифікації.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(lastSavedTxIdProvider) == widget.tx.id) {
        ref.read(lastSavedTxIdProvider.notifier).state = null;
      }
    });
    if (mounted) setState(() => _highlight = true);
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  /// Видалення свайпом (Функціонал п.4.4): м'яке, з Undo-тостом на 5 секунд.
  /// Друге з двох місць вібрації в застосунку.
  void _delete() {
    hapticImpact(ref);
    final repo = ref.read(transactionRepositoryProvider);
    final id = widget.tx.id;
    repo.softDelete(id);
    showAppToast(
      context,
      context.l10n.deleted,
      actionLabel: context.l10n.undo,
      onAction: () => repo.restore(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final c = widget.category;
    final isIncome = tx.type == TxType.income;
    final note = tx.note;
    final hasNote = note != null && note.isNotEmpty;

    final name = categoryDisplayName(context.l10n, c);

    // Кожен запис — у СВОЇЙ валюті (Функціонал п.5): зміна валюти
    // в налаштуваннях старі записи не чіпає.
    final txFormat = MoneyFormat.of(
        ref.watch(localeTagProvider), tx.currencyCode);
    final amountText =
        '${isIncome ? '+' : '−'} ${txFormat.full(tx.amountMinor.toMajor)}';

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

    // Тап — швидке редагування; свайп вліво — видалення. Червоний колір
    // у застосунку означає тільки видалення й з'являється тільки тут.
    final interactive = Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(),
      background: Container(
        color: AppColors.dangerSubtle,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline,
                color: AppColors.danger, size: 22),
            const SizedBox(width: 8),
            Text(context.l10n.delete,
                style:
                    AppText.bodyStrong.copyWith(color: AppColors.danger)),
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showQuickEditSheet(context, tx),
        child: row,
      ),
    );

    if (!_highlight) return interactive;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: AppDurations.of(context, AppDurations.highlight),
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
      child: interactive,
    );
  }
}
