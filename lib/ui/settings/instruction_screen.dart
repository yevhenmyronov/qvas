import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

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
                Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  builder: (context, pressed) => const SizedBox(
                    width: AppSize.minTouch,
                    height: AppSize.minTouch,
                    child: Icon(Icons.chevron_left,
                        size: 24, color: AppColors.textSecondary),
                  ),
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
