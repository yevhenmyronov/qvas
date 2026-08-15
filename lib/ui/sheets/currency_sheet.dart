import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/currency.dart';
import '../../providers/locale_providers.dart';
import '../../theme/tokens.dart';
import '../common/app_sheet.dart';

/// Шторка вибору валюти (Функціонал п.8.1). Один компонент на два місця:
/// онбординг і налаштування. Згори — 6 найпоширеніших, нижче — повний
/// список ISO 4217 із пошуком по коду й назві. Список вшитий, ніяких
/// запитів і курсів.
Future<String?> showCurrencySheet(
  BuildContext context, {
  required String current,
  bool fromSettings = false,
}) {
  return showAppSheet<String>(
    context,
    heightFactor: 0.7,
    builder: (_) =>
        _CurrencySheet(current: current, fromSettings: fromSettings),
  );
}

class _CurrencySheet extends ConsumerStatefulWidget {
  const _CurrencySheet({required this.current, required this.fromSettings});

  final String current;
  final bool fromSettings;

  @override
  ConsumerState<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends ConsumerState<_CurrencySheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final localeTag = ref.watch(localeTagProvider);
    final q = _query.trim().toLowerCase();

    final List<CurrencyInfo> visible;
    if (q.isEmpty) {
      // 6 популярних згори, далі решта за кодом.
      final common = [
        for (final code in commonCurrencies)
          allCurrencies.firstWhere((c) => c.code == code),
      ];
      visible = [
        ...common,
        ...allCurrencies.where((c) => !commonCurrencies.contains(c.code)),
      ];
    } else {
      visible = [
        for (final c in allCurrencies)
          if (c.code.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q))
            c,
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: Text(context.l10n.currencyTitle, style: AppText.title),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.side,
            0,
            AppSpace.side,
            8,
          ),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: AppText.body,
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: context.l10n.search,
              hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, i) {
              final c = visible[i];
              final selected = c.code == widget.current;
              // Межа між популярними й повним списком.
              final divider = q.isEmpty && i == commonCurrencies.length;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (divider)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderHairline,
                    ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(c.code),
                    child: SizedBox(
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.side,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                currencySymbolOf(c.code, localeTag),
                                style: AppText.bodyStrong,
                              ),
                            ),
                            SizedBox(
                              width: 56,
                              child: Text(c.code, style: AppText.bodyStrong),
                            ),
                            Expanded(
                              child: Text(
                                c.name,
                                style: AppText.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: AppColors.accent,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.fromSettings)
          Padding(
            padding: const EdgeInsets.all(AppSpace.side),
            child: Text(
              context.l10n.currencyChangeNote,
              style: AppText.caption,
            ),
          ),
      ],
    );
  }
}
