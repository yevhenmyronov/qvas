/// Форматування чисел для UI. v0.1 — українська локаль захардкожена:
/// розділювач тисяч — нерозривний пробіл, символ валюти після числа.
library;

/// v0.1: валюта захардкожена (план v0.1). У v0.2 приїде з налаштувань.
const kCurrencyCode = 'UAH';
const kCurrencySymbol = '₴';

const _nbsp = ' ';

/// 50000 → '50 000' (нерозривний пробіл).
String groupDigits(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(_nbsp);
    b.write(s[i]);
  }
  return b.toString();
}

/// '14 200 ₴' — для місць, де символ іде тим самим кеглем.
String formatMoney(int major) => '${groupDigits(major)}$_nbsp$kCurrencySymbol';
