import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../providers/history_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';
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

/// Екран 2 — Історія (Функціонал п.4): шапка місяця, три метрики, стрічка.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyData = ref.watch(hasAnyDataProvider);

    return Scaffold(
      body: SafeArea(
        child: hasAnyData
            ? const _HistoryBody()
            : _FirstLaunchEmpty(onStart: () => Navigator.of(context).pop()),
      ),
    );
  }
}

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(monthFeedProvider).value ?? const [];

    return Column(
      children: [
        const SizedBox(height: 8),
        const _MonthNav(),
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
                  child:
                      Text(AppStrings.emptyMonth, style: AppText.caption),
                )
              : Feed(transactions: feed),
        ),
      ],
    );
  }
}

/// Навігація по місяцях (Функціонал п.4.1): стрілки перемикають місяць,
/// вихід за межі наявних даних заблокований (стрілка гасне й не реагує),
/// тап по назві повертає до поточного.
class _MonthNav extends ConsumerWidget {
  const _MonthNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final range = ref.watch(monthRangeProvider);
    final canPrev = month != range.first;
    final canNext = month != range.last;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Arrow(
          icon: Icons.chevron_left,
          enabled: canPrev,
          onTap: () => ref
              .read(selectedMonthProvider.notifier)
              .state = month.prev,
        ),
        GestureDetector(
          onTap: () => ref.read(selectedMonthProvider.notifier).state =
              MonthKey.now(),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 180,
            child: Center(
              child: Text(
                AppStrings.monthTitle(month.year, month.month),
                style: AppText.bodyStrong,
              ),
            ),
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right,
          enabled: canNext,
          onTap: () => ref
              .read(selectedMonthProvider.notifier)
              .state = month.next,
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      enabled: enabled,
      onTap: onTap,
      builder: (context, pressed) => SizedBox(
        width: AppSize.minTouch,
        height: AppSize.minTouch,
        child: Icon(
          icon,
          size: 24,
          color:
              enabled ? AppColors.textSecondary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Перший запуск, нуль даних (Екрани п.3.2): метрик немає взагалі —
/// порожній стан із кнопкою, що веде на Екран 1.
class _FirstLaunchEmpty extends StatelessWidget {
  const _FirstLaunchEmpty({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppStrings.emptyTitle, style: AppText.bodyStrong),
          const SizedBox(height: 8),
          Text(AppStrings.emptySubtitle, style: AppText.caption),
          const SizedBox(height: AppSpace.block),
          Pressable(
            onTap: onStart,
            builder: (context, pressed) => Container(
              height: AppSize.saveButton,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: pressed
                    ? AppColors.accentPressed
                    : AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              alignment: Alignment.center,
              child: Text(
                AppStrings.emptyAction,
                style: AppText.bodyStrong
                    .copyWith(color: AppColors.onAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
