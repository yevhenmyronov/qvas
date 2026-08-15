import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../models/dates.dart';
import '../../models/money.dart';
import '../../models/tx_type.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/input_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../sheets/quick_edit_sheet.dart';

/// Стрічка (Функціонал п.4.3): групування за днями, найновіші зверху.
/// Часу немає ніде (рішення 29). Другий рівень рядка — тільки коментар.
class Feed extends ConsumerWidget {
  const Feed({
    super.key,
    required this.transactions,
    this.topPadding = 0,
    this.controller,
  });

  final List<Transaction> transactions;

  /// Зовнішній контролер: панель підсумків слухає offset, щоб згортати
  /// метрики (рішення 38).
  final ScrollController? controller;

  /// Місце під панель підсумків, за якою скролиться стрічка (рішення 37):
  /// список лежить у Stack на всю висоту, тож перший рядок мусить
  /// стартувати нижче панелі.
  final double topPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesByIdProvider).value ?? const {};
    final mainFormat = ref.watch(moneyFormatProvider);

    final todayKey = localDateKeyOf(DateTime.now());
    final yesterdayKey = localDateKeyOf(
        DateTime.now().subtract(const Duration(days: 1)));

    // Групування за localDateKey — порядок уже правильний із запиту.
    final groups = <_DayGroup>[];
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
      groups.add(_DayGroup(
        title: title,
        totalText: dayExpense > 0
            ? mainFormat.full(dayExpense.toMajor)
            : null,
        transactions: List.of(dayBuffer),
      ));
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

    // Рішення 43: заголовок дня закріплюється під панеллю (sticky),
    // поки скролиться його день, і виштовхується наступним днем.
    // Дата й сума лишаються читабельними — ефект зникнення чіпає
    // тільки рядки транзакцій.
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topPadding)),
        for (final g in groups)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _DayHeaderDelegate(
                  title: g.title,
                  totalText: g.totalText,
                  controller: controller,
                ),
              ),
              SliverList.list(
                children: [
                  for (final tx in g.transactions)
                    // Ключ обов'язковий: без нього Flutter
                    // перевикористовує стан рядка на тій самій позиції,
                    // і підсвічування нового запису (п.4.6) ніколи не
                    // запускається. Живе на обгортці — вона і є
                    // елементом списку.
                    _edgeWrap(
                      TransactionTile(
                          tx: tx, category: categories[tx.categoryId]),
                      key: ValueKey(tx.id),
                    ),
                ],
              ),
            ],
          ),
        const SliverToBoxAdapter(
            child: SizedBox(height: AppSpace.block)),
      ],
    );
  }

  /// Обгортає елемент стрічки ефектом зникнення (рішення 41), якщо є
  /// контролер, за яким можна стежити.
  Widget _edgeWrap(Widget child, {Key? key}) {
    final c = controller;
    if (c == null) return KeyedSubtree(key: key, child: child);
    return _EdgeVanish(key: key, controller: c, child: child);
  }
}

/// Ефект зникнення біля панелі (рішення 41): що ближче центр рядка до
/// верхнього краю вьюпорта (= нижньої грані панелі), то менший,
/// прозоріший і розмитіший рядок; на краю він гасне повністю. Блюр —
/// частина ефекту рядка, а не смуга над списком (рішення 42): у
/// BackdropFilter-смуги завжди жорстка просторова межа, а сигма, що
/// росте разом зі стисканням, розмиває рядок цілком і меж не має.
/// Прив'язка пряма до позиції при скролі, не таймінгова анімація —
/// «Прибрати анімації» не впливає.
class _EdgeVanish extends StatelessWidget {
  const _EdgeVanish({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  /// Зона дії: відстань центру рядка від нижнього краю закріпленого
  /// заголовка дня, з якої починається стискання. Повне зникнення —
  /// коли центр рядка сягає низу заголовка (рішення 43). Перший рядок
  /// дня у спокої має бути ПОЗА зоною, інакше він тьмяний без скролу.
  static const _zone = 56.0;

  /// Початок відліку — низ закріпленого заголовка, не край вьюпорта.
  static const _edge = _DayHeaderDelegate.extent;

  static double _computeT(BuildContext context) {
    var t = 1.0;
    // try — обов'язковий: коли новий запис приїжджає в стрічку ПІД
    // ЧАС переходу з Екрана 1 (збереження), layoutOffset рядка ще
    // не виставлений і localToGlobal кидає. Без перехоплення
    // виняток обриває build решти рядків, і замість них лишається
    // сірий шар GPU-сміття до першого скролу (баг зі скріншота
    // 2026-08-15). Фолбек — рядок повністю видимий, наступний кадр
    // перераховує чесно.
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.attached && box.hasSize) {
        final viewport = Scrollable.of(context).context.findRenderObject();
        if (viewport is RenderBox && viewport.attached) {
          final center = box
              .localToGlobal(Offset(0, box.size.height / 2),
                  ancestor: viewport)
              .dy;
          t = ((center - _edge) / _zone).clamp(0.0, 1.0);
        }
      }
    } catch (_) {
      t = 1.0;
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return _VanishOnScroll(
      controller: controller,
      computeT: _computeT,
      child: child,
    );
  }
}

/// Спільний механізм «геометрія минулого кадру + доганяння в спокої».
///
/// t рахується з геометрії минулого кадру — під час скролу відставання
/// на кадр око не розрізняє. Але коли скрол зупиняється, останнє
/// обчислення застигає на передостанньому кадрі: рядок уже доїхав на
/// місце, а ефект — ні, і верхній рядок висів напіврозмитим до
/// наступного дотику (баг «блюр у спокої», 2026-08-15). Тому поки
/// значення змінюється, плануємо ще один перерахунок після наступного
/// кадру; щойно стабілізувалось — зупиняємось. Сходиться за 1–2 кадри
/// після зупинки, під час скролу додаткових перерахунків майже немає
/// (поза зоною t стабільно 1).
class _VanishOnScroll extends StatefulWidget {
  const _VanishOnScroll({
    required this.controller,
    required this.computeT,
    this.blur = true,
    required this.child,
  });

  final ScrollController controller;
  final double Function(BuildContext context) computeT;
  final bool blur;
  final Widget child;

  @override
  State<_VanishOnScroll> createState() => _VanishOnScrollState();
}

class _VanishOnScrollState extends State<_VanishOnScroll> {
  double _lastT = 1.0;
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final t = widget.computeT(context);
        if (t != _lastT && !_scheduled) {
          _scheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scheduled = false;
            if (mounted) setState(() {});
          });
        }
        _lastT = t;
        return _vanish(t, child!, blur: widget.blur);
      },
      child: widget.child,
    );
  }
}

/// Спільна візуальна частина ефекту зникнення (рішення 41–44):
/// прозорість, стискання і (для рядків) блюр керуються одним t
/// (1 — недоторканий, 0 — зник повністю).
///
/// Прозорість гасне квадратично (t²): з лінійною кривою сильно розмитий
/// рядок довго висів напівпрозорою сірою плямою — «брудний хвіст».
/// Квадрат прибирає хвіст, не чіпаючи м'який початок переходу.
Widget _vanish(double t, Widget child, {bool blur = true}) {
  if (t >= 1) return child;
  const minScale = 0.85;
  const maxSigma = 6.0;
  final sigma = blur ? (1 - t) * maxSigma : 0.0;
  return Opacity(
    opacity: t * t,
    child: Transform.scale(
      scale: minScale + (1 - minScale) * t,
      child: sigma < 0.1
          ? child
          : ImageFiltered(
              imageFilter:
                  ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
    ),
  );
}

class _DayGroup {
  const _DayGroup({
    required this.title,
    required this.totalText,
    required this.transactions,
  });

  final String title;
  final String? totalText;
  final List<Transaction> transactions;
}

/// Закріплений заголовок дня (рішення 43). Суцільний фон обов'язковий:
/// рядки проїжджають ЗА заголовком, поки тануть під ним.
///
/// Рішення 44: коли наступний день виштовхує заголовок, він не ріжеться
/// об панель, а зникає тим самим ефектом, що й рядки (scale +
/// прозорість + блюр за від'ємною позицією відносно вьюпорта).
class _DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _DayHeaderDelegate({
    required this.title,
    required this.totalText,
    required this.controller,
  });

  final String title;
  final String? totalText;
  final ScrollController? controller;

  /// Фіксована висота: side (20) зверху + рядок капшену (~18) + 8 знизу.
  static const extent = 46.0;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    // Фон не обривається прямокутником (це давало грубу лінію там, де
    // рядок ховається під заголовок), а розчиняється донизу градієнтом.
    final content = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgBase,
            AppColors.bgBase,
            Color(0x000D0D0D),
          ],
          stops: [0, 0.7, 1],
        ),
      ),
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
    final c = controller;
    if (c == null) return content;

    return _VanishOnScroll(
      controller: c,
      blur: false,
      computeT: _computeT,
      child: content,
    );
  }

  /// Зникаємо НА ВИПЕРЕДЖЕННЯ: виштовхування ріже заголовок об
  /// край вьюпорта з першого ж пікселя, тож гасити його навздогін
  /// пізно — завжди видно розрізаний текст. Натомість дивимось,
  /// скільки контенту дня лишилось під заголовком (scrollExtent −
  /// scrollOffset групи), і розчиняємось за останні _lead пікселів
  /// — до початку зрізу заголовка вже немає. Геометрія минулого
  /// кадру з доганянням у спокої — через _VanishOnScroll.
  /// try — з тієї ж причини, що в _EdgeVanish: у кадр оновлення
  /// стрічки геометрія може бути ще не готова.
  static double _computeT(BuildContext context) {
    var t = 1.0;
    try {
      final box = context.findRenderObject();
      if (box != null && box.attached) {
        RenderObject? node = box.parent;
        while (node != null && node is! RenderSliverMainAxisGroup) {
          if (node is RenderViewportBase) break;
          node = node.parent;
        }
        if (node is RenderSliverMainAxisGroup && node.geometry != null) {
          final remaining =
              node.geometry!.scrollExtent - node.constraints.scrollOffset;
          t = ((remaining - extent) / _lead).clamp(0.0, 1.0);
        }
      }
    } catch (_) {
      t = 1.0;
    }
    return t;
  }

  /// За скільки пікселів залишку дня заголовок розчиняється повністю.
  static const _lead = 56.0;

  @override
  bool shouldRebuild(covariant _DayHeaderDelegate oldDelegate) =>
      oldDelegate.title != title ||
      oldDelegate.totalText != totalText ||
      oldDelegate.controller != controller;
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
    // Спалах стартує ПІСЛЯ приїзду Екрана 2: рядок народжується ще під
    // час переходу, і без затримки більша частина 600 мс згорала за
    // кадром — наживо спалаху не було видно.
    Future.delayed(AppDurations.sheet, () {
      if (mounted) setState(() => _highlight = true);
    });
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
          // Тап по кружечку — фільтр стрічки за цією категорією
          // (Функціонал п.4.7); повторний тап знімає. Внутрішній
          // розпізнавач виграє арену в тапу рядка (редагування).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final filter = ref.read(categoryFilterProvider.notifier);
              filter.state =
                  filter.state == tx.categoryId ? null : tx.categoryId;
            },
            child: Semantics(
              label: context.l10n.a11yFilterByCategory,
              button: true,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.bgSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(c?.emoji ?? '',
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
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
        // Яскравіше за --accent-subtle: 12% на графітовому фоні наживо
        // читались як «нічого не сталося».
        color: Color.lerp(
          Colors.transparent,
          (widget.tx.type == TxType.income
                  ? AppColors.income
                  : AppColors.accent)
              .withValues(alpha: 0.26),
          t,
        )!,
        child: child,
      ),
      child: interactive,
    );
  }
}
