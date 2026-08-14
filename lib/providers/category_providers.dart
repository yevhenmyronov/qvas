import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/dates.dart';
import '../models/smart_categories.dart';
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

/// Склад п'яти слотів Smart Categories (Функціонал п.2.4, тех. спека п.4).
///
/// Кеш перераховується раз на добу — якщо computedOn == сьогодні, читається
/// готовий склад без агрегації. FutureProvider навмисно НЕ стежить за
/// стрімами: у межах сесії порядок не змінюється ніколи, навіть після
/// збереження транзакції — м'язова пам'ять важливіша за свіжість.
final smartSlotsProvider =
    FutureProvider.family<List<String>, TxType>((ref, type) async {
  final catRepo = ref.watch(categoryRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);

  final now = DateTime.now();
  final today = localDateKeyOf(now);

  final cached = await catRepo.readRankingCache(type);
  if (cached != null && cached.computedOn == today) return cached.ids;

  final active = await catRepo.getActiveOnce(type);
  final activeIds = [for (final c in active) c.id];
  final pinnedIds = [
    for (final c in active)
      if (c.isPinned) c.id,
  ];

  final since = localDateKeyOf(now.subtract(const Duration(days: 30)));
  final ranks = await txRepo.rankSince(type, since);

  List<String> slots;
  if (cached == null && ranks.isEmpty && pinnedIds.isEmpty) {
    // Холодний старт із нульовою історією — передвизначений набір
    // (Функціонал п.9), а не перші за sortOrder.
    final defaults =
        type == TxType.expense ? defaultTopExpense : defaultTopIncome;
    final byKey = {for (final c in active) c.nameKey: c};
    slots = [
      for (final key in defaults)
        if (byKey[key] != null) byKey[key]!.id,
    ];
  } else {
    slots = computeSmartSlots(
      ranks: ranks,
      pinnedIds: pinnedIds,
      previousSlots: cached?.ids ?? const [],
      activeIds: activeIds,
    );
  }

  await catRepo.writeRankingCache(
    type,
    slots,
    {for (final r in ranks) r.categoryId: r.rank},
    today,
  );
  return slots;
});

/// П'ять бульбашок головного екрана: слоти Smart Categories, зіставлені
/// з живим списком категорій (архівована зникає одразу, порядок решти
/// не рухається). Поки слоти не обчислені — перші п'ять за sortOrder,
/// щоб перший кадр не був порожнім.
final topCategoriesProvider =
    Provider.family<List<Category>, TxType>((ref, type) {
  final all = ref.watch(activeCategoriesProvider(type)).value ?? const [];
  if (all.isEmpty) return const [];
  final byId = {for (final c in all) c.id: c};

  final slots = ref.watch(smartSlotsProvider(type)).value;
  if (slots == null) return all.take(kSlotCount).toList();

  final result = [
    for (final id in slots)
      if (byId[id] != null) byId[id]!,
  ];
  // Якщо щось заархівували в сесії — дозаповнюємо хвіст, не рухаючи решту.
  for (final c in all) {
    if (result.length >= kSlotCount) break;
    if (!result.contains(c)) result.add(c);
  }
  return result.take(kSlotCount).toList();
});
