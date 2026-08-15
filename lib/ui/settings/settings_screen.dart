import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../providers/core_providers.dart';
import '../../providers/locale_providers.dart';
import '../../services/backup.dart';
import '../../theme/tokens.dart';
import '../common/app_toast.dart';
import '../common/pressable.dart';
import '../sheets/currency_sheet.dart';
import 'instruction_screen.dart';
import 'manage_categories_screen.dart';

/// Синхронізується з pubspec.yaml вручну — package_info тягнув би
/// зайвий плагін заради одного рядка.
const appVersion = '0.2.8';

Route<void> settingsRoute() {
  return MaterialPageRoute<void>(builder: (_) => const SettingsScreen());
}

/// Налаштування (Функціонал п.10, Екрани п.6): один короткий екран.
/// Іконок біля пунктів немає, групи розділені відступом. v0.2 — без
/// біометрії та пунктів billing (v0.3 пропущено рішенням користувача).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final current = ref.read(currencyCodeProvider);
    final picked = await showCurrencySheet(context,
        current: current, fromSettings: true);
    if (picked != null) {
      await ref.read(settingsRepositoryProvider).setCurrency(picked);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final current =
        ref.read(settingsProvider).value?.localeOverride;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => _OptionsSheet(
        title: l.language,
        options: [
          (value: 'system', label: l.languageSystem),
          (value: 'uk', label: 'Українська'),
          (value: 'en', label: 'English'),
        ],
        current: current ?? 'system',
      ),
    );
    if (picked != null) {
      await ref
          .read(settingsRepositoryProvider)
          .setLocaleOverride(picked == 'system' ? null : picked);
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final service = ref.read(backupServiceProvider);
    ParsedBackup? backup;
    try {
      backup = await service.pickBackup();
    } on FormatException {
      if (context.mounted) showAppToast(context, l.importInvalid);
      return;
    }
    if (backup == null || !context.mounted) return;

    final period = backup.period;
    // Підтвердження з підрахунком (Функціонал п.7.2, Екрани п.6.2):
    // «Замінити» — червона, бо дія рівносильна видаленню поточних даних.
    final replace = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => _ImportConfirmSheet(
        info: l.importInfo(
            backup!.count, period?.from ?? '—', period?.to ?? '—'),
      ),
    );
    if (replace == null) return;
    await service.applyImport(backup, replace: replace);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider).value;
    final currency = ref.watch(currencyCodeProvider);
    final localeTag = ref.watch(localeTagProvider);
    final backupService = ref.read(backupServiceProvider);

    final languageLabel = switch (settings?.localeOverride) {
      'uk' => 'Українська',
      'en' => 'English',
      _ => l.languageSystem,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                Text(l.settingsTitle, style: AppText.title),
              ],
            ),
            const SizedBox(height: AppSpace.side),
            _Row(
              label: l.currencyTitle,
              value: currencySymbolOf(currency, localeTag),
              onTap: () => _pickCurrency(context, ref),
            ),
            _Row(
              label: l.language,
              value: languageLabel,
              onTap: () => _pickLanguage(context, ref),
            ),
            _SwitchRow(
              label: l.haptics,
              value: settings?.hapticsEnabled ?? true,
              onChanged: (v) => ref
                  .read(settingsRepositoryProvider)
                  .setHapticsEnabled(v),
            ),
            const SizedBox(height: AppSpace.block),
            _Row(
              label: l.saveBackup,
              onTap: backupService.exportJson,
            ),
            _Row(
              label: l.exportCsv,
              onTap: () {
                final loc = context.l10n;
                backupService
                    .exportCsv((c) => categoryDisplayName(loc, c));
              },
            ),
            _Row(
              label: l.restoreBackup,
              onTap: () => _restoreBackup(context, ref),
            ),
            const SizedBox(height: AppSpace.block),
            _Row(
              label: l.manageCategories,
              onTap: () => Navigator.of(context)
                  .push(manageCategoriesRoute()),
            ),
            const SizedBox(height: AppSpace.block),
            // «Як користуватися» (рішення 51): розділ існує наперед,
            // текст інструкції буде написаний окремо.
            _Row(
              label: l.howToUse,
              onTap: () =>
                  Navigator.of(context).push(instructionRoute()),
            ),
            const SizedBox(height: AppSpace.block),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.side, vertical: 16),
              child: Text(l.aboutApp(appVersion), style: AppText.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// Рядок списку (компонент 0.5): висота 56, без роздільників,
/// натиснутий стан — фон і scale(0.98).
class _Row extends StatelessWidget {
  const _Row({required this.label, this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      builder: (context, pressed) => Container(
        height: 56,
        color: pressed ? AppColors.bgSurface : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body)),
            if (value != null) ...[
              Text(value!, style: AppText.caption),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<({String value, String label})> options;
  final String current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurfaceHigh,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpace.side),
              child: Text(title, style: AppText.title),
            ),
            const SizedBox(height: 8),
            for (final o in options)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(o.value),
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.side),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(o.label, style: AppText.body)),
                        if (o.value == current)
                          const Icon(Icons.check,
                              size: 20, color: AppColors.accent),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Підтвердження імпорту: «Замінити» — червона (рівносильна видаленню),
/// «Додати» — акцентна. Єдине місце, крім видалення, де червоний
/// з'являється на кнопці (Екрани п.6.2).
class _ImportConfirmSheet extends StatelessWidget {
  const _ImportConfirmSheet({required this.info});

  final String info;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurfaceHigh,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.side),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(info, style: AppText.body),
              const SizedBox(height: AppSpace.side),
              Row(
                children: [
                  Expanded(
                    child: _ConfirmButton(
                      label: l.importReplace,
                      color: AppColors.danger,
                      textColor: AppColors.textOnDanger,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ConfirmButton(
                      label: l.importAdd,
                      color: AppColors.accent,
                      textColor: AppColors.onAccent,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      builder: (context, pressed) => Container(
        height: AppSize.saveButton,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppText.bodyStrong.copyWith(color: textColor)),
      ),
    );
  }
}
