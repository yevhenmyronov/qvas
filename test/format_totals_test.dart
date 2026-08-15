import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/models/currency.dart';

/// Компактний підсумок по валютах (Функціонал п.5): у заголовку дня і в
/// рядку «Сьогодні» суми різних валют стоять поруч, а не складаються.
void main() {
  test('порожній підсумок → порожній рядок', () {
    expect(formatTotals('uk', const []), '');
  });

  test('одна валюта — звичайна сума, позиція символу з локалі', () {
    expect(formatTotals('uk', [(currencyCode: 'UAH', totalMinor: 45000)]),
        contains('450'));
    expect(formatTotals('en', [(currencyCode: 'USD', totalMinor: 15000)]),
        startsWith(r'$'));
  });

  test('дві валюти — через роздільник, без складання', () {
    final text = formatTotals('uk', const [
      (currencyCode: 'USD', totalMinor: 10000),
      (currencyCode: 'UAH', totalMinor: 40000),
    ]);
    expect(text, contains(totalsSeparator));
    expect(text.indexOf('100'), lessThan(text.indexOf('400')));
    // Головне, чого не мало статись: 100 + 400 = 500 одним числом.
    expect(text, isNot(contains('500')));
  });

  test('порядок рядка — той, у якому передали підсумки', () {
    final text = formatTotals('uk', const [
      (currencyCode: 'UAH', totalMinor: 40000),
      (currencyCode: 'USD', totalMinor: 10000),
    ]);
    expect(text.indexOf('400'), lessThan(text.indexOf('100')));
  });
}
