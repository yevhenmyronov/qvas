import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/amount_input.dart';
import '../models/format.dart';
import '../models/tx_type.dart';
import 'core_providers.dart';

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
  InputState build() => const InputState();

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

  void restore(InputState snapshot) => state = snapshot;

  void reset() => state = const InputState();

  /// Записує транзакцію. Викликається тільки при canSave.
  /// Незавершений вираз обчислюється автоматично.
  Future<String> save() {
    assert(state.canSave);
    final s = state;
    return ref.read(transactionRepositoryProvider).insert(
          type: s.type,
          amountMinor: s.amount.resolvedAmount * 100,
          categoryId: s.categoryId!,
          currencyCode: kCurrencyCode,
        );
  }
}

final inputProvider =
    NotifierProvider<InputController, InputState>(InputController.new);

/// id щойно збереженої транзакції — для м'ятного підсвічування нового рядка
/// на Екрані 2 (Функціонал п.4.6). Одноразовий: рядок споживає й гасить.
final lastSavedTxIdProvider = StateProvider<String?>((ref) => null);
