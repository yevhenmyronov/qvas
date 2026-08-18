import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../common/app_icon_button.dart';

Route<void> instructionRoute() {
  return MaterialPageRoute<void>(builder: (_) => const InstructionScreen());
}

/// «Як користуватися» (рішення 51, наповнено рішенням 91).
///
/// **Це довідка, а не навчання.** Інструкцію не читають до того, як
/// виникло питання — тому навчають підказки в момент, коли жест стає
/// доречним (рішення 89), а цей екран відповідає тому, хто вже прийшов
/// із питанням. Звідси форма: список жестів, а не суцільний текст.
///
/// Кожен рядок — «що зробити → що станеться», одним реченням. Порядок
/// повторює порядок екранів застосунку, щоб шукати можна було за
/// пам'яттю про те, де саме ти застряг.
class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconButton(
                  icon: Icons.chevron_left,
                  semanticLabel:
                      MaterialLocalizations.of(context).backButtonTooltip,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Text(l.howToUse, style: AppText.title),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.side,
                  8,
                  AppSpace.side,
                  AppSpace.block,
                ),
                children: [
                  _Section(l.howtoSectionInput),
                  _Item(l.howtoAmount),
                  _Item(l.howtoClear),
                  _Item(l.howtoCalc),
                  _Item(l.howtoType),
                  _Item(l.howtoMore),
                  _Item(l.howtoSwipeUp),
                  _Section(l.howtoSectionHistory),
                  _Item(l.howtoEdit),
                  _Item(l.howtoDelete),
                  _Item(l.howtoFilter),
                  _Item(l.howtoBreakdown),
                  _Item(l.howtoMonths),
                  _Section(l.howtoSectionData),
                  _Item(l.howtoLocal),
                  _Item(l.howtoBackup),
                  _Item(l.howtoArchive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.block, bottom: 4),
      child: Text(title, style: AppText.caption),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: AppText.body),
    );
  }
}
