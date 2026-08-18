import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/amount_input.dart';
import 'package:qvas/models/currency.dart';
import 'package:qvas/theme/tokens.dart';
import 'package:qvas/ui/input/amount_display.dart';

/// Сума перебудована з одного `Text.rich` на ряд погліфових `Text`, щоб
/// цифри могли з'являтись поодинці. Це найризикованіша зміна всієї
/// роботи: правильність тут одночасно залежить від локалі
/// (розділювач тисяч — нерозривний пробіл в uk), від валюти (символ
/// перед числом чи після) й від автозменшення кеглю. Зламати тихо дуже
/// легко, і жоден інший тест цього не побачить.
///
/// Тому перевіряється не «як воно виглядає», а інваріант: склеєний
/// текст усіх `Text` має точно дорівнювати рядку, який давала стара
/// однорядкова реалізація.
void main() {
  /// Те, що будував старий `Text.rich`, — еталон. Знака в ньому немає
  /// в жодному режимі: з рішення 77 дохід позначає колір цифр, а не
  /// «+», тож текст суми однаковий у витраті й доході — цикл по
  /// `income` нижче тепер стереже саме це.
  String expected(MoneyFormat f, int value) {
    final number = f.number(value);
    return f.symbolFirst ? '${f.symbol} $number' : '$number ${f.symbol}';
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
              expected(format, value),
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
        expected(format, amount.displayValue),
        reason: 'посеред анімації текст має бути вже повним',
      );
      await tester.pumpAndSettle();
      expect(rendered(tester), expected(format, amount.displayValue));
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
    expect(rendered(tester), expected(format, amount.displayValue));
  });

  /// Після рішення 77 весь сигнал про режим у сумі несе колір цифр —
  /// текст у витраті й доході однаковий. Інваріант вище цього не
  /// побачить: склеєний рядок стилів не знає.
  testWidgets('дохід фарбує цифри, витрата лишає їх білими', (tester) async {
    final format = MoneyFormat.of('uk', 'UAH');

    Color colorOf(String glyph) => tester
        .widgetList<Text>(find.byType(Text))
        .firstWhere((t) => t.data == glyph)
        .style!
        .color!;

    await pumpAmount(tester, format: format, value: 2000, income: true);
    expect(colorOf('2'), AppColors.income);
    expect(colorOf(' ₴'), AppColors.incomeMuted,
        reason: 'сірий символ на зеленій сумі читався б як хвіст');

    await pumpAmount(tester, format: format, value: 2000, income: false);
    expect(colorOf('2'), AppColors.textPrimary);
    expect(colorOf(' ₴'), AppColors.textSecondary);

    // «Порожньо» й «набрано» — окремі стани, і різницю між ними несе
    // яскравість, а не відтінок (рішення 78).
    await pumpAmount(tester, format: format, value: 0, income: true);
    expect(colorOf('0'), AppColors.incomeMuted);

    // У витраті зелений означав би дохід, тож нуль лишається сірим.
    await pumpAmount(tester, format: format, value: 0, income: false);
    expect(colorOf('0'), AppColors.textTertiary);
  });
}
