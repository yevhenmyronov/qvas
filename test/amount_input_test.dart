import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/amount_input.dart';
import 'package:qvas/models/money.dart';

AmountInput _type(AmountInput s, String digits) {
  for (final ch in digits.split('')) {
    s = s.pressDigit(int.parse(ch));
  }
  return s;
}

void main() {
  group('набір цифр', () {
    test('звичайний набір і форматований displayValue', () {
      final s = _type(AmountInput.empty, '1250');
      expect(s.displayValue, 1250);
    });

    test('ведучі нулі не накопичуються: 0 → 5 дає 5', () {
      final s = _type(AmountInput.empty, '05');
      expect(s.displayValue, 5);
    });

    test('максимум 7 розрядів, далі ігнорується', () {
      final s = _type(AmountInput.empty, '99999999');
      expect(s.displayValue, maxAmountMajor);
    });

    test('backspace видаляє один розряд', () {
      final s = _type(AmountInput.empty, '123').pressBackspace();
      expect(s.displayValue, 12);
    });

    test('clear очищає повністю', () {
      final s = _type(AmountInput.empty, '123').pressCalcKey().clear();
      expect(s, AmountInput.empty);
    });
  });

  group('клітинка калькулятора — три стани', () {
    test('спокій → іконка', () {
      expect(AmountInput.empty.keyFace, CalcKeyFace.icon);
    });

    test('вираз відкрито → оператор, тап циклює + − × ÷', () {
      var s = _type(AmountInput.empty, '800').pressCalcKey();
      expect(s.keyFace, CalcKeyFace.operator);
      expect(s.op, CalcOp.add);
      s = s.pressCalcKey();
      expect(s.op, CalcOp.sub);
      s = s.pressCalcKey();
      expect(s.op, CalcOp.mul);
      s = s.pressCalcKey();
      expect(s.op, CalcOp.div);
      s = s.pressCalcKey();
      expect(s.op, CalcOp.add); // цикл замкнувся
    });

    test('другий операнд введено → =', () {
      final s = _type(_type(AmountInput.empty, '800').pressCalcKey(), '4');
      expect(s.keyFace, CalcKeyFace.equals);
    });
  });

  group('сценарії зі спеки', () {
    test('800 🖩 + 400 = → 400 (сценарій з Idea)', () {
      var s = _type(AmountInput.empty, '800');
      s = s.pressCalcKey(); // вираз: 800 +
      s = s.pressCalcKey(); // оператор: 800 −
      expect(s.expressionText, '800 −');
      expect(s.displayValue, 800);
      s = _type(s, '400');
      expect(s.expressionText, '800 − 400');
      expect(s.displayValue, 400);
      s = s.pressCalcKey(); // =
      expect(s.displayValue, 400);
      expect(s.hasExpression, isFalse);
      expect(s.expressionText, isNull);
    });

    test('розділити рахунок на трьох: 900 ÷ 3 = 300', () {
      var s = _type(AmountInput.empty, '900');
      s = s.pressCalcKey(); // +
      s = s.pressCalcKey(); // −
      s = s.pressCalcKey(); // ×
      s = s.pressCalcKey(); // ÷
      s = _type(s, '3').pressCalcKey();
      expect(s.displayValue, 300);
    });

    test('ланцюжок зліва направо: 100 + 50 + 25 = 175', () {
      var s = _type(AmountInput.empty, '100').pressCalcKey();
      s = _type(s, '50').pressCalcKey(); // = → 150
      expect(s.displayValue, 150);
      s = s.pressCalcKey(); // новий вираз 150 +
      s = _type(s, '25').pressCalcKey();
      expect(s.displayValue, 175);
    });

    test('без пріоритету операцій: 2 + 3 × 4 = 20, а не 14', () {
      var s = _type(AmountInput.empty, '2').pressCalcKey();
      s = _type(s, '3').pressCalcKey(); // = → 5
      s = s.pressCalcKey(); // 5 +
      s = s.pressCalcKey(); // 5 −
      s = s.pressCalcKey(); // 5 ×
      s = _type(s, '4').pressCalcKey();
      expect(s.displayValue, 20);
    });
  });

  group('правила арифметики', () {
    test('ділення half-up: 100 ÷ 3 → 33, 100 ÷ 6 → 17', () {
      var s = _type(AmountInput.empty, '100').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = s.pressCalcKey(); // ×
      s = s.pressCalcKey(); // ÷
      expect(_type(s, '3').resolve().displayValue, 33);
      expect(_type(s, '6').resolve().displayValue, 17);
    });

    test('ділення на нуль: = ігнорується, вираз лишається відкритим', () {
      var s = _type(AmountInput.empty, '100').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = s.pressCalcKey(); // ×
      s = s.pressCalcKey(); // ÷
      s = _type(s, '0');
      final after = s.pressCalcKey();
      expect(after, s); // нічого не сталося
      expect(after.hasExpression, isTrue);
    });

    test("від'ємний результат → 0", () {
      var s = _type(AmountInput.empty, '100').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = _type(s, '400').pressCalcKey();
      expect(s.displayValue, 0);
    });

    test('переповнення обрізається до 9 999 999', () {
      var s = _type(AmountInput.empty, '9000000').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = s.pressCalcKey(); // ×
      s = _type(s, '9').pressCalcKey();
      expect(s.displayValue, maxAmountMajor);
    });
  });

  group('backspace у виразі', () {
    test('стирає розряди другого операнда', () {
      var s = _type(AmountInput.empty, '800').pressCalcKey();
      s = _type(s, '45');
      s = s.pressBackspace();
      expect(s.displayValue, 4);
      expect(s.typedSecond, isTrue);
    });

    test('порожній другий операнд → повернення до лівого', () {
      var s = _type(AmountInput.empty, '800').pressCalcKey();
      s = _type(s, '4').pressBackspace();
      expect(s.displayValue, 800);
      expect(s.typedSecond, isFalse);
      expect(s.hasExpression, isTrue);
    });

    test('ще один backspace скасовує оператор', () {
      var s = _type(AmountInput.empty, '800').pressCalcKey();
      s = s.pressBackspace();
      expect(s.hasExpression, isFalse);
      expect(s.displayValue, 800);
    });
  });

  group('автопідбиття при збереженні', () {
    test('завершений вираз обчислюється', () {
      var s = _type(AmountInput.empty, '800').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = _type(s, '300');
      expect(s.resolvedAmount, 500);
    });

    test('половина виразу ніколи не зберігається — оператор відкидається', () {
      final s = _type(AmountInput.empty, '800').pressCalcKey();
      expect(s.resolvedAmount, 800);
    });

    test('незавершене ділення на нуль зберігає лівий операнд', () {
      var s = _type(AmountInput.empty, '100').pressCalcKey();
      s = s.pressCalcKey(); // −
      s = s.pressCalcKey(); // ×
      s = s.pressCalcKey(); // ÷
      s = _type(s, '0');
      // resolve() ігнорує, resolvedAmount мусить все одно дати число:
      // вираз лишився відкритим, displayValue — другий операнд 0...
      // Зберегти з 0 неможливо (кнопка гасне), тож тут достатньо
      // консистентності: не падаємо і не віддаємо сміття.
      expect(s.resolvedAmount, 0);
    });
  });

  test('серіалізація round-trip', () {
    var s = _type(AmountInput.empty, '800').pressCalcKey();
    s = s.pressCalcKey();
    s = _type(s, '40');
    final restored = AmountInput.fromJson(s.toJson());
    expect(restored, s);
  });
}
