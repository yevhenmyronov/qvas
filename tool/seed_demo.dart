// Генератор демо-даних для догфудингу: червень, липень і 1–12 серпня
// 2026 з різними категоріями, сумами й коментарями. Всі id мають
// префікс "demo-", щоб записи можна було знайти і вичистити.
//
// Запуск: dart run tool/seed_demo.dart > build/qvas-demo.json
// (пише JSON у stdout)

import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

String catId(String nameKey) =>
    const Uuid().v5(Namespace.url.value, 'qvas:$nameKey');

void main() {
  final rng = Random(20260815); // фіксований seed — відтворюваність

  // (категорія, мін₴, макс₴, можливі коментарі)
  final expensePool = <(String, int, int, List<String?>)>[
    ('cat.coffee', 45, 120, [null, null, 'з собою', 'лате з сиропом']),
    ('cat.groceries', 180, 2400, [null, 'Сільпо', 'АТБ', 'ринок, овочі']),
    ('cat.cafe', 250, 1400, [null, 'обід з колегами', 'піца', 'суші на двох']),
    ('cat.transport', 8, 350, [null, null, 'таксі додому', 'проїзний']),
    ('cat.car', 800, 2800, ['АЗС по дорозі', null, 'мийка']),
    ('cat.home', 120, 3500, [null, 'лампочки й дрібниці', 'нова подушка']),
    ('cat.utilities', 450, 3200, ['світло', 'вода + газ', 'інтернет']),
    ('cat.pharmacy', 85, 900, [null, 'вітаміни', 'краплі для носа']),
    ('cat.clothes', 600, 4500, [null, 'футболки', 'кросівки 🔥']),
    ('cat.gifts', 300, 2500, ['подарунок мамі', null, 'день народження Олі']),
    ('cat.entertainment', 150, 1200, ['кіно', null, 'настілки з друзями']),
    ('cat.phone', 200, 750, ['поповнення', null]),
    ('cat.sport', 400, 1600, ['абонемент', null, 'протеїн']),
    ('cat.education', 150, 8500, [null, 'курс англійської', 'книжки']),
    ('cat.other', 50, 700, [null, 'дрібниці', 'загубив, не памятаю що']),
  ];

  final incomePool = <(String, int, int, List<String?>)>[
    ('cat.salary', 38000, 52000, ['аванс', 'зарплата']),
    ('cat.freelance', 2500, 14000, ['проєкт на upwork', null, 'верстка лендінгу']),
    ('cat.cashback', 45, 420, [null, 'кешбек банку']),
    ('cat.refund', 120, 900, ['повернення за квитки', null]),
    ('cat.sale', 500, 3000, ['продав старий монітор', null]),
  ];

  final txs = <Map<String, Object?>>[];
  var n = 0;

  void addTx(String dateKey, (String, int, int, List<String?>) pool,
      String type, int hour) {
    final (key, lo, hi, notes) = pool;
    final uah = lo + rng.nextInt(hi - lo + 1);
    final note = notes[rng.nextInt(notes.length)];
    n++;
    txs.add({
      'id': 'demo-$dateKey-$n',
      'type': type,
      'amountMinor': uah * 100,
      'categoryId': catId(key),
      'currencyCode': 'UAH',
      'createdAtUtc':
          '${dateKey}T${hour.toString().padLeft(2, '0')}:${rng.nextInt(60).toString().padLeft(2, '0')}:00.000Z',
      'localDateKey': dateKey,
      'note': note,
    });
  }

  void fillMonth(int month, int lastDay) {
    for (var day = 1; day <= lastDay; day++) {
      // ~15% днів порожні — так реалістичніше
      if (rng.nextDouble() < 0.15) continue;
      final dateKey =
          '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final count = 1 + rng.nextInt(5); // 1–5 витрат на день
      for (var i = 0; i < count; i++) {
        addTx(dateKey, expensePool[rng.nextInt(expensePool.length)],
            'expense', 6 + rng.nextInt(15));
      }
      // Зарплата 5-го, аванс 20-го, зрідка інші доходи
      if (day == 5) addTx(dateKey, incomePool[0], 'income', 10);
      if (day == 20) addTx(dateKey, incomePool[0], 'income', 10);
      if (rng.nextDouble() < 0.12) {
        addTx(dateKey, incomePool[1 + rng.nextInt(incomePool.length - 1)],
            'income', 12 + rng.nextInt(8));
      }
    }
  }

  fillMonth(6, 30);
  fillMonth(7, 31);
  fillMonth(8, 12); // 13–15 серпня — реальні дані, не чіпаємо

  final backup = {
    'app': 'qvas',
    'schemaVersion': 1,
    'exportedAt': '2026-08-15T00:00:00.000Z',
    'settings': {'currencyCode': 'UAH', 'locale': null},
    'categories': <Object?>[],
    'transactions': txs,
  };

  // ignore: avoid_print — CLI-скрипт, print і є виводом
  print(const JsonEncoder.withIndent('  ').convert(backup));
}
