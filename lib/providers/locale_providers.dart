import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import 'core_providers.dart';

/// Мова застосунку: власне налаштування, не системне per-app
/// (тех. спека п.11.3). null у базі = брати системну; фолбек — en.
final localeTagProvider = Provider<String>((ref) {
  final override =
      ref.watch(settingsProvider).value?.localeOverride;
  if (override != null) return override;
  final sys = PlatformDispatcher.instance.locale.languageCode;
  return sys == 'uk' ? 'uk' : 'en';
});

/// Валюта для НОВИХ записів. До ініціалізації рядка налаштувань —
/// автовизначення з системної локалі.
final currencyCodeProvider = Provider<String>((ref) {
  final s = ref.watch(settingsProvider).value;
  return s?.currencyCode ??
      detectCurrencyCode(PlatformDispatcher.instance.locale);
});

/// Формат грошей поточної валюти й мови — для суми вводу та метрик.
/// Записи в стрічці форматуються за ВЛАСНОЮ валютою транзакції.
final moneyFormatProvider = Provider<MoneyFormat>((ref) {
  return MoneyFormat.of(
      ref.watch(localeTagProvider), ref.watch(currencyCodeProvider));
});
