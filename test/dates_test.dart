import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/dates.dart';

void main() {
  group('localDateKeyOf', () {
    test('форматує з нулями', () {
      expect(localDateKeyOf(DateTime(2026, 8, 3)), '2026-08-03');
      expect(localDateKeyOf(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('береться з локального часу, а не UTC', () {
      // 23:30 локально лишається тим самим днем незалежно від пояса.
      expect(localDateKeyOf(DateTime(2026, 8, 13, 23, 30)), '2026-08-13');
    });
  });

  group('межі місяця', () {
    test('початок завжди 1-го', () {
      expect(monthStartKey(2026, 8), '2026-08-01');
      expect(monthStartKey(2026, 1), '2026-01-01');
    });

    test('кінець — останній день місяця', () {
      expect(monthEndKey(2026, 8), '2026-08-31');
      expect(monthEndKey(2026, 2), '2026-02-28');
      expect(monthEndKey(2024, 2), '2024-02-29'); // високосний
      expect(monthEndKey(2026, 4), '2026-04-30');
      expect(monthEndKey(2026, 12), '2026-12-31');
    });

    test('порівняння рядків дає правильний діапазон', () {
      const key = '2026-08-13';
      expect(key.compareTo(monthStartKey(2026, 8)) >= 0, isTrue);
      expect(key.compareTo(monthEndKey(2026, 8)) <= 0, isTrue);
      expect('2026-09-01'.compareTo(monthEndKey(2026, 8)) > 0, isTrue);
      expect('2026-07-31'.compareTo(monthStartKey(2026, 8)) < 0, isTrue);
    });
  });

  test('parseDateKey — зворотний розбір', () {
    final p = parseDateKey('2026-08-03');
    expect((p.year, p.month, p.day), (2026, 8, 3));
  });
}
