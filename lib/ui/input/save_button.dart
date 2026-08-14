import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../providers/input_providers.dart';
import '../../theme/tokens.dart';
import '../common/pressable.dart';

/// Кнопка «Зберегти» — велика, явна, підписана словом, над падом
/// (Функціонал п.2.5, рішення 14). Присутня в розкладці завжди;
/// неактивна — приглушена, натискання ігнорується.
class SaveButton extends ConsumerWidget {
  const SaveButton({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave = ref.watch(inputProvider.select((s) => s.canSave));

    return Pressable(
      enabled: canSave,
      onTap: onSave,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.standard),
        curve: AppCurves.standard,
        height: AppSize.saveButton,
        width: double.infinity,
        decoration: BoxDecoration(
          color: canSave
              ? (pressed ? AppColors.accentPressed : AppColors.accent)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.save,
          style: AppText.bodyStrong.copyWith(
            color: canSave ? AppColors.onAccent : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
