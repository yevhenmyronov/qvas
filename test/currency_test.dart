import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/currency.dart';

void main() {
  group('автовизначення валюти (Функціонал п.5.1)', () {
    test('регіон із таблиці', () {
      expect(detectCurrencyCode(const Locale('uk', 'UA')), 'UAH');
      expect(detectCurrencyCode(const Locale('en', 'US')), 'USD');
      expect(detectCurrencyCode(const Locale('de', 'DE')), 'EUR');
      expect(detectCurrencyCode(const Locale('pl', 'PL')), 'PLN');
    });

    test('локаль без регіону: uk → UAH, решта → USD', () {
      expect(detectCurrencyCode(const Locale('uk')), 'UAH');
      expect(detectCurrencyCode(const Locale('en')), 'USD');
      expect(detectCurrencyCode(const Locale('fr')), 'USD');
    });

    test('невідомий регіон → фолбек на мову', () {
      expect(detectCurrencyCode(const Locale('uk', 'ZZ')), 'UAH');
      expect(detectCurrencyCode(const Locale('xx', 'ZZ')), 'USD');
    });
  });

  group('формат грошей: число з локалі, символ із валюти', () {
    test('uk + UAH: символ після числа', () {
      final f = MoneyFormat.of('uk', 'UAH');
      expect(f.symbolFirst, isFalse);
      expect(f.full(85), contains('₴'));
      expect(f.full(85), startsWith('85'));
    });

    test('en + USD: символ перед числом', () {
      final f = MoneyFormat.of('en', 'USD');
      expect(f.symbolFirst, isTrue);
      expect(f.full(85), '\$85');
    });

    test('розділювач тисяч береться з локалі', () {
      expect(MoneyFormat.of('en', 'USD').number(50000), '50,000');
      // uk: нерозривний пробіл між групами.
      final uk = MoneyFormat.of('uk', 'UAH').number(50000);
      expect(uk.length, 6);
      expect(uk, startsWith('50'));
      expect(uk, endsWith('000'));
      expect(uk.codeUnitAt(2), isNot(0x20)); // не звичайний пробіл
    });
  });
}
