import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/db/database.dart';
import 'package:qvas/models/tx_type.dart';
import 'package:qvas/repositories/transaction_repository.dart';

/// «Видалити всі записи» (рішення 103): записи зникають цілком, разом із
/// кошиком м'якого видалення, а категорії лишаються.
void main() {
  late AppDatabase db;
  late TransactionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TransactionRepository(db);
  });

  tearDown(() => db.close());

  Future<String> add() => repo.insert(
        type: TxType.expense,
        amountMinor: 4500,
        categoryId:
            builtInCategoryId(builtInExpenseCategories.first.nameKey),
        currencyCode: 'UAH',
      );

  test('стирає живі й м\'яко видалені записи, категорії лишає', () async {
    await add();
    await add();
    await repo.softDelete(await add());
    final categoriesBefore = await db.select(db.categories).get();

    await repo.deleteAll();

    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await repo.liveCount(), 0);
    expect(await db.select(db.categories).get(), categoriesBefore);
  });

  test('скидає кеш Smart Categories', () async {
    await add();
    await db.into(db.categoryRankingCache).insert(
          CategoryRankingCacheCompanion.insert(
            type: TxType.expense,
            position: 0,
            categoryId:
                builtInCategoryId(builtInExpenseCategories.first.nameKey),
            rank: 1,
            computedOn: '2026-10-10',
          ),
        );

    await repo.deleteAll();

    expect(await db.select(db.categoryRankingCache).get(), isEmpty);
  });
}
