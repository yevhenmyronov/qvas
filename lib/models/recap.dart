/// Підсумок закритого місяця — те, що застосунок каже першого числа.
///
/// Порожній місяць досі показував мертвий рядок «У цьому місяці записів
/// немає» саме в той момент, коли людина відкриває застосунок уперше в
/// новому місяці. Тепер там стоїть один факт про місяць, який щойно
/// скінчився.
///
/// **Це підсумок ОДНОГО місяця, не порівняння двох.** Щойно тут
/// з'явиться «на 12% більше, ніж у липні» — перейдено межу, яку
/// [[Scope]] тримає навмисно.
library;

typedef CategoryCount = ({String categoryId, int totalMinor, int count});

typedef MonthRecap = ({int count, int spentMinor, String? topCategoryId});

const MonthRecap emptyRecap = (count: 0, spentMinor: 0, topCategoryId: null);

/// Згортає суми за категоріями в один підсумок місяця.
///
/// Найбільша категорія при рівних сумах вибирається за `categoryId` —
/// з тієї ж причини, що й порядок у розкладці: інакше вона стрибала б
/// між перемальовками залежно від порядку рядків із бази.
MonthRecap recapOf(List<CategoryCount> rows) {
  if (rows.isEmpty) return emptyRecap;

  var count = 0;
  var spent = 0;
  String? topId;
  var topMinor = -1;

  for (final r in rows) {
    count += r.count;
    spent += r.totalMinor;
    final better = r.totalMinor > topMinor ||
        (r.totalMinor == topMinor && r.categoryId.compareTo(topId!) < 0);
    if (better) {
      topMinor = r.totalMinor;
      topId = r.categoryId;
    }
  }

  return (count: count, spentMinor: spent, topCategoryId: topId);
}
