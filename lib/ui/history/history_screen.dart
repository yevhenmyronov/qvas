import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../providers/history_providers.dart';
import '../../theme/tokens.dart';
import 'feed.dart';
import 'metrics_header.dart';

/// Перехід Екран 1 → Екран 2: наїжджає знизу, підхоплюючи рух суми
/// (DS п.5.5). Зворотний шлях дзеркальний — його дає той самий route.
Route<void> historyRoute() {
  return PageRouteBuilder<void>(
    transitionDuration: AppDurations.sheet,
    reverseTransitionDuration: AppDurations.sheet,
    pageBuilder: (_, _, _) => const HistoryScreen(),
    transitionsBuilder: (_, animation, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: AppCurves.standard)).animate(animation);
      return SlideTransition(position: slide, child: child);
    },
  );
}

/// Екран 2 — Історія (Функціонал п.4). Легкий інформаційний хаб:
/// шапка місяця, три метрики, стрічка.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final feed = ref.watch(monthFeedProvider).value ?? const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Фаза 3 додасть стрілки навігації по місяцях і блокування меж.
            Text(
              AppStrings.monthTitle(month.year, month.month),
              style: AppText.bodyStrong,
            ),
            const SizedBox(height: AppSpace.block),
            const MetricsHeader(),
            const SizedBox(height: AppSpace.block),
            // Єдина лінія на екрані — межа між підсумком і списком
            // (Екрани п.3.1).
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderHairline,
            ),
            Expanded(
              child: feed.isEmpty
                  ? Center(
                      child: Text(AppStrings.emptyMonth,
                          style: AppText.caption),
                    )
                  : Feed(transactions: feed),
            ),
          ],
        ),
      ),
    );
  }
}
