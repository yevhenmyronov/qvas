import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/smart_categories.dart';

CategoryRank r(String id, int rank, {DateTime? used}) =>
    (categoryId: id, rank: rank, lastUsed: used);

void main() {
  final activeIds = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  group('базове ранжування', () {
    test('без історії та кешу — перші п’ять за sortOrder', () {
      final slots = computeSmartSlots(
        ranks: const [],
        pinnedIds: const [],
        previousSlots: const [],
        activeIds: activeIds,
      );
      expect(slots, ['a', 'b', 'c', 'd', 'e']);
    });

    test('перший розрахунок — за спаданням rank', () {
      final slots = computeSmartSlots(
        ranks: [r('f', 10), r('g', 8), r('a', 5), r('b', 3), r('c', 1)],
        pinnedIds: const [],
        previousSlots: const [],
        activeIds: activeIds,
      );
      expect(slots, ['f', 'g', 'a', 'b', 'c']);
    });

    test('тай-брейк — пізніша дата останнього використання', () {
      final earlier = DateTime.utc(2026, 8, 1);
      final later = DateTime.utc(2026, 8, 10);
      final slots = computeSmartSlots(
        ranks: [
          r('a', 5, used: earlier),
          r('b', 5, used: later),
        ],
        pinnedIds: const [],
        previousSlots: const [],
        activeIds: activeIds,
      );
      expect(slots.indexOf('b') < slots.indexOf('a'), isTrue);
    });
  });

  group('закріплені', () {
    test('йдуть першими в порядку sortOrder і не рухаються алгоритмом', () {
      final slots = computeSmartSlots(
        ranks: [r('f', 100)],
        pinnedIds: const ['d', 'b'],
        previousSlots: const [],
        activeIds: activeIds,
      );
      expect(slots.sublist(0, 2), ['d', 'b']);
      expect(slots.length, 5);
      expect(slots.contains('f'), isTrue);
    });

    test('п’ять закріплених займають усі слоти', () {
      final slots = computeSmartSlots(
        ranks: [r('f', 100)],
        pinnedIds: const ['a', 'b', 'c', 'd', 'e'],
        previousSlots: const [],
        activeIds: activeIds,
      );
      expect(slots, ['a', 'b', 'c', 'd', 'e']);
    });
  });

  group('гістерезис', () {
    // Чинний склад: a(4), b(4), c(4), d(4), e(4).
    final prev = ['a', 'b', 'c', 'd', 'e'];
    final baseRanks = [r('a', 4), r('b', 4), r('c', 4), r('d', 4), r('e', 4)];

    test('претендент з rank+1 НЕ витісняє (менше ніж +2)', () {
      final slots = computeSmartSlots(
        ranks: [...baseRanks, r('f', 5)],
        pinnedIds: const [],
        previousSlots: prev,
        activeIds: activeIds,
      );
      expect(slots, prev); // склад не змінився
    });

    test('претендент із +2 і ×1.25 витісняє найслабшого', () {
      final slots = computeSmartSlots(
        ranks: [
          r('a', 10), r('b', 9), r('c', 8), r('d', 7), r('e', 4),
          r('f', 6), // 6 >= 4+2 і 6 >= 4*1.25 → витісняє e
        ],
        pinnedIds: const [],
        previousSlots: prev,
        activeIds: activeIds,
      );
      expect(slots.contains('f'), isTrue);
      expect(slots.contains('e'), isFalse);
      // Позиції решти стабільні.
      expect(slots.sublist(0, 4), ['a', 'b', 'c', 'd']);
    });

    test('умова ×1.25 працює й на великих числах', () {
      // Чинний 20; претендент 22: +2 виконано, але 22 < 20*1.25=25 → ні.
      final slots = computeSmartSlots(
        ranks: [
          r('a', 30), r('b', 28), r('c', 26), r('d', 24), r('e', 20),
          r('f', 22),
        ],
        pinnedIds: const [],
        previousSlots: prev,
        activeIds: activeIds,
      );
      expect(slots, prev);
    });

    test('архівований чинний звільняє слот без гістерезису', () {
      final slots = computeSmartSlots(
        ranks: baseRanks,
        pinnedIds: const [],
        previousSlots: prev,
        activeIds: ['a', 'b', 'c', 'd', 'f', 'g', 'h'], // e архівовано
        );
      expect(slots.contains('e'), isFalse);
      expect(slots.length, 5);
      expect(slots.sublist(0, 4), ['a', 'b', 'c', 'd']);
    });

    test('нове закріплення зменшує ранжовані слоти', () {
      final slots = computeSmartSlots(
        ranks: baseRanks,
        pinnedIds: const ['h'],
        previousSlots: prev,
        activeIds: activeIds,
      );
      expect(slots.first, 'h');
      expect(slots.length, 5);
      // Чинні лишаються в порядку, найслабший хвіст відпадає через
      // усічення до 4 ранжованих слотів.
      expect(slots.sublist(1), ['a', 'b', 'c', 'd']);
    });
  });
}
