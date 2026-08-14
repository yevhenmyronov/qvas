import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/format.dart';
import '../../models/money.dart';
import '../../providers/history_providers.dart';
import '../../repositories/transaction_repository.dart';
import '../../theme/tokens.dart';

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
    final totals = ref.watch(monthTotalsProvider).value ?? const [];
    final today = ref.watch(todayExpenseProvider).value ?? 0;

    Widget block;
    if (totals.length > 1) {
      block = Column(
        children: [
          for (final (i, t) in totals.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            _CurrencyMetrics(total: t, compact: true),
          ],
        ],
      );
    } else {
      final t = totals.isEmpty
          ? (currencyCode: kCurrencyCode, spentMinor: 0, earnedMinor: 0)
          : totals.first;
      block = _CurrencyMetrics(total: t, compact: false);
    }

    return Column(
      children: [
        block,
        const SizedBox(height: 12),
        Text(AppStrings.todayTotal(formatMoney(today.toMajor)),
            style: AppText.caption),
      ],
    );
  }
}

class _CurrencyMetrics extends StatelessWidget {
  const _CurrencyMetrics({required this.total, required this.compact});

  final MonthTotal total;
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
          Text(AppStrings.expenses, style: AppText.caption),
          const SizedBox(height: 4),
          Text(
            formatMoney(spent),
            style: metricStyle.copyWith(
                color: mutedColor ?? AppColors.textPrimary),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(AppStrings.difference, style: AppText.caption),
        const SizedBox(height: 4),
        Text(
          '${diff >= 0 ? '+' : '−'} ${formatMoney(diff.abs())}',
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
                label: AppStrings.expenses,
                valueMajor: spent,
                style: subStyle,
                muted: isEmpty),
            const SizedBox(width: 40),
            _Sub(
                label: AppStrings.incomes,
                valueMajor: earned,
                style: subStyle,
                muted: isEmpty),
          ],
        ),
      ],
    );
  }
}

class _Sub extends StatelessWidget {
  const _Sub({
    required this.label,
    required this.valueMajor,
    required this.style,
    required this.muted,
  });

  final String label;
  final int valueMajor;
  final TextStyle style;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 2),
        Text(
          formatMoney(valueMajor),
          style: muted
              ? style.copyWith(color: AppColors.textTertiary)
              : style,
        ),
      ],
    );
  }
}
