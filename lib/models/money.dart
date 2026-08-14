/// Гроші — завжди int у мінорних одиницях (8500 == 85 ₴), ніколи не double
/// (тех. спека п.2.2). Пад не має крапки, тому amountMinor завжди кратне 100;
/// конвертація живе тільки тут.
extension MoneyX on int {
  int get toMajor => this ~/ 100;
}

int majorToMinor(int major) => major * 100;

/// Максимальна сума в мажорних одиницях — 7 розрядів (Функціонал п.2.2).
const int maxAmountMajor = 9999999;
