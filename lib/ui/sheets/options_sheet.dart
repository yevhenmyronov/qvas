import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../common/app_row.dart';

/// Вибір одного варіанта зі списку: заголовок, рядки, ✓ біля
/// поточного. Тап по рядку закриває шторку й повертає його значення.
///
/// Жив у налаштуваннях (мова), звідти винесений, коли той самий вибір
/// знадобився періоду Екрана 2 (рішення 102): два різні списки варіантів
/// у двох місцях застосунку розійшлися б.
class OptionsSheet<T> extends StatelessWidget {
  const OptionsSheet({
    super.key,
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<({T value, String label})> options;
  final T current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: Text(title, style: AppText.title),
        ),
        const SizedBox(height: 8),
        for (final o in options)
          AppRow(
            height: AppSize.rowCompact,
            onTap: () => Navigator.of(context).pop(o.value),
            child: Row(
              children: [
                Expanded(child: Text(o.label, style: AppText.body)),
                if (o.value == current)
                  const Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.accent,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
