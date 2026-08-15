import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../providers/core_providers.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_button.dart';
import '../common/sheet_scaled.dart';
import '../sheets/currency_sheet.dart';

/// Онбординг (Функціонал п.8, Екрани п.5): один екран, не більше
/// 5 секунд. Підтверджується ТІЛЬКИ валюта — селектора мови немає
/// навмисно: екран уже написаний обраною мовою й показує себе сам.
/// Логотип — назва шрифтом, без картинки.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _changeCurrency(BuildContext context, WidgetRef ref) async {
    final picked = await showCurrencySheet(
      context,
      current: ref.read(currencyCodeProvider),
    );
    if (picked != null) {
      await ref.read(settingsRepositoryProvider).setCurrency(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final symbol = currencySymbolOf(
      ref.watch(currencyCodeProvider),
      ref.watch(localeTagProvider),
    );

    return Scaffold(
      body: SheetScaled(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                'QVAS',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.onboardingTagline,
                style: AppText.body.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(flex: 2),
              Text(l.onboardingCurrency(symbol), style: AppText.bodyStrong),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _changeCurrency(context, ref),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    l.change,
                    style: AppText.caption.copyWith(color: AppColors.accent),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              AppButton(
                label: l.start,
                onTap: () =>
                    ref.read(settingsRepositoryProvider).setOnboardingDone(),
              ),
              const SizedBox(height: AppSpace.block),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
