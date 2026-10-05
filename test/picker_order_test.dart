import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/smart_categories.dart';

CategoryRank _r(String id, int rank, [int? day]) => (
      categoryId: id,
      rank: rank,
      lastUsed: day == null ? null : DateTime.utc(2026, 9, day),
    );

/// Шторка «Всі категорії»: найчастіші з тих, кого немає серед бульбашок,
/// згори; п'ятірка бульбашок — наприкінці, у порядку екрана.
void main() {
  const active = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

  test('частіші вище, бульбашки в кінці в порядку екрана', () {
    final order = pickerOrder(
      ranks: [_r('a', 9, 1), _r('d', 2, 1), _r('f', 5, 1), _r('b', 20, 1)],
      activeIds: active,
      bubbleIds: ['b', 'a'],
    );
    expect(order, ['f', 'd', 'c', 'e', 'g', 'b', 'a']);
  });

  test('рівна частота — свіжіший вище', () {
    final order = pickerOrder(
      ranks: [_r('c', 3, 2), _r('e', 3, 8)],
      activeIds: active,
      bubbleIds: const [],
    );
    expect(order.take(2), ['e', 'c']);
  });

  test('невикористані лишаються в порядку sortOrder', () {
    final order = pickerOrder(
      ranks: const [],
      activeIds: active,
      bubbleIds: const [],
    );
    expect(order, active);
  });

  test('бульбашка, якої вже немає серед активних, не з\'являється', () {
    final order = pickerOrder(
      ranks: const [],
      activeIds: const ['a', 'b'],
      bubbleIds: const ['x', 'a'],
    );
    expect(order, ['b', 'a']);
  });
}
