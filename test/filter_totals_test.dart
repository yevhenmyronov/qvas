import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/history_providers.dart';

Transaction _tx(int minor) => Transaction(
      id: 'id-$minor',
      type: TxType.expense,
      amountMinor: minor,
      categoryId: 'cat',
      currencyCode: 'UAH',
      createdAtUtc: DateTime.utc(2026, 8, 15),
      localDateKey: '2026-08-15',
    );

void main() {
  test('порожня стрічка → нуль', () {
    expect(filterTotalOf(const []), 0);
  });

  test('підсумок фільтра — сума мінорних одиниць', () {
    expect(filterTotalOf([_tx(8500), _tx(1500)]), 10000);
  });

  test('int-арифметика не втрачає копійок на довгій стрічці', () {
    final many = [for (var i = 0; i < 1000; i++) _tx(1)];
    expect(filterTotalOf(many), 1000);
  });
}
