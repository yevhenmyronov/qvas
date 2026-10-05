import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/note_suggestions.dart';

({String note, DateTime createdAtUtc}) _row(String note, [int day = 1]) =>
    (note: note, createdAtUtc: DateTime.utc(2026, 8, day));

void main() {
  test('порожній вхід → порожні підказки', () {
    expect(rankNotes(const []), isEmpty);
  });

  test('поріг 2: одна поява не показується, дві — показуються', () {
    final rows = [_row('Обід'), _row('Обід'), _row('Перекус')];
    expect(rankNotes(rows), ['Обід']);
  });

  test('частіший коментар перший', () {
    final rows = [
      for (var i = 0; i < 2; i++) _row('Кава з собою'),
      for (var i = 0; i < 5; i++) _row('Обід'),
    ];
    expect(rankNotes(rows), ['Обід', 'Кава з собою']);
  });

  test('при рівній частоті перемагає свіжіший', () {
    final rows = [
      _row('Старий', 1), _row('Старий', 2),
      _row('Новий', 4), _row('Новий', 5),
    ];
    expect(rankNotes(rows), ['Новий', 'Старий']);
  });

  test('ліміт 3 навіть якщо кандидатів більше', () {
    final rows = [
      for (var i = 0; i < 2; i++) _row('А'),
      for (var i = 0; i < 3; i++) _row('Б'),
      for (var i = 0; i < 4; i++) _row('В'),
      for (var i = 0; i < 5; i++) _row('Г'),
    ];
    expect(rankNotes(rows), ['Г', 'В', 'Б']);
  });

  test('trim групує варіанти з пробілами, порожні після trim відкидаються', () {
    final rows = [
      _row('Обід'), _row(' Обід '),
      _row('   '), _row('   '), _row('   '),
    ];
    expect(rankNotes(rows), ['Обід']);
  });
}
