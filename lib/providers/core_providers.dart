import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'qvas'));
  ref.onDispose(db.close);
  return db;
});

final transactionRepositoryProvider = Provider<TransactionRepository>(
    (ref) => TransactionRepository(ref.watch(databaseProvider)));

final categoryRepositoryProvider = Provider<CategoryRepository>(
    (ref) => CategoryRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => SettingsRepository(ref.watch(databaseProvider)));

/// Ініціалізація при старті: рядок налаштувань + фонове прибирання м'яко
/// видалених. Свідомо не await-иться перед першим кадром — пад малюється
/// одразу (бюджет продуктивності, тех. спека п.6).
final startupProvider = FutureProvider<void>((ref) async {
  await ref.read(settingsRepositoryProvider).ensureInitialized();
  await ref.read(transactionRepositoryProvider).purgeDeleted();
});
