import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/tx_type.dart';
import 'core_providers.dart';

/// Неархівовані категорії типу.
final activeCategoriesProvider =
    StreamProvider.family<List<Category>, TxType>((ref, type) {
  return ref.watch(categoryRepositoryProvider).watchActive(type);
});

/// Усі категорії за id — для стрічки (архівовані теж показуються коректно).
final categoriesByIdProvider = StreamProvider<Map<String, Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllById();
});

/// П'ять бульбашок головного екрана. Фаза 1: передвизначений набір
/// «холодного старту» (Функціонал п.9). Фаза 4 замінить нутрощі на
/// Smart Categories з кешем і гістерезисом — інтерфейс провайдера лишиться.
final topCategoriesProvider =
    Provider.family<List<Category>, TxType>((ref, type) {
  final all = ref.watch(activeCategoriesProvider(type)).value ?? const [];
  final defaults =
      type == TxType.expense ? defaultTopExpense : defaultTopIncome;
  final byKey = {for (final c in all) c.nameKey: c};
  return [
    for (final key in defaults)
      if (byKey[key] != null) byKey[key]!,
  ];
});
