import 'package:flutter/foundation.dart';

import 'money.dart';

/// Оператор калькулятора. Тільки чотири дії, зліва направо, без пріоритету
/// (межа зафіксована в Scope).
enum CalcOp { add, sub, mul, div }

/// Що намальовано на клітинці калькулятора (Функціонал п.2.2.1):
/// завжди показує, що станеться при натисканні.
enum CalcKeyFace { icon, operator, equals }

/// Стан вводу суми — одна незмінна структура (тех. спека п.12).
/// Уся арифметика — тут, без жодного віджета. Значення в мажорних одиницях.
@immutable
class AmountInput {
  const AmountInput({
    this.current = 0,
    this.left,
    this.op,
    this.typedSecond = false,
  });

  /// Число, яке зараз набирається.
  final int current;

  /// Лівий операнд; null — виразу немає.
  final int? left;

  /// Обраний оператор.
  final CalcOp? op;

  /// Чи введено хоч одну цифру другого операнда.
  final bool typedSecond;

  static const empty = AmountInput();

  bool get hasExpression => op != null;

  /// Велика цифра завжди показує число, яке зараз набирається; поки другий
  /// операнд не почато — лівий операнд.
  int get displayValue =>
      (op != null && !typedSecond) ? left! : current;

  CalcKeyFace get keyFace {
    if (op == null) return CalcKeyFace.icon;
    return typedSecond ? CalcKeyFace.equals : CalcKeyFace.operator;
  }

  /// Рядок виразу під сумою: '800 −' або '800 − 400'. null — виразу немає.
  String? get expressionText {
    final op = this.op;
    if (op == null) return null;
    final sign = switch (op) {
      CalcOp.add => '+',
      CalcOp.sub => '−',
      CalcOp.mul => '×',
      CalcOp.div => '÷',
    };
    return typedSecond ? '$left $sign $current' : '$left $sign';
  }

  AmountInput _copy({
    int? current,
    int? Function()? left,
    CalcOp? Function()? op,
    bool? typedSecond,
  }) {
    return AmountInput(
      current: current ?? this.current,
      left: left != null ? left() : this.left,
      op: op != null ? op() : this.op,
      typedSecond: typedSecond ?? this.typedSecond,
    );
  }

  /// Натиснута цифра. Максимум 7 розрядів — далі ігнорується; ведучі нулі
  /// не накопичуються (Функціонал п.2.2).
  AmountInput pressDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    if (op != null && !typedSecond) {
      // Перша цифра другого операнда починає його з нуля.
      return _copy(current: digit, typedSecond: true);
    }
    final next = current * 10 + digit;
    if (next > maxAmountMajor) return this;
    return _copy(current: next);
  }

  /// Backspace: видаляє один розряд. Під час другого операнда стирає його
  /// розряди; коли той порожній — скасовує оператор і повертає лівий операнд.
  AmountInput pressBackspace() {
    if (op != null) {
      if (typedSecond && current > 0) {
        final next = current ~/ 10;
        return next == 0
            ? _copy(current: left!, typedSecond: false)
            : _copy(current: next);
      }
      // Операнд порожній — скасовуємо оператор.
      return _copy(
        current: left!,
        left: () => null,
        op: () => null,
        typedSecond: false,
      );
    }
    return _copy(current: current ~/ 10);
  }

  /// Довге натискання backspace: повне очищення — і сума, і вираз.
  AmountInput clear() => AmountInput.empty;

  /// Тап по клітинці калькулятора — поведінка залежить від стану
  /// (таблиця у Функціоналі п.2.2.1).
  AmountInput pressCalcKey() {
    if (op == null) {
      // Відкрити вираз: поточне число стає лівим операндом, оператор «плюс».
      return _copy(left: () => current, op: () => CalcOp.add);
    }
    if (!typedSecond) {
      // Циклічна зміна оператора: + → − → × → ÷ → +
      final next = CalcOp.values[(op!.index + 1) % CalcOp.values.length];
      return _copy(op: () => next);
    }
    return resolve();
  }

  /// Обчислення виразу. Чиста функція — викликається рівно з двох місць:
  /// тап по «=» і кнопка «Зберегти».
  ///
  /// Правила (Функціонал п.2.2.1): ділення half-up до цілого; ділення на
  /// нуль ігнорується (вираз лишається відкритим); від'ємний результат → 0;
  /// переповнення обрізається до 9 999 999.
  AmountInput resolve() {
    final op = this.op;
    if (op == null) return this;
    if (!typedSecond) {
      // «Половина виразу» ніколи не зберігається — оператор відкидається.
      return AmountInput(current: left!);
    }
    final a = left!;
    final b = current;
    int result;
    switch (op) {
      case CalcOp.add:
        result = a + b;
      case CalcOp.sub:
        result = a - b;
      case CalcOp.mul:
        result = a * b;
      case CalcOp.div:
        if (b == 0) return this; // тап по «=» ігнорується
        result = (a + b ~/ 2) ~/ b; // half-up
    }
    result = result.clamp(0, maxAmountMajor);
    return AmountInput(current: result);
  }

  /// Сума для збереження: незавершений вираз обчислюється автоматично.
  int get resolvedAmount => resolve().displayValue;

  /// Серіалізація для відновлення стану при згортанні (Функціонал п.11):
  /// зберігається вся структура, а не лише підсумкова сума.
  Map<String, Object?> toJson() => {
        'current': current,
        'left': left,
        'op': op?.name,
        'typedSecond': typedSecond,
      };

  factory AmountInput.fromJson(Map<String, Object?> json) {
    final opName = json['op'] as String?;
    return AmountInput(
      current: json['current'] as int? ?? 0,
      left: json['left'] as int?,
      op: opName == null
          ? null
          : CalcOp.values.firstWhere((o) => o.name == opName),
      typedSecond: json['typedSecond'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AmountInput &&
      other.current == current &&
      other.left == left &&
      other.op == op &&
      other.typedSecond == typedSecond;

  @override
  int get hashCode => Object.hash(current, left, op, typedSecond);

  @override
  String toString() =>
      'AmountInput(current: $current, left: $left, op: $op, typedSecond: $typedSecond)';
}
