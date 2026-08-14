/// Робота з localDateKey — рядком 'yyyy-MM-dd', обчисленим із локального часу
/// в момент запису (тех. спека п.2.3). Групування й межі місяця — порівняння
/// рядків, без арифметики з датами й часовими поясами.
library;

String _two(int n) => n.toString().padLeft(2, '0');

/// 'yyyy-MM-dd' з локальної дати.
String localDateKeyOf(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-${_two(local.month)}-${_two(local.day)}';

/// Перший день місяця: '2026-08-01'.
String monthStartKey(int year, int month) =>
    '${year.toString().padLeft(4, '0')}-${_two(month)}-01';

/// Останній день місяця: '2026-08-31'. Місяць завжди календарний,
/// від 1-го числа (рішення 04).
String monthEndKey(int year, int month) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(lastDay)}';
}

/// Розбирає localDateKey назад у (year, month, day).
({int year, int month, int day}) parseDateKey(String key) => (
      year: int.parse(key.substring(0, 4)),
      month: int.parse(key.substring(5, 7)),
      day: int.parse(key.substring(8, 10)),
    );
