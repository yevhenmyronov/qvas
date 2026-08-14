import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/note_suggestions.dart';

({String note, DateTime createdAtUtc}) _row(String note, [int day = 1]) =>
    (note: note, createdAtUtc: DateTime.utc(2026, 8, day));

void main() {
  test('порожній вхід → порожні підказки', () {
    expect(rankNotes(const []), isEmpty);
  });

  test('поріг 3: дві появи не показуються, три — показуються', () {
    final rows = [
      _row('Обідок'), _row('Обідок'), _row('Обідок'),
      _row('Перекус'), _row('Перекус'),
    ];
    expect(rankNotes(rows), ['Обідок']);
  });

  test('частіша нотатка перша', () {
    final rows = [
      for (var i = 0; i < 3; i++) _row('Кава з собою'),
      for (var i = 0; i < 5; i++) _row('Обідок'),
    ];
    expect(rankNotes(rows), ['Обідок', 'Кава з собою']);
  });

  test('при рівній частоті перемагає свіжіша', () {
    final rows = [
      _row('Стара', 1), _row('Стара', 2), _row('Стара', 3),
      _row('Нова', 4), _row('Нова', 5), _row('Нова', 6),
    ];
    expect(rankNotes(rows), ['Нова', 'Стара']);
  });

  test('ліміт 2 навіть якщо кандидатів більше', () {
    final rows = [
      for (var i = 0; i < 3; i++) _row('А'),
      for (var i = 0; i < 4; i++) _row('Б'),
      for (var i = 0; i < 5; i++) _row('В'),
    ];
    expect(rankNotes(rows), hasLength(2));
    expect(rankNotes(rows), ['В', 'Б']);
  });

  test('trim групує варіанти з пробілами, порожні після trim відкидаються', () {
    final rows = [
      _row('Обідок'), _row(' Обідок '), _row('Обідок  '),
      _row('   '), _row('   '), _row('   '),
    ];
    expect(rankNotes(rows), ['Обідок']);
  });
}
