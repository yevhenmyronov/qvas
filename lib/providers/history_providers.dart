import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/breakdown.dart';
import '../models/dates.dart';
import '../models/recap.dart';
import '../models/tx_type.dart';
import '../repositories/transaction_repository.dart';
import 'core_providers.dart';

/// Місяць, який зараз відкритий на Екрані 2.
class MonthKey {
  const MonthKey(this.year, this.month);

  final int year;
  final int month;

  factory MonthKey.now() {
    final n = DateTime.now();
    return MonthKey(n.year, n.month);
  }

  MonthKey get prev =>
      month == 1 ? MonthKey(year - 1, 12) : MonthKey(year, month - 1);

  MonthKey get next =>
      month == 12 ? MonthKey(year + 1, 1) : MonthKey(year, month + 1);

  /// Порядковий номер місяця в абсолютній шкалі — щоб можна було
  /// сказати, у який бік рухається час. Потрібне переходу на Екрані 2:
  /// напрямок слайду береться саме звідси, а не з того, яку стрілку
  /// натиснули (місяць міняє ще й тап по назві).
  int get ordinal => year * 12 + month;

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

/// Місяць Екрана 2 стежить за календарем, поки людина сама не пішла
/// в інший.
///
/// Досі це був `StateProvider` з `MonthKey.now()`, порахованим рівно
/// раз — при першому читанні в житті процесу. Застосунок такого штибу
/// не закривають, а згортають, тож процес переживав межу місяця, і
/// першого числа Екран 2 відкривався на минулому: запис потрапляв у
/// новий місяць, а показувався старий без нього (знайдено догфудингом
/// 2026-10-02).
///
/// Тому два моменти синхронізації:
/// - [showCurrent] — кожне відкриття Екрана 2 починається з поточного
///   місяця, як фільтр, який теж не переживає виходу з екрана;
/// - [sync] — повернення з фону: якщо показаний місяць був поточним, а
///   календар тим часом перегорнувся, перегортається й він. Місяць,
///   куди людина пішла стрілками, не чіпається — це її вибір, а не
///   застарілий стан.
class SelectedMonthController extends Notifier<MonthKey> {
  /// [now] — годинник; підміняється в тестах, щоб перегорнути календар.
  SelectedMonthController({MonthKey Function()? now})
      : _now = now ?? MonthKey.now;

  final MonthKey Function() _now;

  /// Поточний місяць на момент останньої синхронізації.
  late MonthKey _current = _now();

  @override
  MonthKey build() => _current = _now();

  void show(MonthKey month) => state = month;

  void showCurrent() => state = _current = _now();

  void sync() {
    final now = _now();
    if (now == _current) return;
    final followed = state == _current;
    _current = now;
    if (followed) state = now;
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthController, MonthKey>(
        SelectedMonthController.new);

/// Масштаб періоду Екрана 2 (рішення 102).
///
/// Екран 2 уже вміє все, що потрібно для загальної картини — три
/// метрики, розкладку, фільтр і стрічку. Жорстко в ньому було одне:
/// період завжди дорівнював місяцю. Масштаб розширює період, а решта
/// екрана працює без змін.
///
/// 3 і 6 місяців — календарні місяці, що закінчуються показаним
/// (поточним, бо вибір ширшого масштабу повертає до поточного): у
/// жовтні «3 місяці» — це серпень, вересень і жовтень до сьогодні.
enum HistoryScope {
  month(1),
  months3(3),
  months6(6),
  allTime(null);

  const HistoryScope(this.months);

  /// Скільки календарних місяців охоплює; null — без меж.
  final int? months;
}

/// Стан ефемерний так само, як місяць: кожне відкриття Екрана 2
/// починається з місяця (рішення 97), тож ширший масштаб — погляд на
/// хвилинку, а не новий вигляд за замовчуванням.
final historyScopeProvider =
    StateProvider<HistoryScope>((ref) => HistoryScope.month);

/// Перший і останній місяць показаного періоду; null — «за весь час».
final periodMonthsProvider =
    Provider<({MonthKey first, MonthKey last})?>((ref) {
  final months = ref.watch(historyScopeProvider).months;
  if (months == null) return null;
  final last = ref.watch(selectedMonthProvider);
  var first = last;
  for (var i = 1; i < months; i++) {
    first = first.prev;
  }
  return (first: first, last: last);
});

/// Межі показаного періоду в ключах дат — єдине, що треба знати
/// запитам стрічки, метрик і розкладки.
final periodProvider = Provider<DateKeyRange>((ref) {
  final months = ref.watch(periodMonthsProvider);
  if (months == null) return allTimePeriod;
  return (
    start: monthStartKey(months.first.year, months.first.month),
    end: monthEndKey(months.last.year, months.last.month),
  );
});

/// Стрічка показаного періоду (живі записи, найновіші зверху).
final monthFeedProvider = StreamProvider<List<Transaction>>((ref) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchPeriod(ref.watch(periodProvider));
});

/// Метрики показаного періоду.
final monthTotalsProvider = StreamProvider<MonthTotal>((ref) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchPeriodTotals(ref.watch(periodProvider));
});

/// Фільтр стрічки за категорією (Функціонал п.4.7): id категорії або null.
/// autoDispose — стан ефемерний: вихід з Екрана 2 скидає фільтр.
final categoryFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Стрічка місяця з урахуванням фільтра за категорією.
final filteredFeedProvider =
    Provider.autoDispose<List<Transaction>>((ref) {
  final feed = ref.watch(monthFeedProvider).value ?? const [];
  final filter = ref.watch(categoryFilterProvider);
  if (filter == null) return feed;
  return [
    for (final tx in feed)
      if (tx.categoryId == filter) tx,
  ];
});

/// Підсумок відфільтрованої стрічки. Валюта в застосунку одна
/// (рішення 57), тож це одне число — не список по валютах.
int filterTotalOf(Iterable<Transaction> transactions) {
  var total = 0;
  for (final tx in transactions) {
    total += tx.amountMinor;
  }
  return total;
}

/// Межі даних для блокування стрілок місяців.
final dataBoundsProvider =
    StreamProvider<({String min, String max})?>((ref) {
  return ref.watch(transactionRepositoryProvider).watchDataBounds();
});

/// Чи є в базі хоч один живий запис — розрізняє «перший запуск»
/// і «порожній місяць» (Екрани п.3.2 / п.3.3).
final hasAnyDataProvider = Provider<bool>((ref) {
  return ref.watch(dataBoundsProvider).value != null;
});

/// Дозволений діапазон місяців: місяці з даними + поточний місяць
/// (стартова точка). Стрілка за межі гасне.
final monthRangeProvider = Provider<({MonthKey first, MonthKey last})>((ref) {
  final bounds = ref.watch(dataBoundsProvider).value;
  // Залежність від показаного місяця — заради перерахунку `now`: без неї
  // межі рахувались би з календаря першого читання, і після переходу
  // місяця стрілка вперед лишалась би погашеною на новому.
  ref.watch(selectedMonthProvider);
  final now = MonthKey.now();
  if (bounds == null) return (first: now, last: now);
  final minP = parseDateKey(bounds.min);
  final maxP = parseDateKey(bounds.max);
  final dataFirst = MonthKey(minP.year, minP.month);
  final dataLast = MonthKey(maxP.year, maxP.month);
  return (
    first: _isBefore(dataFirst, now) ? dataFirst : now,
    last: _isBefore(now, dataLast) ? dataLast : now,
  );
});

bool _isBefore(MonthKey a, MonthKey b) =>
    a.year < b.year || (a.year == b.year && a.month < b.month);

/// Банер «давно не було резервної копії» (Функціонал п.7.3): понад 60 днів
/// без бекапу і більше 100 записів. Закривається назавжди одним тапом.
final backupReminderProvider = FutureProvider<bool>((ref) async {
  final s = ref.watch(settingsProvider).value;
  if (s == null || s.backupBannerDismissed) return false;
  final last = s.lastBackupAt;
  final stale = last == null ||
      DateTime.now().toUtc().difference(last) > const Duration(days: 60);
  if (!stale) return false;
  final count =
      await ref.watch(transactionRepositoryProvider).liveCount();
  return count > 100;
});

/// Підсумок будь-якого місяця. Викликається з `.prev` показаного —
/// порожній місяць розповідає про той, що перед ним.
final monthRecapProvider =
    StreamProvider.family<MonthRecap, MonthKey>((ref, m) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthRecap(m.year, m.month);
});

/// Розкладка показаного періоду за категоріями, від найбільшої суми.
///
/// Період береться з [periodProvider], тобто шторка розкладки
/// успадковує навігацію Екрана 2 і власного перемикача не потребує.
final categoryBreakdownProvider =
    StreamProvider.family<List<CategoryTotal>, TxType>((ref, type) {
  return ref
      .watch(transactionRepositoryProvider)
      .watchCategoryBreakdown(ref.watch(periodProvider), type)
      .map(rankedTotals);
});
