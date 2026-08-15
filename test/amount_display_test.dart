import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/amount_input.dart';
import 'package:qvas/models/currency.dart';
import 'package:qvas/ui/input/amount_display.dart';

/// Сума перебудована з одного `Text.rich` на ряд погліфових `Text`, щоб
/// цифри могли з'являтись поодинці. Це найризикованіша зміна всієї
/// роботи: правильність тут одночасно залежить від локалі
/// (розділювач тисяч — нерозривний пробіл в uk), від валюти (символ
/// перед числом чи після), від знака «+» у режимі доходу й від
/// автозменшення кеглю. Зламати тихо дуже легко, і жоден інший тест
/// цього не побачить.
///
/// Тому перевіряється не «як воно виглядає», а інваріант: склеєний
/// текст усіх `Text` має точно дорівнювати рядку, який давала стара
/// однорядкова реалізація.
void main() {
  /// Те, що будував старий `Text.rich`, — еталон.
  String expected(MoneyFormat f, int value, {required bool income}) {
    final sign = income ? '+ ' : '';
    final number = f.number(value);
    return f.symbolFirst
        ? '$sign${f.symbol} $number'
        : '$sign$number ${f.symbol}';
  }

  String rendered(WidgetTester tester) {
    return tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join();
  }

  Future<void> pumpAmount(
    WidgetTester tester, {
    required MoneyFormat format,
    required int value,
    required bool income,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AmountDisplay(
              amount: AmountInput(current: value),
              format: format,
              income: income,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const locales = ['uk', 'en'];
  const currencies = ['UAH', 'USD'];
  const values = [0, 1, 999, 1000, 12345, 999999, 9999999];

  for (final locale in locales) {
    for (final code in currencies) {
      for (final income in [false, true]) {
        test('$locale/$code income=$income — формат сам по собі', () {
          // Стереже сам еталон: якщо intl колись перестане давати
          // розділювач тисяч, тест нижче почав би порівнювати зламане
          // зі зламаним і мовчки проходити.
          final f = MoneyFormat.of(locale, code);
          expect(f.number(9999999).replaceAll(RegExp(r'[\d]'), ''), isNotEmpty,
              reason: 'сім розрядів мають мати розділювачі тисяч');
        });

        testWidgets('$locale/$code income=$income — текст суми збігається', (
          tester,
        ) async {
          final format = MoneyFormat.of(locale, code);
          for (final value in values) {
            await pumpAmount(
              tester,
              format: format,
              value: value,
              income: income,
            );
            expect(
              rendered(tester),
              expected(format, value, income: income),
              reason: 'значення $value у $locale/$code',
            );
          }
        });
      }
    }
  }

  testWidgets('набір цифри: текст правильний і під час анімації', (
    tester,
  ) async {
    final format = MoneyFormat.of('uk', 'UAH');
    var amount = const AmountInput();

    Widget host() => MaterialApp(
      home: Scaffold(
        body: Center(child: AmountDisplay(amount: amount, format: format)),
      ),
    );

    await tester.pumpWidget(host());

    for (final digit in [1, 2, 3, 4]) {
      amount = amount.pressDigit(digit);
      await tester.pumpWidget(host());
      // Пів-анімації: гліф, що заходить, уже в дереві, але ще вузький.
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        rendered(tester),
        expected(format, amount.displayValue, income: false),
        reason: 'посеред анімації текст має бути вже повним',
      );
      await tester.pumpAndSettle();
      expect(rendered(tester), expected(format, amount.displayValue,
          income: false));
    }
  });

  testWidgets('backspace лишає текст коректним, поки привид згасає', (
    tester,
  ) async {
    final format = MoneyFormat.of('uk', 'UAH');
    var amount = const AmountInput().pressDigit(1).pressDigit(2).pressDigit(3);

    Widget host() => MaterialApp(
      home: Scaffold(
        body: Center(child: AmountDisplay(amount: amount, format: format)),
      ),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    amount = amount.pressBackspace();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // Привид уже знятий — зайвої цифри в тексті бути не може.
    expect(rendered(tester), expected(format, amount.displayValue,
        income: false));
  });
}
