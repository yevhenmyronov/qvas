import 'dart:ui';

import 'package:intl/intl.dart';

import '../l10n/country_currency.dart';
import 'money.dart';

/// Визначення валюти з системної локалі (Функціонал п.5.1, рішення 25).
/// Фолбеки згори вниз: регіон у таблиці → мова uk → USD.
String detectCurrencyCode(Locale locale) {
  final region = locale.countryCode?.toUpperCase();
  if (region != null) {
    final code = countryCurrency[region];
    if (code != null) return code;
  }
  if (locale.languageCode.toLowerCase() == 'uk') return 'UAH';
  return 'USD';
}

/// Формат грошей: число за локаллю, символ за валютою
/// (тех. спека п.11.1: це незалежні речі).
class MoneyFormat {
  MoneyFormat._(this.symbol, this.symbolFirst, this._number);

  final String symbol;

  /// true — символ перед числом ($85), false — після (85 ₴).
  final bool symbolFirst;

  final NumberFormat _number;

  /// '50 000' / '50,000' — саме число, без символу.
  String number(int major) => _number.format(major);

  /// Повний рядок: '85 ₴' або '$85' (нерозривний пробіл).
  String full(int major) => symbolFirst
      ? '$symbol${number(major)}'
      : '${number(major)} $symbol';

  static final _cache = <String, MoneyFormat>{};

  factory MoneyFormat.of(String localeTag, String currencyCode) {
    return _cache.putIfAbsent('$localeTag|$currencyCode', () {
      final currency = NumberFormat.simpleCurrency(
          locale: localeTag, name: currencyCode);
      // Позиція символу — з патерну локалі+валюти.
      final probe = currency.format(1);
      final symbol = currency.currencySymbol;
      final symbolFirst = probe.indexOf(symbol) <
          probe.indexOf(RegExp('[0-9]'));
      final number = NumberFormat('#,##0', localeTag);
      return MoneyFormat._(symbol, symbolFirst, number);
    });
  }
}

/// Підсумок в одній валюті. Валюти ніколи не складаються (Функціонал п.5),
/// тож будь-яка «сума за період» — це список, а не одне число.
typedef CurrencyTotal = ({String currencyCode, int totalMinor});

/// Роздільник валют у компактному підсумку: `100 $ · 400 ₴`.
const totalsSeparator = ' · ';

/// Кілька валют одним рядком. Порожній список → порожній рядок:
/// «нуль у якій валюті» вирішує місце виклику, бо в різних місцях
/// відповідь різна (підсумок дня взагалі не показується, «Сьогодні»
/// показує 0 в поточній валюті).
String formatTotals(String localeTag, Iterable<CurrencyTotal> totals) =>
    totals
        .map((t) =>
            MoneyFormat.of(localeTag, t.currencyCode).full(t.totalMinor.toMajor))
        .join(totalsSeparator);

/// Пункт списку валют для шторки вибору.
typedef CurrencyInfo = ({String code, String name});

/// Шість найпоширеніших для наших мов (Функціонал п.8.1).
const commonCurrencies = ['UAH', 'USD', 'EUR', 'PLN', 'GBP', 'CZK'];

/// Повний список ISO 4217 (валюти в обігу). Назви англійською —
/// пошук працює по коду й назві.
const List<CurrencyInfo> allCurrencies = [
  (code: 'AED', name: 'UAE Dirham'),
  (code: 'AFN', name: 'Afghani'),
  (code: 'ALL', name: 'Lek'),
  (code: 'AMD', name: 'Armenian Dram'),
  (code: 'ANG', name: 'Caribbean Guilder'),
  (code: 'AOA', name: 'Kwanza'),
  (code: 'ARS', name: 'Argentine Peso'),
  (code: 'AUD', name: 'Australian Dollar'),
  (code: 'AWG', name: 'Aruban Florin'),
  (code: 'AZN', name: 'Azerbaijan Manat'),
  (code: 'BAM', name: 'Convertible Mark'),
  (code: 'BBD', name: 'Barbados Dollar'),
  (code: 'BDT', name: 'Taka'),
  (code: 'BGN', name: 'Bulgarian Lev'),
  (code: 'BHD', name: 'Bahraini Dinar'),
  (code: 'BIF', name: 'Burundi Franc'),
  (code: 'BMD', name: 'Bermudian Dollar'),
  (code: 'BND', name: 'Brunei Dollar'),
  (code: 'BOB', name: 'Boliviano'),
  (code: 'BRL', name: 'Brazilian Real'),
  (code: 'BSD', name: 'Bahamian Dollar'),
  (code: 'BTN', name: 'Ngultrum'),
  (code: 'BWP', name: 'Pula'),
  (code: 'BYN', name: 'Belarusian Ruble'),
  (code: 'BZD', name: 'Belize Dollar'),
  (code: 'CAD', name: 'Canadian Dollar'),
  (code: 'CDF', name: 'Congolese Franc'),
  (code: 'CHF', name: 'Swiss Franc'),
  (code: 'CLP', name: 'Chilean Peso'),
  (code: 'CNY', name: 'Yuan Renminbi'),
  (code: 'COP', name: 'Colombian Peso'),
  (code: 'CRC', name: 'Costa Rican Colon'),
  (code: 'CUP', name: 'Cuban Peso'),
  (code: 'CVE', name: 'Cabo Verde Escudo'),
  (code: 'CZK', name: 'Czech Koruna'),
  (code: 'DJF', name: 'Djibouti Franc'),
  (code: 'DKK', name: 'Danish Krone'),
  (code: 'DOP', name: 'Dominican Peso'),
  (code: 'DZD', name: 'Algerian Dinar'),
  (code: 'EGP', name: 'Egyptian Pound'),
  (code: 'ERN', name: 'Nakfa'),
  (code: 'ETB', name: 'Ethiopian Birr'),
  (code: 'EUR', name: 'Euro'),
  (code: 'FJD', name: 'Fiji Dollar'),
  (code: 'FKP', name: 'Falkland Islands Pound'),
  (code: 'GBP', name: 'Pound Sterling'),
  (code: 'GEL', name: 'Lari'),
  (code: 'GHS', name: 'Ghana Cedi'),
  (code: 'GIP', name: 'Gibraltar Pound'),
  (code: 'GMD', name: 'Dalasi'),
  (code: 'GNF', name: 'Guinean Franc'),
  (code: 'GTQ', name: 'Quetzal'),
  (code: 'GYD', name: 'Guyana Dollar'),
  (code: 'HKD', name: 'Hong Kong Dollar'),
  (code: 'HNL', name: 'Lempira'),
  (code: 'HTG', name: 'Gourde'),
  (code: 'HUF', name: 'Forint'),
  (code: 'IDR', name: 'Rupiah'),
  (code: 'ILS', name: 'New Israeli Sheqel'),
  (code: 'INR', name: 'Indian Rupee'),
  (code: 'IQD', name: 'Iraqi Dinar'),
  (code: 'IRR', name: 'Iranian Rial'),
  (code: 'ISK', name: 'Iceland Krona'),
  (code: 'JMD', name: 'Jamaican Dollar'),
  (code: 'JOD', name: 'Jordanian Dinar'),
  (code: 'JPY', name: 'Yen'),
  (code: 'KES', name: 'Kenyan Shilling'),
  (code: 'KGS', name: 'Som'),
  (code: 'KHR', name: 'Riel'),
  (code: 'KMF', name: 'Comorian Franc'),
  (code: 'KPW', name: 'North Korean Won'),
  (code: 'KRW', name: 'Won'),
  (code: 'KWD', name: 'Kuwaiti Dinar'),
  (code: 'KYD', name: 'Cayman Islands Dollar'),
  (code: 'KZT', name: 'Tenge'),
  (code: 'LAK', name: 'Lao Kip'),
  (code: 'LBP', name: 'Lebanese Pound'),
  (code: 'LKR', name: 'Sri Lanka Rupee'),
  (code: 'LRD', name: 'Liberian Dollar'),
  (code: 'LSL', name: 'Loti'),
  (code: 'LYD', name: 'Libyan Dinar'),
  (code: 'MAD', name: 'Moroccan Dirham'),
  (code: 'MDL', name: 'Moldovan Leu'),
  (code: 'MGA', name: 'Malagasy Ariary'),
  (code: 'MKD', name: 'Denar'),
  (code: 'MMK', name: 'Kyat'),
  (code: 'MNT', name: 'Tugrik'),
  (code: 'MOP', name: 'Pataca'),
  (code: 'MRU', name: 'Ouguiya'),
  (code: 'MUR', name: 'Mauritius Rupee'),
  (code: 'MVR', name: 'Rufiyaa'),
  (code: 'MWK', name: 'Malawi Kwacha'),
  (code: 'MXN', name: 'Mexican Peso'),
  (code: 'MYR', name: 'Malaysian Ringgit'),
  (code: 'MZN', name: 'Mozambique Metical'),
  (code: 'NAD', name: 'Namibia Dollar'),
  (code: 'NGN', name: 'Naira'),
  (code: 'NIO', name: 'Cordoba Oro'),
  (code: 'NOK', name: 'Norwegian Krone'),
  (code: 'NPR', name: 'Nepalese Rupee'),
  (code: 'NZD', name: 'New Zealand Dollar'),
  (code: 'OMR', name: 'Rial Omani'),
  (code: 'PAB', name: 'Balboa'),
  (code: 'PEN', name: 'Sol'),
  (code: 'PGK', name: 'Kina'),
  (code: 'PHP', name: 'Philippine Peso'),
  (code: 'PKR', name: 'Pakistan Rupee'),
  (code: 'PLN', name: 'Zloty'),
  (code: 'PYG', name: 'Guarani'),
  (code: 'QAR', name: 'Qatari Rial'),
  (code: 'RON', name: 'Romanian Leu'),
  (code: 'RSD', name: 'Serbian Dinar'),
  (code: 'RUB', name: 'Russian Ruble'),
  (code: 'RWF', name: 'Rwanda Franc'),
  (code: 'SAR', name: 'Saudi Riyal'),
  (code: 'SBD', name: 'Solomon Islands Dollar'),
  (code: 'SCR', name: 'Seychelles Rupee'),
  (code: 'SDG', name: 'Sudanese Pound'),
  (code: 'SEK', name: 'Swedish Krona'),
  (code: 'SGD', name: 'Singapore Dollar'),
  (code: 'SHP', name: 'Saint Helena Pound'),
  (code: 'SLE', name: 'Leone'),
  (code: 'SOS', name: 'Somali Shilling'),
  (code: 'SRD', name: 'Surinam Dollar'),
  (code: 'SSP', name: 'South Sudanese Pound'),
  (code: 'STN', name: 'Dobra'),
  (code: 'SYP', name: 'Syrian Pound'),
  (code: 'SZL', name: 'Lilangeni'),
  (code: 'THB', name: 'Baht'),
  (code: 'TJS', name: 'Somoni'),
  (code: 'TMT', name: 'Turkmenistan New Manat'),
  (code: 'TND', name: 'Tunisian Dinar'),
  (code: 'TOP', name: 'Paʻanga'),
  (code: 'TRY', name: 'Turkish Lira'),
  (code: 'TTD', name: 'Trinidad and Tobago Dollar'),
  (code: 'TWD', name: 'New Taiwan Dollar'),
  (code: 'TZS', name: 'Tanzanian Shilling'),
  (code: 'UAH', name: 'Hryvnia'),
  (code: 'UGX', name: 'Uganda Shilling'),
  (code: 'USD', name: 'US Dollar'),
  (code: 'UYU', name: 'Peso Uruguayo'),
  (code: 'UZS', name: 'Uzbekistan Sum'),
  (code: 'VES', name: 'Bolivar Soberano'),
  (code: 'VND', name: 'Dong'),
  (code: 'VUV', name: 'Vatu'),
  (code: 'WST', name: 'Tala'),
  (code: 'XAF', name: 'CFA Franc BEAC'),
  (code: 'XCD', name: 'East Caribbean Dollar'),
  (code: 'XOF', name: 'CFA Franc BCEAO'),
  (code: 'XPF', name: 'CFP Franc'),
  (code: 'YER', name: 'Yemeni Rial'),
  (code: 'ZAR', name: 'Rand'),
  (code: 'ZMW', name: 'Zambian Kwacha'),
  (code: 'ZWL', name: 'Zimbabwe Dollar'),
];

/// Символ валюти для рядків списку (через intl, з кешем).
String currencySymbolOf(String code, String localeTag) =>
    MoneyFormat.of(localeTag, code).symbol;
