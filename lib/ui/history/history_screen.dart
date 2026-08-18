import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/hints.dart';
import '../../models/money.dart';
import '../../models/recap.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/edge_light.dart';
import '../../theme/tokens.dart';
import '../common/app_button.dart';
import '../common/app_icon_button.dart';
import '../common/sheet_scaled.dart';
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
      body: SheetScaled(
        child: SafeArea(
          child: hasAnyData
              ? const _HistoryBody()
              : _FirstLaunchEmpty(onStart: () => Navigator.of(context).pop()),
        ),
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
  late final AnimationController _slide = AnimationController(
    vsync: this,
    value: 1,
  );
  int _direction = 1;

  /// Підказка цього візиту (рішення 89). Обирається один раз при вході
  /// й більше не переобирається: інакше вона могла б змінитись або
  /// зникнути прямо під поглядом, щойно оновиться будь-який провайдер.
  AppHint? _hint;
  bool _hintResolved = false;
  bool _hintHidden = false;
  Timer? _hintTimer;

  /// Скільки підказка мусить прожити на екрані, щоб рахуватись
  /// показаною.
  ///
  /// **Без цієї витримки підказки згорали не побачені.** Під час
  /// швидкого внесення записів Екран 2 приїжджає після кожного
  /// збереження й одразу закривається — за один вечір так згоріли всі
  /// три, а користувач бачив рівно одну. Позначати за факт побудови
  /// кадру означало позначати за те, що екран промайнув.
  static const _hintDwell = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    // Підказка зникає від скролу — тобто від першої ж дії, яка означає
    // «я вже дивлюсь на свої записи, дякую».
    _scroll.addListener(() {
      if (!_hintHidden && _hint != null && _scroll.offset > 8) {
        setState(() => _hintHidden = true);
      }
    });
  }

  @override
  void dispose() {
    // Не встигла відлежати свої секунди — не рахується показаною й
    // прийде наступного разу.
    _hintTimer?.cancel();
    _slide.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Обирає підказку й заводить годинник, який її «спалить».
  void _resolveHint(List<Transaction> feed) {
    if (_hintResolved || feed.isEmpty) return;
    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;

    _hintResolved = true;
    _hint = pendingHint(
      shownMask: settings.hintsShown,
      monthRecords: feed.length,
      topCategoryRecords: topCategoryCount(feed.map((t) => t.categoryId)),
    );
    final hint = _hint;
    if (hint == null) return;

    _hintTimer = Timer(_hintDwell, () {
      ref.read(settingsRepositoryProvider).markHintShown(hint);
    });
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
    final filtered = ref.watch(categoryFilterProvider) != null;
    // Під фільтром підказок немає: людина вже прийшла з питанням, і
    // репліка про інші жести була б перебиванням.
    if (!filtered) _resolveHint(feed);
    final hint = filtered || _hintHidden ? null : _hint;

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
                    // Під фільтром порожнеча означає інше — «у цієї
                    // категорії тут нічого», — і підсумок місяця там був
                    // би відповіддю не на те питання.
                    child: ref.watch(categoryFilterProvider) == null
                        ? const _EmptyMonth()
                        : Text(
                            context.l10n.emptyMonth,
                            style: AppText.caption,
                          ),
                  ),
                )
              : Column(
                  children: [
                    if (hint != null) _HintLine(hint: hint),
                    Expanded(
                      child: Feed(
                        transactions: feed,
                        // Відступ НЕ зменшується під підказку: саме він
                        // тримає перший рядок поза зоною ефекту
                        // зникнення, а запас там 4dp (рішення 52).
                        // Прибереш — і верхній рядок стоїть
                        // напіврозмитим у спокої.
                        topPadding: AppSpace.block,
                        controller: _scroll,
                      ),
                    ),
                  ],
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
                child: AppIconButton(
                  icon: Icons.settings_outlined,
                  iconSize: 20,
                  semanticLabel: context.l10n.settingsTitle,
                  onTap: () => Navigator.of(context).push(settingsRoute()),
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
        AppIconButton(
          icon: Icons.chevron_left,
          semanticLabel: context.l10n.a11yPrevMonth,
          enabled: canPrev,
          color: canPrev ? AppColors.textSecondary : AppColors.textTertiary,
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
        AppIconButton(
          icon: Icons.chevron_right,
          semanticLabel: context.l10n.a11yNextMonth,
          enabled: canNext,
          color: canNext ? AppColors.textSecondary : AppColors.textTertiary,
          onTap: () =>
              ref.read(selectedMonthProvider.notifier).state = month.next,
        ),
      ],
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
          AppIconButton(
            icon: Icons.close,
            // Менша за 48: ✕ стоїть усередині рядка тексту, і повна
            // ціль дотику розсунула б рядок на півсантиметра.
            size: 30,
            iconSize: 14,
            color: AppColors.textTertiary,
            semanticLabel:
                MaterialLocalizations.of(context).closeButtonTooltip,
            onTap: () =>
                ref.read(settingsRepositoryProvider).dismissBackupBanner(),
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

/// Порожній місяць: підсумок того, що щойно закрився (рішення 88).
///
/// Це місце було мертвим рядком «У цьому місяці записів немає» саме
/// тоді, коли людина вперше відкриває застосунок у новому місяці —
/// тобто в єдиний природний ритуал, який у продукті взагалі є. Тепер
/// воно розповідає про попередній місяць.
///
/// Якщо попереднього місяця теж немає (перший місяць вжитку, або
/// гортання далеко в минуле) — лишається звичайний текст. Порожнеча
/// краща за «Записів: 0».
class _EmptyMonth extends ConsumerWidget {
  const _EmptyMonth();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final month = ref.watch(selectedMonthProvider);
    final recap =
        ref.watch(monthRecapProvider(month.prev)).value ?? emptyRecap;

    if (recap.count == 0) {
      return Text(l.emptyMonth, style: AppText.caption);
    }

    final categories = ref.watch(categoriesByIdProvider).value ?? const {};
    final top = categories[recap.topCategoryId];
    final format = ref.watch(moneyFormatProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.recapClosed(monthTitle(
            ref.watch(localeTagProvider),
            month.prev.year,
            month.prev.month,
          )),
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        Text(
          format.full(recap.spentMinor.toMajor),
          style: AppText.metricSub,
        ),
        const SizedBox(height: 8),
        Text(l.recapRecords(recap.count), style: AppText.caption),
        if (top != null) ...[
          const SizedBox(height: 2),
          Text(
            l.recapTop('${top.emoji} ${categoryDisplayName(l, top)}'),
            style: AppText.caption,
          ),
        ],
      ],
    );
  }
}

/// Підказка в момент, коли вона стає доречною (рішення 89).
///
/// Один рядок тексту над стрічкою — не модалка, не тост, не оверлей.
/// Нічого не блокує, нічого не потребує натиснути, зникає від скролу й
/// більше не повертається ніколи.
///
/// Свідомо без підкладки, іконки й кнопки «Зрозуміло»: щойно підказка
/// отримує рамку, вона стає елементом інтерфейсу, а не реплікою.
class _HintLine extends StatelessWidget {
  const _HintLine({required this.hint});

  final AppHint hint;

  String _text(BuildContext context) => switch (hint) {
        AppHint.rowActions => context.l10n.hintRowActions,
        AppHint.breakdown => context.l10n.hintBreakdown,
        AppHint.categoryFilter => context.l10n.hintCategoryFilter,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.side,
        AppSpace.block,
        AppSpace.side,
        AppSpace.block,
      ),
      child: Text(
        _text(context),
        style: AppText.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
