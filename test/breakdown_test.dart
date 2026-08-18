import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/breakdown.dart';

/// Упорядкування розкладки за категоріями.
void main() {
  test('сортує за спаданням суми', () {
    final r = rankedTotals([
      (categoryId: 'transport', totalMinor: 2000),
      (categoryId: 'food', totalMinor: 6000),
      (categoryId: 'home', totalMinor: 3000),
    ]);

    expect(r.map((e) => e.categoryId), ['food', 'home', 'transport']);
  });

  test('рівні суми впорядковані детерміновано', () {
    // Інакше дві категорії з однаковою сумою мінялися б місцями між
    // перемальовками — залежно від того, у якому порядку їх віддала
    // база. На екрані це виглядало б як самовільне смикання списку.
    final forward = rankedTotals([
      (categoryId: 'b', totalMinor: 100),
      (categoryId: 'a', totalMinor: 100),
    ]);
    final reversed = rankedTotals([
      (categoryId: 'a', totalMinor: 100),
      (categoryId: 'b', totalMinor: 100),
    ]);

    expect(forward.map((e) => e.categoryId), ['a', 'b']);
    expect(reversed.map((e) => e.categoryId), ['a', 'b']);
  });

  test('вхідний список не мутується', () {
    // Приходить він зі стріму бази, тобто може бути перевикористаний.
    final source = [
      (categoryId: 'a', totalMinor: 100),
      (categoryId: 'b', totalMinor: 900),
    ];
    rankedTotals(source);

    expect(source.first.categoryId, 'a');
  });

  test('порожній місяць', () {
    expect(rankedTotals([]), isEmpty);
  });
}
