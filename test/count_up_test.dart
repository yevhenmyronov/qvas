import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/ui/history/count_up.dart';

/// Дві поведінки [CountUp], які легко втратити при наступній правці й
/// які не видно з коду віджета, що його використовує.
void main() {
  Widget host(int value, Object cutKey) => MaterialApp(
    home: Scaffold(
      body: CountUp(
        value: value,
        cutKey: cutKey,
        builder: (context, v) => Text('$v'),
      ),
    ),
  );

  String shown(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).data!;

  testWidgets('перший показ не рахує від нуля', (tester) async {
    // Інакше кожен вхід на Екран 2 починався б рахунком від нуля —
    // зокрема одразу після збереження, коли вже грають згортання суми
    // й поява рядка.
    await tester.pumpWidget(host(1500, 'a'));
    expect(shown(tester), '1500');

    await tester.pump(const Duration(milliseconds: 60));
    expect(shown(tester), '1500');
  });

  testWidgets('зміна значення добігає через проміжні', (tester) async {
    await tester.pumpWidget(host(100, 'a'));
    await tester.pumpWidget(host(300, 'a'));

    await tester.pump(const Duration(milliseconds: 120));
    final mid = int.parse(shown(tester));
    expect(mid, greaterThan(100));
    expect(mid, lessThan(300));

    await tester.pumpAndSettle();
    expect(shown(tester), '300');
  });

  testWidgets('зміна cutKey ріже без рахунку', (tester) async {
    await tester.pumpWidget(host(100, 'серпень'));
    // Інший місяць — це інша величина, а не зміна цієї, і в нього вже
    // є власний перехід (слайд). Рахувати від чужого числа до чужого
    // означало б показати кілька секунд неіснуючих сум.
    await tester.pumpWidget(host(9000, 'липень'));

    await tester.pump();
    expect(shown(tester), '9000');
  });
}
