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

/// Три метрики за один погляд (Функціонал п.4.2): «Різниця» домінантна,
/// «Витрати» й «Доходи» другорядні. Голі цифри без карток (рішення 24).
///
/// Крайні стани (Екрани п.3.3, 3.4, 3.8):
/// - доходів нуль → «Різниця» й «Доходи» зникають, «Витрати» домінантні;
/// - місяць порожній → нулі приглушеним кольором;
/// - кілька валют → стовпчик по валютах, кегль на крок менший,
///   валюти ніколи не складаються.
class MetricsHeader extends ConsumerWidget {
  const MetricsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Фільтр за категорією (Функціонал п.4.7): три метрики тимчасово
    // поступаються місцем одній — підсумку категорії за місяць.
    final filterId = ref.watch(categoryFilterProvider);
    if (filterId != null) return _FilterMetrics(categoryId: filterId);

    final totals = ref.watch(monthTotalsProvider).value ?? const [];
    final today = ref.watch(todayExpenseProvider).value ?? 0;
    final localeTag = ref.watch(localeTagProvider);
    final mainFormat = ref.watch(moneyFormatProvider);

    Widget block;
    if (totals.length > 1) {
      // Кілька валют — стовпчик, кожна своїм рядком, ніколи не складаються
      // (Функціонал п.5).
      block = Column(
        children: [
          for (final (i, t) in totals.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            _CurrencyMetrics(
              total: t,
              format: MoneyFormat.of(localeTag, t.currencyCode),
              compact: true,
            ),
          ],
        ],
      );
    } else {
      final t = totals.isEmpty
          ? (
              currencyCode: ref.watch(currencyCodeProvider),
              spentMinor: 0,
              earnedMinor: 0
            )
          : totals.first;
      block = _CurrencyMetrics(
        total: t,
        format: MoneyFormat.of(localeTag, t.currencyCode),
        compact: false,
      );
    }

    return Column(
      children: [
        block,
        const SizedBox(height: 12),
        Text(
            context.l10n.todayTotal(mainFormat.full(today.toMajor)),
            style: AppText.caption),
      ],
    );
  }
}

class _CurrencyMetrics extends StatelessWidget {
  const _CurrencyMetrics({
    required this.total,
    required this.format,
    required this.compact,
  });

  final MonthTotal total;
  final MoneyFormat format;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spent = total.spentMinor.toMajor;
    final earned = total.earnedMinor.toMajor;
    final diff = earned - spent;
    final isEmpty = spent == 0 && earned == 0;
    final noIncome = earned == 0;

    final metricStyle = compact
        ? AppText.metric.copyWith(fontSize: 32)
        : AppText.metric;
    final subStyle = compact
        ? AppText.metricSub.copyWith(fontSize: 20)
        : AppText.metricSub;

    // Порожній місяць: нулі приглушеним кольором.
    final mutedColor = isEmpty ? AppColors.textTertiary : null;

    if (noIncome) {
      // Доходів нуль: «Витрати» — домінантна цифра, решта зникає.
      // Екран не має виглядати зламаним у того, хто доходи не вносить.
      return Column(
        children: [
          Text(context.l10n.expenses, style: AppText.caption),
          const SizedBox(height: 4),
          Text(
            format.full(spent),
            style: metricStyle.copyWith(
                color: mutedColor ?? AppColors.textPrimary),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(context.l10n.difference, style: AppText.caption),
        const SizedBox(height: 4),
        Text(
          '${diff >= 0 ? '+' : '−'} ${format.full(diff.abs())}',
          style: metricStyle.copyWith(
            // Синій якщо +, білий якщо − (Екрани п.3.1).
            color: mutedColor ??
                (diff >= 0 ? AppColors.income : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Sub(
                label: context.l10n.expenses,
                text: format.full(spent),
                style: subStyle,
                muted: isEmpty),
            const SizedBox(width: 40),
            _Sub(
                label: context.l10n.incomes,
                text: format.full(earned),
                style: subStyle,
                muted: isEmpty),
          ],
        ),
      ],
    );
  }
}

/// Підсумок фільтра за категорією (Функціонал п.4.7): «☕ Кава ✕» +
/// домінантна сума за показаний місяць. Рядка «Сьогодні» тут немає —
/// він відповідає на інше питання. Кілька валют — стовпчик, як у метрик.
class _FilterMetrics extends ConsumerWidget {
  const _FilterMetrics({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category =
        (ref.watch(categoriesByIdProvider).value ?? const {})[categoryId];
    final totals = filterTotalsOf(ref.watch(filteredFeedProvider));
    final localeTag = ref.watch(localeTagProvider);
    final isIncome = category?.type == TxType.income;

    final amountColor = totals.isEmpty
        ? AppColors.textTertiary
        : isIncome
            ? AppColors.income
            : AppColors.textPrimary;

    String amountText(String currencyCode, int minor) {
      final text =
          MoneyFormat.of(localeTag, currencyCode).full(minor.toMajor);
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
        if (totals.isEmpty)
          Text(
            amountText(ref.watch(currencyCodeProvider), 0),
            style: AppText.metric.copyWith(color: amountColor),
          )
        else ...[
          for (final (i, t) in totals.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Text(
              amountText(t.currencyCode, t.totalMinor),
              style: (totals.length > 1
                      ? AppText.metric.copyWith(fontSize: 32)
                      : AppText.metric)
                  .copyWith(color: amountColor),
            ),
          ],
        ],
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
