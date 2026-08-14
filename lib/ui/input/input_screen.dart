import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../models/tx_type.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../history/history_screen.dart';
import 'amount_display.dart';
import 'category_bubbles.dart';
import 'numpad.dart';
import 'save_button.dart';
import 'type_switch.dart';

/// Екран 1 — Швидкий ввід. Розкладка статична, п'ять блоків зверху вниз
/// (Функціонал п.2.0). Ніякої навігації, заголовків і підказок: одна дія.
/// Вхід в історію — свайп угору.
class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final ctrl = ref.read(inputProvider.notifier);
    final snapshot = ref.read(inputProvider);

    // Одне з двох місць вібрації в застосунку (Функціонал п.2.6).
    HapticFeedback.mediumImpact();

    // Анімація і перехід стартують одразу; запис іде паралельно
    // (бюджет ≤100 мс, тех. спека п.6).
    final pending = ctrl.save();
    ctrl.reset();
    final navigator = Navigator.of(context);
    navigator.push(historyRoute(context));

    try {
      final id = await pending;
      ref.read(lastSavedTxIdProvider.notifier).state = id;
    } catch (_) {
      // Помилка запису: повертаємось на Екран 1 із відновленим станом.
      // Єдиний тост, дозволений на Екрані 1 (Функціонал п.2.5).
      navigator.popUntil((r) => r.isFirst);
      ctrl.restore(snapshot);
      if (context.mounted) {
        showAppToast(context, AppStrings.saveFailed);
      }
    }
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(historyRoute(context));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Малий екран (<680dp): зменшені розміри (Функціонал п.2.0).
    final small = MediaQuery.sizeOf(context).height < AppSize.smallScreenHeight;
    final amount = ref.watch(inputProvider.select((s) => s.amount));
    final isIncome = ref.watch(
        inputProvider.select((s) => s.type == TxType.income));
    final ctrl = ref.read(inputProvider.notifier);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -600) {
            _openHistory(context);
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
                    child: AmountDisplay(
                      amount: amount,
                      income: isIncome,
                      baseSize: small ? 48 : 64,
                    ),
                  ),
                ),
                CategoryBubbles(
                    height:
                        small ? AppSize.bubbleSmall : AppSize.bubble),
                const SizedBox(height: AppSpace.block),
                SaveButton(onSave: () => _save(context, ref)),
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
