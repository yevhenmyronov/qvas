import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/tx_type.dart';
import '../../providers/core_providers.dart';
import '../../providers/input_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../history/history_screen.dart';
import 'amount_display.dart';
import 'category_bubbles.dart';
import 'note_field.dart';
import 'numpad.dart';
import 'save_button.dart';
import 'type_switch.dart';

/// Екран 1 — Швидкий ввід. Розкладка статична, п'ять блоків зверху вниз
/// (Функціонал п.2.0). Ніякої навігації, заголовків і підказок: одна дія.
/// Вхід в історію — свайп угору.
class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen>
    with SingleTickerProviderStateMixin {
  /// Анімація збереження (DS п.5.5): сума «згортається» вниз і гасне,
  /// поки Екран 2 наїжджає знизу, підхоплюючи рух.
  late final AnimationController _collapse = AnimationController(
    vsync: this,
    duration: AppDurations.sheet,
  );

  @override
  void dispose() {
    _collapse.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ctrl = ref.read(inputProvider.notifier);
    final snapshot = ref.read(inputProvider);

    // Одне з двох місць вібрації в застосунку (Функціонал п.2.6);
    // поважає перемикач «Хаптика» в налаштуваннях.
    hapticImpact(ref);

    // Анімація і перехід стартують одразу; запис іде паралельно
    // (бюджет ≤100 мс, тех. спека п.6).
    final pending = ctrl.save();
    final navigator = Navigator.of(context);
    _collapse.forward(from: 0);
    navigator.push(historyRoute(context));

    // Стан скидається, коли Екран 2 уже повністю накрив ввід.
    Future.delayed(AppDurations.of(context, AppDurations.sheet), () {
      if (!mounted) return;
      ctrl.reset();
      _collapse.reset();
    });

    try {
      // id для підсвічування вже виставлений синхронно в save().
      await pending;
    } catch (_) {
      // Помилка запису: повертаємось на Екран 1 із відновленим станом.
      // Єдиний тост, дозволений на Екрані 1 (Функціонал п.2.5).
      ref.read(lastSavedTxIdProvider.notifier).state = null;
      navigator.popUntil((r) => r.isFirst);
      ctrl.restore(snapshot);
      _collapse.reset();
      if (mounted) {
        showAppToast(context, context.l10n.saveFailed);
      }
    }
  }

  void _openHistory() {
    Navigator.of(context).push(historyRoute(context));
  }

  @override
  Widget build(BuildContext context) {
    // Малий екран (<680dp): зменшені розміри (Функціонал п.2.0).
    final small =
        MediaQuery.sizeOf(context).height < AppSize.smallScreenHeight;
    final amount = ref.watch(inputProvider.select((s) => s.amount));
    final isIncome =
        ref.watch(inputProvider.select((s) => s.type == TxType.income));
    final ctrl = ref.read(inputProvider.notifier);

    return Scaffold(
      // Клавіатура нотатки накриває пад, не стискаючи розкладку: пад у
      // момент набору тексту не потрібен, а Column зі стисканням би
      // переповнився (Функціонал п.2.7).
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -600) {
            _openHistory();
          }
        },
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpace.side),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const TypeSwitch(),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _collapse,
                      builder: (context, child) {
                        final t = AppCurves.standard
                            .transform(_collapse.value);
                        return Transform.translate(
                          offset: Offset(0, 120 * t),
                          child: Opacity(
                            opacity: 1 - t,
                            child: child,
                          ),
                        );
                      },
                      child: AmountDisplay(
                        amount: amount,
                        format: ref.watch(moneyFormatProvider),
                        income: isIncome,
                        baseSize: small ? 48 : 64,
                      ),
                    ),
                  ),
                ),
                CategoryBubbles(
                    height: small ? AppSize.bubbleSmall : AppSize.bubble),
                const SizedBox(height: 12),
                const NoteField(),
                const SizedBox(height: 12),
                SaveButton(onSave: _save),
                const SizedBox(height: AppSpace.side),
                Numpad(
                  value: amount,
                  onChanged: ctrl.setAmount,
                  cellHeight:
                      small ? AppSize.padCellSmall : AppSize.padCell,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
