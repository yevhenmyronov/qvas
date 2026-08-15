import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../models/money.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/locale_providers.dart';
import '../../repositories/transaction_repository.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';
import 'count_up.dart';

/// Три метрики за один погляд (Функціонал п.4.2): «Різниця» домінантна,
/// «Витрати» й «Доходи» другорядні. Голі цифри без карток (рішення 24).
///
/// Крайні стани (Екрани п.3.3, 3.4, 3.8):
/// - доходів нуль → «Різниця» й «Доходи» зникають, «Витрати» домінантні;
/// - місяць порожній → нулі приглушеним кольором.
///
/// Валюта одна на весь застосунок (рішення 57), тож стовпчика по
/// валютах більше немає — формат скрізь із налаштувань.
class MetricsHeader extends ConsumerWidget {
  const MetricsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Фільтр за категорією (Функціонал п.4.7): три метрики тимчасово
    // поступаються місцем одній — підсумку категорії за місяць.
    final filterId = ref.watch(categoryFilterProvider);
    if (filterId != null) return _FilterMetrics(categoryId: filterId);

    const MonthTotal empty = (spentMinor: 0, earnedMinor: 0);
    final total = ref.watch(monthTotalsProvider).value ?? empty;
    final today = ref.watch(todayExpenseProvider).value ?? 0;
    final mainFormat = ref.watch(moneyFormatProvider);

    return Column(
      children: [
        _Metrics(
          total: total,
          format: mainFormat,
          month: ref.watch(selectedMonthProvider),
        ),
        const SizedBox(height: 12),
        Text(context.l10n.todayTotal(mainFormat.full(today.toMajor)),
            style: AppText.caption),
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.total,
    required this.format,
    required this.month,
  });

  final MonthTotal total;
  final MoneyFormat format;

  /// Ключ «зрізати, а не рахувати»: інший місяць — це інша величина, а
  /// не зміна цієї, і в нього вже є власний перехід.
  final MonthKey month;

  @override
  Widget build(BuildContext context) {
    final spent = total.spentMinor.toMajor;
    final earned = total.earnedMinor.toMajor;
    final diff = earned - spent;
    final isEmpty = spent == 0 && earned == 0;
    final noIncome = earned == 0;

    const metricStyle = AppText.metric;
    const subStyle = AppText.metricSub;

    // Порожній місяць: нулі приглушеним кольором.
    final mutedColor = isEmpty ? AppColors.textTertiary : null;

    if (noIncome) {
      // Доходів нуль: «Витрати» — домінантна цифра, решта зникає.
      // Екран не має виглядати зламаним у того, хто доходи не вносить.
      return Column(
        children: [
          Text(context.l10n.expenses, style: AppText.caption),
          const SizedBox(height: 4),
          CountUp(
            value: spent,
            cutKey: month,
            builder: (context, v) => Text(
              format.full(v),
              style: metricStyle.copyWith(
                  color: mutedColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(context.l10n.difference, style: AppText.caption),
        const SizedBox(height: 4),
        CountUp(
          value: diff,
          cutKey: month,
          // Знак і колір рахуються з ПРОМІЖНОГО значення, тож перетин
          // нуля перекидає їх сам, у той самий момент, коли цифра
          // проходить нуль (Екрани п.3.1).
          //
          // Від'ємна — бурштин (рішення 69). Досі вона була білою: тобто
          // головна цифра застосунку не мала кольору саме тоді, коли
          // повідомляла найважливіше. Червоний сюди взяти не можна — він
          // означає тільки видалення.
          builder: (context, v) => Text(
            '${v >= 0 ? '+' : '−'} ${format.full(v.abs())}',
            style: metricStyle.copyWith(
              color:
                  mutedColor ?? (v >= 0 ? AppColors.income : AppColors.warn),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CountUp(
              value: spent,
              cutKey: month,
              builder: (context, v) => _Sub(
                  label: context.l10n.expenses,
                  text: format.full(v),
                  style: subStyle,
                  muted: isEmpty),
            ),
            const SizedBox(width: 40),
            CountUp(
              value: earned,
              cutKey: month,
              builder: (context, v) => _Sub(
                  label: context.l10n.incomes,
                  text: format.full(v),
                  style: subStyle,
                  muted: isEmpty),
            ),
          ],
        ),
      ],
    );
  }
}

/// Підсумок фільтра за категорією (Функціонал п.4.7): «☕ Кава ✕» +
/// домінантна сума за показаний місяць. Рядка «Сьогодні» тут немає —
/// він відповідає на інше питання.
class _FilterMetrics extends ConsumerWidget {
  const _FilterMetrics({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category =
        (ref.watch(categoriesByIdProvider).value ?? const {})[categoryId];
    // Порожнеча береться зі стрічки, не з суми: «немає записів» і
    // «записи на нуль» — різні стани, і приглушений колір лише в
    // першого.
    final feed = ref.watch(filteredFeedProvider);
    final format = ref.watch(moneyFormatProvider);
    final isIncome = category?.type == TxType.income;

    final amountColor = feed.isEmpty
        ? AppColors.textTertiary
        : isIncome
            ? AppColors.income
            : AppColors.textPrimary;

    String amountText(int minor) {
      final text = format.full(minor.toMajor);
      return isIncome ? '+ $text' : text;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${category?.emoji ?? ''} '
              '${categoryDisplayName(context.l10n, category)}',
              style: AppText.caption,
            ),
            const SizedBox(width: 4),
            Pressable(
              onTap: () =>
                  ref.read(categoryFilterProvider.notifier).state = null,
              builder: (context, pressed) => Semantics(
                label: context.l10n.a11yClearFilter,
                button: true,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close,
                      size: 14, color: AppColors.textTertiary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amountText(filterTotalOf(feed)),
          style: AppText.metric.copyWith(color: amountColor),
        ),
      ],
    );
  }
}

class _Sub extends StatelessWidget {
  const _Sub({
    required this.label,
    required this.text,
    required this.style,
    required this.muted,
  });

  final String label;
  final String text;
  final TextStyle style;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 2),
        Text(
          text,
          style: muted
              ? style.copyWith(color: AppColors.textTertiary)
              : style,
        ),
      ],
    );
  }
}
