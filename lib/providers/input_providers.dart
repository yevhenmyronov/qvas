import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/amount_input.dart';
import '../models/note_suggestions.dart';
import '../models/tx_type.dart';
import 'category_providers.dart';
import 'core_providers.dart';
import 'locale_providers.dart';

/// Стан Екрана 1: сума (з виразом калькулятора), тип, обрана категорія,
/// коментар (Функціонал п.2.7).
class InputState {
  const InputState({
    this.amount = AmountInput.empty,
    this.type = TxType.expense,
    this.categoryId,
    this.note = '',
  });

  final AmountInput amount;
  final TxType type;
  final String? categoryId;

  /// Коментар як набраний; порожній — коментаря немає. Обрізається лише
  /// при записі, щоб пробіл у кінці не зникав посеред набору.
  final String note;

  /// Обидві умови кнопки «Зберегти» (Функціонал п.2.5). Коментар на них
  /// не впливає ніколи: він не є частиною шляху «сума → категорія».
  bool get canSave => amount.resolvedAmount > 0 && categoryId != null;

  InputState copyWith({
    AmountInput? amount,
    TxType? type,
    String? Function()? categoryId,
    String? note,
  }) {
    return InputState(
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      note: note ?? this.note,
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

  void setNote(String text) => state = state.copyWith(note: text);

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

/// Підказки коментарів для обраної категорії (Функціонал п.2.7): те, що
/// людина вже писала в цій категорії щонайменше двічі, частіше — першим.
///
/// Ключ — тільки категорія. Експеримент рішення 48 звіряв ще й суму, і
/// підказка з'являлась лише на точному повторі покупки; а коментар
/// повторюється не з сумою, а з місцем і приводом — «обід» буває за
/// різні гроші. Валюта з ключа випала разом із рішенням 57.
///
/// Перезапитується тільки при зміні категорії — не на кожну літеру.
final noteSuggestionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final categoryId = ref.watch(inputProvider.select((s) => s.categoryId));
  if (categoryId == null) return const [];
  final rows = await ref
      .watch(transactionRepositoryProvider)
      .recentNotesFor(categoryId);
  return rankNotes(rows);
});
