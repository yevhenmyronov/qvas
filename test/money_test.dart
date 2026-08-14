import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/money.dart';

void main() {
  test('мінорні ↔ мажорні', () {
    expect(majorToMinor(85), 8500);
    expect(8500.toMajor, 85);
    expect(0.toMajor, 0);
    expect(majorToMinor(maxAmountMajor), 999999900);
    expect(999999900.toMajor, maxAmountMajor);
  });

  test('int-арифметика не втрачає копійок при підсумовуванні', () {
    // Класична пастка double (0.1 + 0.2 != 0.3) тут неможлива в принципі.
    final sum = List.filled(1000, majorToMinor(1)).reduce((a, b) => a + b);
    expect(sum.toMajor, 1000);
  });
}
