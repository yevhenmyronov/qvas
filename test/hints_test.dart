import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/hints.dart';

/// Пороги підказок (рішення 89).
///
/// Помилка тут не видна на пристрої: підказка, яка не з'явилась, нічим
/// себе не виявляє, а підказка, яка з'явилась двічі, помітна вже після
/// того, як набридла. Тому пороги перевіряються тут.
void main() {
  group('pendingHint', () {
    test('перший запис відкриває підказку про дії з рядком', () {
      expect(
        pendingHint(shownMask: 0, monthRecords: 1, topCategoryRecords: 1),
        AppHint.rowActions,
      );
    });

    test('порожній місяць не показує нічого', () {
      expect(
        pendingHint(shownMask: 0, monthRecords: 0, topCategoryRecords: 0),
        isNull,
      );
    });

    test('одна за раз: десять записів не вивалюють усі три', () {
      // Умови всіх трьох виконані одночасно. Показати їх разом означало б
      // зробити рівно той туторіал, від якого рішення 89 відмовляється.
      const many = 10;
      final first = pendingHint(
          shownMask: 0, monthRecords: many, topCategoryRecords: 5);
      expect(first, AppHint.rowActions);

      final second = pendingHint(
          shownMask: first!.bit, monthRecords: many, topCategoryRecords: 5);
      expect(second, AppHint.breakdown);

      final third = pendingHint(
          shownMask: first.bit | second!.bit,
          monthRecords: many,
          topCategoryRecords: 5);
      expect(third, AppHint.categoryFilter);

      expect(
        pendingHint(
            shownMask: first.bit | second.bit | third!.bit,
            monthRecords: many,
            topCategoryRecords: 5),
        isNull,
        reason: 'четвертої підказки не існує',
      );
    });

    test('розкладка чекає на десять записів', () {
      expect(
        pendingHint(
            shownMask: AppHint.rowActions.bit,
            monthRecords: 9,
            topCategoryRecords: 1),
        isNull,
      );
      expect(
        pendingHint(
            shownMask: AppHint.rowActions.bit,
            monthRecords: 10,
            topCategoryRecords: 1),
        AppHint.breakdown,
      );
    });

    test('фільтр чекає, поки в одній категорії набереться три записи', () {
      const shown = 1 | 2; // rowActions + breakdown
      expect(
        pendingHint(
            shownMask: shown, monthRecords: 30, topCategoryRecords: 2),
        isNull,
      );
      expect(
        pendingHint(
            shownMask: shown, monthRecords: 30, topCategoryRecords: 3),
        AppHint.categoryFilter,
      );
    });

    test('біти не перетинаються', () {
      final bits = AppHint.values.map((h) => h.bit).toList();
      expect(bits.toSet().length, bits.length);
      // Маска мусить лишатись розкладною: сума всіх бітів дорівнює їх
      // побітовому АБО лише тоді, коли жоден не накриває інший.
      expect(
        bits.reduce((a, b) => a | b),
        bits.reduce((a, b) => a + b),
      );
    });
  });

  group('topCategoryCount', () {
    test('рахує найчастішу категорію', () {
      expect(topCategoryCount(['a', 'b', 'a', 'c', 'a']), 3);
      expect(topCategoryCount(['a', 'b']), 1);
    });

    test('порожня стрічка — нуль', () {
      expect(topCategoryCount([]), 0);
    });
  });
}
