import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/backup_service.dart';

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

final backupServiceProvider = Provider<BackupService>((ref) =>
    BackupService(ref.watch(databaseProvider),
        ref.watch(settingsRepositoryProvider)));

/// Живий рядок налаштувань (валюта, мова, хаптика, стан бекапу).
final settingsProvider = StreamProvider<AppSetting?>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

const _hapticsChannel = MethodChannel('qvas/haptics');

/// Вібрація з урахуванням перемикача «Хаптика» — використовується рівно
/// у двох місцях застосунку (Функціонал п.2.6).
///
/// Рішення 36: на Android — прямий виклик вібромотора через власний
/// канал (потребує VIBRATE), бо HapticFeedback.mediumImpact() глушиться
/// системним перемикачем «вібрація при дотику». На інших платформах —
/// стандартний шлях.
void hapticImpact(WidgetRef ref) {
  if (!(ref.read(settingsProvider).value?.hapticsEnabled ?? true)) return;
  if (defaultTargetPlatform == TargetPlatform.android) {
    _hapticsChannel.invokeMethod<void>('impact');
  } else {
    HapticFeedback.mediumImpact();
  }
}

/// Ініціалізація при старті: рядок налаштувань + фонове прибирання м'яко
/// видалених. Свідомо не await-иться перед першим кадром — пад малюється
/// одразу (бюджет продуктивності, тех. спека п.6).
final startupProvider = FutureProvider<void>((ref) async {
  await ref.read(settingsRepositoryProvider).ensureInitialized();
  final transactions = ref.read(transactionRepositoryProvider);
  await transactions.purgeDeleted();
  // ТИМЧАСОВО: чистка демо-даних догфудингу. Прибрати разом із
  // [TransactionRepository.softDeleteDemoSeed], щойно відпрацює на
  // робочому пристрої. Повторні запуски — порожня операція.
  await transactions.softDeleteDemoSeed();
});
