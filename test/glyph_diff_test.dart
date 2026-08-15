import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/ui/input/animated_number.dart';

/// Уся складність погліфової анімації суми — тут, у чистій функції.
///
/// Перша версія порівнювала гліфи, і анімація мовчки вмирала після
/// третьої цифри: на четвертій з'являється розділювач тисяч і зсуває
/// решту позицій, тож для дифа це виглядало не як «дописали один
/// гліф», а як перебудова цілого рядка. На пристрої це помітно тільки
/// оком і тільки якщо спеціально набирати довге число — тому діф
/// перевіряється окремо від віджета.
void main() {
  const nbsp = ' ';

  group('набір', () {
    test('перша цифра поверх нуля заходить рухом', () {
      final d = GlyphDiff.between('0', '5');
      expect(d.animate, isTrue);
      expect(d.stable, 0);
      expect(d.ghosts, isEmpty);
    });

    test('друга й третя цифри — один гліф праворуч', () {
      for (final (before, after) in [('1', '12'), ('12', '123')]) {
        final d = GlyphDiff.between(before, after);
        expect(d.animate, isTrue, reason: '$before → $after');
        expect(d.stable, after.length - 1, reason: '$before → $after');
      }
    });

    test('четверта цифра — розділювач не має ламати анімацію', () {
      final d = GlyphDiff.between('123', '1${nbsp}234');
      expect(d.animate, isTrue, reason: 'саме тут анімація вмирала');
      // Заходить лише останній гліф; розділювач просто стає на місце.
      expect(d.stable, '1${nbsp}234'.length - 1);
      expect(d.ghosts, isEmpty);
    });

    test('розділювач, що переїжджає, теж не ламає', () {
      final d = GlyphDiff.between('1${nbsp}234', '12${nbsp}345');
      expect(d.animate, isTrue);
      expect(d.stable, '12${nbsp}345'.length - 1);
    });

    test('сьомий розряд', () {
      final d = GlyphDiff.between('999${nbsp}999', '9${nbsp}999${nbsp}999');
      expect(d.animate, isTrue);
      expect(d.stable, '9${nbsp}999${nbsp}999'.length - 1);
    });
  });

  group('backspace', () {
    test('одна цифра праворуч стає привидом', () {
      final d = GlyphDiff.between('123', '12');
      expect(d.animate, isTrue);
      expect(d.stable, 2);
      expect(d.ghosts, ['3']);
    });

    test('зникнення розділювача не ламає', () {
      final d = GlyphDiff.between('1${nbsp}234', '123');
      expect(d.animate, isTrue);
      expect(d.ghosts, ['4']);
    });
  });

  group('без анімації', () {
    test('результат калькулятора підміняється', () {
      final d = GlyphDiff.between('800', '400');
      expect(d.animate, isFalse);
    });

    test('очищення довгого числа підміняється', () {
      final d = GlyphDiff.between('12${nbsp}345', '0');
      expect(d.animate, isFalse);
    });

    test('те саме число — нічого не відбувається', () {
      final d = GlyphDiff.between('123', '123');
      expect(d.animate, isFalse);
    });
  });
}
