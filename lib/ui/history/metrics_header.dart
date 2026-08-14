import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/format.dart';
import '../../models/money.dart';
import '../../providers/history_providers.dart';
import '../../theme/tokens.dart';

/// Три метрики за один погляд (Функціонал п.4.2): «Різниця» домінантна,
/// «Витрати» й «Доходи» другорядні. Голі цифри без карток (рішення 24) —
/// ієрархія тримається кеглем і кольором.
class MetricsHeader extends ConsumerWidget {
  const MetricsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(monthTotalsProvider).value ?? const [];
    final today = ref.watch(todayExpenseProvider).value ?? 0;

    // v0.1 — одна валюта (UAH захардкожена). Кілька валют — Фаза 3 (п.3.8).
    final t = totals.isEmpty
        ? (currencyCode: kCurrencyCode, spentMinor: 0, earnedMinor: 0)
        : totals.first;

    final spent = t.spentMinor.toMajor;
    final earned = t.earnedMinor.toMajor;
    final diff = earned - spent;

    return Column(
      children: [
        Text(AppStrings.difference, style: AppText.caption),
        const SizedBox(height: 4),
        Text(
          '${diff >= 0 ? '+' : '−'} ${formatMoney(diff.abs())}',
          style: AppText.metric.copyWith(
            // Синій якщо +, білий якщо − (Екрани п.3.1).
            color: diff >= 0 ? AppColors.income : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SubMetric(label: AppStrings.expenses, valueMajor: spent),
            const SizedBox(width: 40),
            _SubMetric(label: AppStrings.incomes, valueMajor: earned),
          ],
        ),
        const SizedBox(height: 12),
        Text(AppStrings.todayTotal(formatMoney(today.toMajor)),
            style: AppText.caption),
      ],
    );
  }
}

class _SubMetric extends StatelessWidget {
  const _SubMetric({required this.label, required this.valueMajor});

  final String label;
  final int valueMajor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 2),
        Text(formatMoney(valueMajor), style: AppText.metricSub),
      ],
    );
  }
}
