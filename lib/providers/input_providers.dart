import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/amount_input.dart';
import '../models/tx_type.dart';
import 'category_providers.dart';
import 'core_providers.dart';
import 'locale_providers.dart';

/// Стан Екрана 1: сума (з виразом калькулятора), тип, обрана категорія.
class InputState {
  const InputState({
    this.amount = AmountInput.empty,
    this.type = TxType.expense,
    this.categoryId,
  });

  final AmountInput amount;
  final TxType type;
  final String? categoryId;

  /// Обидві умови кнопки «Зберегти» (Функціонал п.2.5).
  bool get canSave => amount.resolvedAmount > 0 && categoryId != null;

  InputState copyWith({
    AmountInput? amount,
    TxType? type,
    String? Function()? categoryId,
  }) {
    return InputState(
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
    );
  }
}

class InputController extends Notifier<InputState> {
  @override
  InputState build() {
    // Вибрана категорія може зникнути під ногами: рішення 49 дозволяє
    // видаляти категорії без записів, а знімок вводу (Функціонал п.11)
    // взагалі переживає смерть процесу й може принести id, видалений
    // у минулій сесії. Тоді бульбашка не показується, але categoryId
    // не null — «Зберегти» лишається активною, а insert падає на
    // зовнішньому ключі. Один слухач замість перевірок у кожному місці
    // видалення.
    ref.listen(categoriesByIdProvider, (_, next) => _dropMissingCategory(
        next.value));
    return const InputState();
  }

  void _dropMissingCategory(Map<String, Category>? categories) {
    final id = state.categoryId;
    // categories == null — список ще вантажиться; це не «категорії немає».
    if (id == null || categories == null) return;
    if (!categories.containsKey(id)) {
      state = state.copyWith(categoryId: () => null);
    }
  }

  /// Уся клавіатурна логіка живе в AmountInput; пад віддає готовий стан.
  void setAmount(AmountInput amount) =>
      state = state.copyWith(amount: amount);

  /// Перемикання «Витрата / Дохід»: сума й вираз зберігаються, скидається
  /// лише категорія (Функціонал п.2.1).
  void toggleType() => state = state.copyWith(
        type: state.type == TxType.expense ? TxType.income : TxType.expense,
        categoryId: () => null,
      );

  /// Тап по бульбашці; повторний тап по вибраній — знімає вибір.
  void selectCategory(String id) => state = state.copyWith(
        categoryId: () => state.categoryId == id ? null : id,
      );

  /// Вибір зі шторки «Всі категорії» — завжди встановлює, без тоглу.
  void setCategory(String id) =>
      state = state.copyWith(categoryId: () => id);

  void restore(InputState snapshot) {
    state = snapshot;
    // Слухач реагує лише на ЗМІНУ списку категорій, а знімок приїжджає,
    // коли список уже прочитано — тут перевіряємо явно.
    _dropMissingCategory(ref.read(categoriesByIdProvider).value);
  }

  void reset() => state = const InputState();

  /// Записує транзакцію. Викликається тільки при canSave.
  /// Незавершений вираз обчислюється автоматично; валюта фіксується
  /// в момент запису (Функціонал п.5).
  ///
  /// id виставляється в [lastSavedTxIdProvider] СИНХРОННО, до запису:
  /// стрічка може оновитись раніше, ніж завершиться await, і рядок має
  /// вже знати, що він новий (підсвічування, Функціонал п.4.6).
  Future<String> save() {
    assert(state.canSave);
    final s = state;
    final id = const Uuid().v4();
    ref.read(lastSavedTxIdProvider.notifier).state = id;
    return ref.read(transactionRepositoryProvider).insert(
          id: id,
          type: s.type,
          amountMinor: s.amount.resolvedAmount * 100,
          categoryId: s.categoryId!,
          currencyCode: ref.read(currencyCodeProvider),
        );
  }
}

final inputProvider =
    NotifierProvider<InputController, InputState>(InputController.new);

/// id щойно збереженої транзакції — для м'ятного підсвічування нового рядка
/// на Екрані 2 (Функціонал п.4.6). Одноразовий: рядок споживає й гасить.
final lastSavedTxIdProvider = StateProvider<String?>((ref) => null);
