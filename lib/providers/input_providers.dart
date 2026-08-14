import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/amount_input.dart';
import '../models/note_suggestions.dart';
import '../models/tx_type.dart';
import 'core_providers.dart';
import 'locale_providers.dart';

/// Стан Екрана 1: сума (з виразом калькулятора), тип, обрана категорія,
/// нотатка (Функціонал п.2.7).
class InputState {
  const InputState({
    this.amount = AmountInput.empty,
    this.type = TxType.expense,
    this.categoryId,
    this.note = '',
    this.noteFromSuggestion = false,
  });

  final AmountInput amount;
  final TxType type;
  final String? categoryId;

  /// Текст нотатки; порожній — нотатки немає.
  final String note;

  /// Нотатка поставлена тапом по чіпу-підказці, а не набрана вручну.
  /// Ручний набір ховає чіпи (людина вже зробила вибір), вибір чіпом — ні.
  final bool noteFromSuggestion;

  /// Обидві умови кнопки «Зберегти» (Функціонал п.2.5). Нотатка на них
  /// не впливає ніколи.
  bool get canSave => amount.resolvedAmount > 0 && categoryId != null;

  InputState copyWith({
    AmountInput? amount,
    TxType? type,
    String? Function()? categoryId,
    String? note,
    bool? noteFromSuggestion,
  }) {
    return InputState(
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      note: note ?? this.note,
      noteFromSuggestion: noteFromSuggestion ?? this.noteFromSuggestion,
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

  /// Ручний ввід нотатки з поля.
  void setNote(String text) =>
      state = state.copyWith(note: text, noteFromSuggestion: false);

  /// Тап по чіпу-підказці; повторний тап по обраному — знімає.
  void toggleSuggestedNote(String text) =>
      state = (state.note == text && state.noteFromSuggestion)
          ? state.copyWith(note: '', noteFromSuggestion: false)
          : state.copyWith(note: text, noteFromSuggestion: true);

  void restore(InputState snapshot) => state = snapshot;

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
    final note = s.note.trim();
    ref.read(lastSavedTxIdProvider.notifier).state = id;
    return ref.read(transactionRepositoryProvider).insert(
          id: id,
          type: s.type,
          amountMinor: s.amount.resolvedAmount * 100,
          categoryId: s.categoryId!,
          currencyCode: ref.read(currencyCodeProvider),
          note: note.isEmpty ? null : note,
        );
  }
}

final inputProvider =
    NotifierProvider<InputController, InputState>(InputController.new);

/// id щойно збереженої транзакції — для м'ятного підсвічування нового рядка
/// на Екрані 2 (Функціонал п.4.6). Одноразовий: рядок споживає й гасить.
final lastSavedTxIdProvider = StateProvider<String?>((ref) => null);

/// Підказки нотаток (Функціонал п.2.7): до двох нотаток, що повторювались
/// щонайменше тричі для поточної комбінації сума+категорія+валюта.
/// Перезапитується тільки при зміні суми чи категорії — не при наборі
/// тексту нотатки.
final noteSuggestionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final (amountMajor, categoryId) = ref.watch(
      inputProvider.select((s) => (s.amount.resolvedAmount, s.categoryId)));
  if (categoryId == null || amountMajor <= 0) return const [];
  final rows = await ref.watch(transactionRepositoryProvider).notesFor(
        categoryId: categoryId,
        amountMinor: amountMajor * 100,
        currencyCode: ref.watch(currencyCodeProvider),
      );
  return rankNotes(rows, minCount: 3, limit: 2);
});
