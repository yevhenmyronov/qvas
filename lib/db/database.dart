import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../models/tx_type.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, AppSettings, CategoryRankingCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
          await _seedBuiltInCategories();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Часткові індекси з тех. спеки п.2.4 — м'яко видалені записи
  /// не роздувають індекс.
  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX idx_tx_date ON transactions(local_date_key) '
      'WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX idx_tx_type_date ON transactions(type, local_date_key) '
      'WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX idx_tx_category ON transactions(category_id) '
      'WHERE deleted_at IS NULL',
    );
  }

  Future<void> _seedBuiltInCategories() async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAll(categories, [
        for (final (i, c) in builtInExpenseCategories.indexed)
          _builtIn(c, TxType.expense, i, now),
        for (final (i, c) in builtInIncomeCategories.indexed)
          _builtIn(c, TxType.income, i, now),
      ]);
    });
  }

  CategoriesCompanion _builtIn(
    ({String nameKey, String emoji}) c,
    TxType type,
    int order,
    DateTime now,
  ) {
    return CategoriesCompanion.insert(
      id: builtInCategoryId(c.nameKey),
      type: type,
      nameKey: Value(c.nameKey),
      emoji: c.emoji,
      isBuiltIn: const Value(true),
      sortOrder: Value(order),
      createdAt: now,
    );
  }
}

/// Детермінований uuid v5 для вбудованої категорії: однаковий на всіх
/// установках, тож імпорт бекапу в режимі «додати» дедуплікується за id.
String builtInCategoryId(String nameKey) =>
    const Uuid().v5(Namespace.url.value, 'qvas:$nameKey');

/// Функціонал п.9.1. Порядок — це sortOrder.
const builtInExpenseCategories = <({String nameKey, String emoji})>[
  (nameKey: 'cat.coffee', emoji: '☕'),
  (nameKey: 'cat.groceries', emoji: '🛒'),
  (nameKey: 'cat.cafe', emoji: '🍽'),
  (nameKey: 'cat.transport', emoji: '🚌'),
  (nameKey: 'cat.car', emoji: '⛽'),
  (nameKey: 'cat.home', emoji: '🏠'),
  (nameKey: 'cat.utilities', emoji: '🧾'),
  (nameKey: 'cat.pharmacy', emoji: '💊'),
  (nameKey: 'cat.clothes', emoji: '👕'),
  (nameKey: 'cat.gifts', emoji: '🎁'),
  (nameKey: 'cat.entertainment', emoji: '🎬'),
  (nameKey: 'cat.phone', emoji: '📱'),
  (nameKey: 'cat.pets', emoji: '🐾'),
  (nameKey: 'cat.beauty', emoji: '💇'),
  (nameKey: 'cat.sport', emoji: '🏋'),
  (nameKey: 'cat.education', emoji: '📚'),
  (nameKey: 'cat.kids', emoji: '🧒'),
  (nameKey: 'cat.other', emoji: '🔧'),
];

/// Функціонал п.9.2.
const builtInIncomeCategories = <({String nameKey, String emoji})>[
  (nameKey: 'cat.salary', emoji: '💰'),
  (nameKey: 'cat.freelance', emoji: '💻'),
  (nameKey: 'cat.income_gift', emoji: '🎁'),
  (nameKey: 'cat.cashback', emoji: '💳'),
  (nameKey: 'cat.investments', emoji: '📈'),
  (nameKey: 'cat.refund', emoji: '🔄'),
  (nameKey: 'cat.sale', emoji: '🏷'),
  (nameKey: 'cat.income_other', emoji: '🔧'),
];

/// Стартові п'ятірки головного екрана до накопичення історії
/// (Функціонал п.9, «холодний старт» у п.2.4).
const defaultTopExpense = [
  'cat.coffee',
  'cat.groceries',
  'cat.cafe',
  'cat.transport',
  'cat.pharmacy',
];

const defaultTopIncome = [
  'cat.salary',
  'cat.freelance',
  'cat.cashback',
  'cat.income_gift',
  'cat.refund',
];
