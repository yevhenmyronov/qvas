/// Smart Categories — чистий алгоритм ранжування (Функціонал п.2.4).
///
/// Головна вимога — не точність, а СТАБІЛЬНІСТЬ: позиції не стрибають,
/// бо «2 кліки» береться з м'язової пам'яті. Тому гістерезис: категорія,
/// що вже займає слот, витісняється тільки помітно сильнішим претендентом.
library;

/// Ранг категорії за останні 30 днів.
typedef CategoryRank = ({String categoryId, int rank, DateTime? lastUsed});

const int kSlotCount = 5;

/// Обчислює склад п'яти слотів головного екрана.
///
/// [ranks] — кількість транзакцій за 30 днів по категоріях (відсутні = 0).
/// [pinnedIds] — закріплені вручну, вже впорядковані за sortOrder.
/// [previousSlots] — попередній кешований склад НЕзакріплених слотів
///   (порядок = позиції). Порожній — кешу ще не було.
/// [activeIds] — всі неархівовані категорії типу, впорядковані за
///   sortOrder (для детермінованого заповнення при нульовій історії).
///
/// Повертає повний список категорій для слотів: закріплені першими,
/// далі ранжовані. Розмір ≤ [kSlotCount].
List<String> computeSmartSlots({
  required List<CategoryRank> ranks,
  required List<String> pinnedIds,
  required List<String> previousSlots,
  required List<String> activeIds,
}) {
  final active = activeIds.toSet();

  // 3. Закріплені першими, максимум 5. Алгоритм їх не рухає.
  final pinned = [
    for (final id in pinnedIds)
      if (active.contains(id)) id,
  ].take(kSlotCount).toList();
  final pinnedSet = pinned.toSet();

  final rankedSlotCount = kSlotCount - pinned.length;
  if (rankedSlotCount <= 0) return pinned;

  final rankById = {for (final r in ranks) r.categoryId: r};
  int rankOf(String id) => rankById[id]?.rank ?? 0;
  DateTime? lastUsedOf(String id) => rankById[id]?.lastUsed;

  final sortIndex = {for (final (i, id) in activeIds.indexed) id: i};

  // Кандидати за спаданням rank; тай-брейк — пізніша дата останнього
  // використання, далі — порядок sortOrder (детермінізм при нулях).
  int compare(String a, String b) {
    final byRank = rankOf(b).compareTo(rankOf(a));
    if (byRank != 0) return byRank;
    final la = lastUsedOf(a);
    final lb = lastUsedOf(b);
    if (la != null || lb != null) {
      if (la == null) return 1;
      if (lb == null) return -1;
      final byUsed = lb.compareTo(la);
      if (byUsed != 0) return byUsed;
    }
    return (sortIndex[a] ?? 1 << 30).compareTo(sortIndex[b] ?? 1 << 30);
  }

  // 5. Гістерезис: чинні мешканці слотів лишаються на своїх позиціях,
  // якщо претендент не сильніший за поріг.
  final incumbents = [
    for (final id in previousSlots)
      if (active.contains(id) && !pinnedSet.contains(id)) id,
  ].take(rankedSlotCount).toList();

  final challengers = [
    for (final id in activeIds)
      if (!pinnedSet.contains(id) && !incumbents.contains(id)) id,
  ]..sort(compare);

  // Вільні слоти заповнюються найсильнішими претендентами одразу.
  var c = 0;
  while (incumbents.length < rankedSlotCount && c < challengers.length) {
    incumbents.add(challengers[c++]);
  }

  // Далі кожен претендент (від найсильнішого) може витіснити
  // найслабшого чинного, якщо помітно сильніший:
  //   rank(претендент) >= rank(чинний) + 2  ТА  >= rank(чинний) * 1.25
  for (; c < challengers.length; c++) {
    final challenger = challengers[c];
    // Найслабший чинний.
    var weakestIdx = 0;
    for (var i = 1; i < incumbents.length; i++) {
      if (rankOf(incumbents[i]) < rankOf(incumbents[weakestIdx])) {
        weakestIdx = i;
      }
    }
    final weakestRank = rankOf(incumbents[weakestIdx]);
    final chRank = rankOf(challenger);
    if (chRank >= weakestRank + 2 && chRank >= weakestRank * 1.25) {
      incumbents[weakestIdx] = challenger;
    } else {
      // Претенденти відсортовані — слабші тим більше не пройдуть.
      break;
    }
  }

  return [...pinned, ...incumbents];
}
