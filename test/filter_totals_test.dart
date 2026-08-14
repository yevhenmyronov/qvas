import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/providers/history_providers.dart';

Transaction _tx(String currency, int minor) => Transaction(
      id: 'id-$currency-$minor',
      type: TxType.expense,
      amountMinor: minor,
      categoryId: 'cat',
      currencyCode: currency,
      createdAtUtc: DateTime.utc(2026, 8, 15),
      localDateKey: '2026-08-15',
    );

void main() {
  test('порожня стрічка → порожній підсумок', () {
    expect(filterTotalsOf(const []), isEmpty);
  });

  test('одна валюта складається в одну суму', () {
    final totals = filterTotalsOf([_tx('UAH', 8500), _tx('UAH', 1500)]);
    expect(totals, hasLength(1));
    expect(totals.single.currencyCode, 'UAH');
    expect(totals.single.totalMinor, 10000);
  });

  test('валюти не складаються між собою, порядок — перша поява', () {
    final totals = filterTotalsOf([
      _tx('UAH', 8500),
      _tx('EUR', 2000),
      _tx('UAH', 500),
    ]);
    expect(totals, hasLength(2));
    expect(totals[0].currencyCode, 'UAH');
    expect(totals[0].totalMinor, 9000);
    expect(totals[1].currencyCode, 'EUR');
    expect(totals[1].totalMinor, 2000);
  });
}
