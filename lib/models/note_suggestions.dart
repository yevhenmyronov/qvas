/// Ранжування підказок коментарів (Функціонал п.2.7): з коментарів однієї
/// категорії лишаються ті, що траплялись щонайменше [minCount] разів;
/// частіші перші, при рівній частоті — свіжіші. Групування — за текстом
/// після trim, тож «Обід» і «Обід » — одна підказка.
///
/// Поріг 2, а не 3, як було в експерименті рішення 48: ключем тепер є
/// лише категорія, а не точна сума, і повтор у ній уже означає звичку,
/// а не збіг.
List<String> rankNotes(
  Iterable<({String note, DateTime createdAtUtc})> rows, {
  int minCount = 2,
  int limit = 3,
}) {
  final counts = <String, int>{};
  final latest = <String, DateTime>{};
  for (final r in rows) {
    final note = r.note.trim();
    if (note.isEmpty) continue;
    counts[note] = (counts[note] ?? 0) + 1;
    final prev = latest[note];
    if (prev == null || r.createdAtUtc.isAfter(prev)) {
      latest[note] = r.createdAtUtc;
    }
  }
  final candidates = [
    for (final e in counts.entries)
      if (e.value >= minCount) e.key,
  ];
  candidates.sort((a, b) {
    final byCount = counts[b]!.compareTo(counts[a]!);
    if (byCount != 0) return byCount;
    return latest[b]!.compareTo(latest[a]!);
  });
  return candidates.take(limit).toList();
}
