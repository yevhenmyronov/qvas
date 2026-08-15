import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../common/app_icon_button.dart';

Route<void> instructionRoute() {
  return MaterialPageRoute<void>(builder: (_) => const InstructionScreen());
}

/// «Як користуватися» (рішення 51): розділ створено наперед, сама
/// інструкція буде написана пізніше — поки що порожній стан.
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
              child: Center(
                child: Text(l.instructionSoon, style: AppText.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
