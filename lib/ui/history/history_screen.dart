import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../providers/core_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';
import 'feed.dart';
import 'metrics_header.dart';

/// Перехід Екран 1 → Екран 2: наїжджає знизу, підхоплюючи рух суми
/// (DS п.5.5). Зворотний шлях дзеркальний — його дає той самий route.
Route<void> historyRoute(BuildContext context) {
  final d = AppDurations.of(context, AppDurations.sheet);
  return PageRouteBuilder<void>(
    transitionDuration: d,
    reverseTransitionDuration: d,
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
        const _BackupBanner(),
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
                  child: Text(context.l10n.emptyMonth,
                      style: AppText.caption),
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
          label: context.l10n.a11yPrevMonth,
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
                monthTitle(ref.watch(localeTagProvider), month.year,
                    month.month),
                style: AppText.bodyStrong,
              ),
            ),
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right,
          label: context.l10n.a11yNextMonth,
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
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      enabled: enabled,
      onTap: onTap,
      builder: (context, pressed) => Semantics(
        label: label,
        button: true,
        enabled: enabled,
        child: SizedBox(
          width: AppSize.minTouch,
          height: AppSize.minTouch,
          child: Icon(
            icon,
            size: 24,
            color:
                enabled ? AppColors.textSecondary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// Банер нагадування про резервну копію (Екрани п.0.3): один рядок
/// тексту + ✕, без фону й рамки. Закривається назавжди одним тапом.
class _BackupBanner extends ConsumerWidget {
  const _BackupBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(backupReminderProvider).value ?? false;
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.backupReminder, style: AppText.caption),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => ref
                .read(settingsRepositoryProvider)
                .dismissBackupBanner(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close,
                  size: 14, color: AppColors.textTertiary),
            ),
          ),
        ],
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
          Text(context.l10n.emptyTitle, style: AppText.bodyStrong),
          const SizedBox(height: 8),
          Text(context.l10n.emptySubtitle, style: AppText.caption),
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
                context.l10n.emptyAction,
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
