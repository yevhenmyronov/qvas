import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/ui/common/app_sheet.dart';

/// Регресія 2026-08-16: шторка зберігала зміни, але не опускалась.
///
/// [showAppSheet] передає власний `transitionAnimationController`, щоб
/// шторки реагували на системне «Прибрати анімації». Такий контролер
/// зобов'язаний викидати той, хто його створив, — і робилось це надто
/// рано: Future від `showModalBottomSheet` завершується раніше, ніж
/// шторка доїжджає вниз, а зворотний хід грає саме на цьому контролері.
///
/// Ізольовано експериментом: без переданого контролера шторка
/// закривається; з ним і без викидання — теж; ламає саме викидання.
/// Проміжна спроба відкласти його таймером «тривалість + запас» цей
/// тест теж не пройшла — тому орієнтиром став стан контролера.
///
/// Симптом виглядав як логічний баг («кнопка не закриває вікно»), а
/// причина була в часі життя об'єкта — тому це тест, а не виправлений
/// рядок.
void main() {
  Widget host() {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showAppSheet<void>(
                context,
                builder: (sheetContext) => TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('всередині'),
                ),
              ),
              child: const Text('відкрити'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('шторка справді зникає після pop', (tester) async {
    await tester.pumpWidget(host());

    await tester.tap(find.text('відкрити'));
    await tester.pumpAndSettle();
    expect(find.text('всередині'), findsOneWidget);

    await tester.tap(find.text('всередині'));
    await tester.pumpAndSettle();
    expect(
      find.text('всередині'),
      findsNothing,
      reason: 'шторка лишилась на екрані після pop',
    );

    // Дочекатись відкладеного викидання контролера, щоб тест не впав
    // на «A Timer is still pending».
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('шторка зникає і при змахуванні по фону', (tester) async {
    await tester.pumpWidget(host());

    await tester.tap(find.text('відкрити'));
    await tester.pumpAndSettle();
    expect(find.text('всередині'), findsOneWidget);

    // Тап по затемненню позаду — другий шлях закриття, і він теж
    // проходить через той самий контролер.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('всередині'), findsNothing);

    await tester.pump(const Duration(milliseconds: 400));
  });
}
