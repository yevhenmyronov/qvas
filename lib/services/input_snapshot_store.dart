import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/amount_input.dart';
import '../models/tx_type.dart';
import '../providers/input_providers.dart';

/// Збереження стану вводу при згортанні (Функціонал п.11): якщо застосунок
/// повернули протягом 10 хвилин — сума, незавершений вираз, тип і категорія
/// відновлюються; далі стан скидається. Серіалізується вся структура
/// AmountInput, а не лише підсумкова сума (тех. спека п.12).
class InputSnapshotStore {
  static const maxAge = Duration(minutes: 10);

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}input_snapshot.json');
  }

  Future<void> write(InputState state) async {
    final f = await _file();
    await f.writeAsString(jsonEncode({
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'amount': state.amount.toJson(),
      'type': state.type.name,
      'categoryId': state.categoryId,
    }));
  }

  Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }

  /// Повертає стан, якщо знімок свіжіший за 10 хвилин; інакше null
  /// (застарілий знімок видаляється).
  Future<InputState?> readFresh() async {
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final json = jsonDecode(await f.readAsString()) as Map<String, Object?>;
      final savedAt = DateTime.parse(json['savedAt'] as String);
      if (DateTime.now().toUtc().difference(savedAt) > maxAge) {
        await f.delete();
        return null;
      }
      return InputState(
        amount:
            AmountInput.fromJson(json['amount'] as Map<String, Object?>),
        type: TxType.values
            .firstWhere((t) => t.name == json['type'] as String?),
        categoryId: json['categoryId'] as String?,
      );
    } catch (_) {
      // Пошкоджений знімок ніколи не має ламати запуск.
      return null;
    }
  }
}
