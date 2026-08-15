import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../providers/input_providers.dart';
import '../common/app_button.dart';

/// Кнопка «Зберегти» — велика, явна, підписана словом, над падом
/// (Функціонал п.2.5, рішення 14). Присутня в розкладці завжди;
/// неактивна — приглушена, натискання ігнорується.
class SaveButton extends ConsumerWidget {
  const SaveButton({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave = ref.watch(inputProvider.select((s) => s.canSave));

    return AppButton(label: context.l10n.save, enabled: canSave, onTap: onSave);
  }
}
