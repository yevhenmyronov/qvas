import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/amount_input.dart';
import 'package:qvas/providers/input_providers.dart';

/// Умови кнопки «Зберегти» (Функціонал п.2.5) — обидві мусять виконатись.
/// Тест закриває баг аудиту 2026-08-15: категорія, видалена під ногами,
/// лишала canSave == true, і запис падав на зовнішньому ключі.
void main() {
  const cat = 'cat-id';

  test('порожній стан зберегти не можна', () {
    expect(const InputState().canSave, isFalse);
  });

  test('сума без категорії — не можна', () {
    const s = InputState(amount: AmountInput(current: 100));
    expect(s.canSave, isFalse);
  });

  test('категорія без суми — не можна', () {
    const s = InputState(categoryId: cat);
    expect(s.canSave, isFalse);
  });

  test('сума й категорія — можна', () {
    const s = InputState(amount: AmountInput(current: 100), categoryId: cat);
    expect(s.canSave, isTrue);
  });

  test('знятий вибір категорії гасить «Зберегти»', () {
    const s = InputState(amount: AmountInput(current: 100), categoryId: cat);
    final dropped = s.copyWith(categoryId: () => null);
    expect(dropped.canSave, isFalse);
    // Сума при цьому не втрачається — людина не мусить набирати заново.
    expect(dropped.amount.resolvedAmount, 100);
  });

  test('незавершений вираз рахується як сума', () {
    const s = InputState(
      amount: AmountInput(current: 400, left: 800, op: CalcOp.add,
          typedSecond: true),
      categoryId: cat,
    );
    expect(s.canSave, isTrue);
    expect(s.amount.resolvedAmount, 1200);
  });

  test('вираз із нульовим результатом зберегти не можна', () {
    const s = InputState(
      amount: AmountInput(current: 800, left: 800, op: CalcOp.sub,
          typedSecond: true),
      categoryId: cat,
    );
    expect(s.canSave, isFalse);
  });

  test('ділення на нуль не дає зберегти', () {
    const s = InputState(
      amount: AmountInput(current: 0, left: 800, op: CalcOp.div,
          typedSecond: true),
      categoryId: cat,
    );
    expect(s.canSave, isFalse);
  });
}
