import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../providers/core_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';
import '../common/app_button.dart';
import '../common/pressable.dart';
import '../settings/settings_screen.dart';
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

class _HistoryBody extends ConsumerStatefulWidget {
  const _HistoryBody();

  @override
  ConsumerState<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends ConsumerState<_HistoryBody>
    with SingleTickerProviderStateMixin {
  /// Висота РОЗГОРНУТОЇ панелі підсумків. Стартова оцінка до першого
  /// заміру — уточнюється post-frame через [_MeasureSize] (панель
  /// динамічна: кілька валют, банер бекапу).
  double _panelHeight = 300;

  final _scroll = ScrollController();

  /// Перехід між місяцями (рішення 63): вміст заїжджає збоку в той бік,
  /// куди рухається час. Раніше місяць мінявся жорстким зрізом — це
  /// була єдина навігація в застосунку взагалі без руху.
  late final AnimationController _slide =
      AnimationController(vsync: this, value: 1);
  int _direction = 1;

  @override
  void dispose() {
    _slide.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onMonthChanged(MonthKey? before, MonthKey after) {
    if (before != null) {
      _direction = after.ordinal >= before.ordinal ? 1 : -1;
    }
    if (_scroll.hasClients) _scroll.jumpTo(0);
    // Заїзд, без виїзду: старий місяць не показується, бо його вміст
    // уже замінений. Перезапуск із нуля коректно обробляє швидкі
    // повторні тапи по стрілці — черги немає, просто новий заїзд.
    _slide.value = 0;
    _slide.animateTo(
      1,
      duration: AppDurations.of(context, AppDurations.standard),
      curve: AppCurves.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(filteredFeedProvider);

    // Інший місяць — скрол з нуля: місяць перемикають, щоб побачити
    // підсумки, а не середину стрічки. Зміна фільтра — з тієї ж причини.
    ref.listen(selectedMonthProvider, _onMonthChanged);
    ref.listen(categoryFilterProvider, (_, _) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });

    // Рішення 39: вьюпорт стрічки починається від НИЖНЬОЇ грані панелі —
    // рядки зникають рівно під нею, а не пливуть за панеллю до верху
    // екрана. Панель статична й непрозора.
    final content = Stack(
      children: [
        Positioned(
          top: _panelHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: feed.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpace.block),
                  child: Center(
                    child: Text(
                      context.l10n.emptyMonth,
                      style: AppText.caption,
                    ),
                  ),
                )
              : Feed(
                  transactions: feed,
                  topPadding: AppSpace.block,
                  controller: _scroll,
                ),
        ),
        // Смуг BackdropFilter тут більше немає (рішення 42): у них
        // завжди жорстка просторова межа. Блюр — частина ефекту
        // зникнення самого рядка у стрічці ([_EdgeVanish] у feed.dart).
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _MeasureSize(
            onChange: (size) {
              if (size.height != _panelHeight) {
                setState(() => _panelHeight = size.height);
              }
            },
            child: const _SummaryPanel(),
          ),
        ),
      ],
    );

    // Трансформується ВЕСЬ Stack, а не окремі частини, і це навмисно.
    // Transform лише малює: [_MeasureSize] бачить ті самі констрейнти,
    // тож `_panelHeight` не стрибає; а ефект зникнення рядків рахує
    // геометрію ВІДНОСНО предка-вьюпорта, тож зсув скорочується з обох
    // боків і нічого не ламає.
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: _slide,
      child: content,
      builder: (context, child) {
        if (_slide.value >= 1) return child!;
        return Opacity(
          opacity: _slide.value,
          child: Transform.translate(
            offset: Offset(_direction * width * 0.12 * (1 - _slide.value), 0),
            child: child,
          ),
        );
      },
    );
  }
}

/// Панель підсумків (рішення 37): суцільна плашка на глибокому чорному
/// фоні — шари розділяються яскравістю, а не лініями.
///
/// Рішення 39: панель статична і непрозора, стрічка зникає під її
/// нижньою гранню (вьюпорт стартує там). Згортання метрик і frosted
/// glass із рішення 38 скасовані: за панеллю ніщо не рухається, тож
/// і розмивати нічого.
class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      // Велика площа тримає рівень краєм, а не яскравістю заливки: саме
      // тому панель лишається тьмянішою за шторки й водночас читається
      // як шар над стрічкою.
      foregroundDecoration: EdgeLight.decoration(
        BorderRadius.circular(AppRadius.card),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          // Вхід у налаштування живе тут: на Екрані 1 немає жодної
          // кнопки, крім головної дії (Екрани п.1.1).
          Stack(
            alignment: Alignment.center,
            children: [
              const _MonthNav(),
              Positioned(
                right: 8,
                child: Pressable(
                  onTap: () => Navigator.of(context).push(settingsRoute()),
                  builder: (context, pressed) => const SizedBox(
                    width: AppSize.minTouch,
                    height: AppSize.minTouch,
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.block),
          const MetricsHeader(),
          const _BackupBanner(),
        ],
      ),
    );
  }
}

/// Повідомляє розмір дитини після layout. Потрібен, бо висота панелі
/// динамічна, а відступ стрічки в Stack мусить їй дорівнювати.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize == null || newSize == _reported) return;
    _reported = newSize;
    // setState не можна викликати під час layout — переносимо на
    // наступний кадр.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
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
          onTap: () =>
              ref.read(selectedMonthProvider.notifier).state = month.prev,
        ),
        GestureDetector(
          onTap: () =>
              ref.read(selectedMonthProvider.notifier).state = MonthKey.now(),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 180,
            child: Center(
              child: Text(
                monthTitle(
                  ref.watch(localeTagProvider),
                  month.year,
                  month.month,
                ),
                style: AppText.bodyStrong,
              ),
            ),
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right,
          label: context.l10n.a11yNextMonth,
          enabled: canNext,
          onTap: () =>
              ref.read(selectedMonthProvider.notifier).state = month.next,
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
            color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
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
            onTap: () =>
                ref.read(settingsRepositoryProvider).dismissBackupBanner(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, size: 14, color: AppColors.textTertiary),
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
          AppButton(
            label: context.l10n.emptyAction,
            onTap: onStart,
            expand: false,
          ),
        ],
      ),
    );
  }
}
