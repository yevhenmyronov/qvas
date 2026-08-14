import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/money.dart';
import '../models/tx_type.dart';

/// Серіалізація бекапу — чисті функції без введення-виведення
/// (тестуються round-trip'ом без бази). Формати — тех. спека п.8.

const backupSchemaVersion = 1;

/// Повний JSON-дамп: транзакції + категорії + налаштування.
Map<String, Object?> buildBackupMap({
  required AppSetting settings,
  required List<Category> categories,
  required List<Transaction> transactions,
  required DateTime exportedAt,
}) {
  return {
    'app': 'qvas',
    'schemaVersion': backupSchemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'settings': {
      'currencyCode': settings.currencyCode,
      'locale': settings.localeOverride,
    },
    'categories': [
      for (final c in categories)
        {
          'id': c.id,
          'type': c.type.name,
          'nameKey': c.nameKey,
          'customName': c.customName,
          'emoji': c.emoji,
          'isBuiltIn': c.isBuiltIn,
          'isPinned': c.isPinned,
          'isArchived': c.isArchived,
          'sortOrder': c.sortOrder,
          'createdAt': c.createdAt.toUtc().toIso8601String(),
        },
    ],
    'transactions': [
      for (final t in transactions)
        {
          'id': t.id,
          'type': t.type.name,
          'amountMinor': t.amountMinor,
          'categoryId': t.categoryId,
          'currencyCode': t.currencyCode,
          // createdAtUtc зберігається: без нього неможливо відновити
          // порядок записів усередині дня (тех. спека п.2.3).
          'createdAtUtc': t.createdAtUtc.toUtc().toIso8601String(),
          'localDateKey': t.localDateKey,
          'note': t.note,
        },
    ],
  };
}

/// Розібраний бекап + дані для екрана підтвердження.
class ParsedBackup {
  ParsedBackup({
    required this.currencyCode,
    required this.localeOverride,
    required this.categories,
    required this.transactions,
  });

  final String? currencyCode;
  final String? localeOverride;
  final List<CategoriesCompanion> categories;
  final List<TransactionsCompanion> transactions;

  int get count => transactions.length;

  /// 'yyyy-MM' → 'MM.yyyy' межі періоду для тексту підтвердження.
  ({String from, String to})? get period {
    if (transactions.isEmpty) return null;
    final keys = [for (final t in transactions) t.localDateKey.value]
      ..sort();
    String fmt(String key) => '${key.substring(5, 7)}.${key.substring(0, 4)}';
    return (from: fmt(keys.first), to: fmt(keys.last));
  }
}

/// Валідація і розбір. Кидає [FormatException] на чужому чи
/// несумісному файлі — імпорт транзакційний: або весь, або ніякий.
ParsedBackup parseBackupMap(Map<String, Object?> json) {
  if (json['app'] != 'qvas') {
    throw const FormatException('not a qvas backup');
  }
  final version = json['schemaVersion'];
  if (version is! int || version > backupSchemaVersion) {
    throw FormatException('unsupported schemaVersion: $version');
  }
  final settings = json['settings'] as Map<String, Object?>? ?? const {};

  TxType typeOf(Object? name) =>
      TxType.values.firstWhere((t) => t.name == name);

  final categories = <CategoriesCompanion>[
    for (final raw in json['categories'] as List? ?? const [])
      _category(raw as Map<String, Object?>, typeOf),
  ];
  final transactions = <TransactionsCompanion>[
    for (final raw in json['transactions'] as List? ?? const [])
      _transaction(raw as Map<String, Object?>, typeOf),
  ];
  return ParsedBackup(
    currencyCode: settings['currencyCode'] as String?,
    localeOverride: settings['locale'] as String?,
    categories: categories,
    transactions: transactions,
  );
}

CategoriesCompanion _category(
    Map<String, Object?> c, TxType Function(Object?) typeOf) {
  return CategoriesCompanion.insert(
    id: c['id'] as String,
    type: typeOf(c['type']),
    nameKey: Value(c['nameKey'] as String?),
    customName: Value(c['customName'] as String?),
    emoji: c['emoji'] as String,
    isBuiltIn: Value(c['isBuiltIn'] as bool? ?? false),
    isPinned: Value(c['isPinned'] as bool? ?? false),
    isArchived: Value(c['isArchived'] as bool? ?? false),
    sortOrder: Value(c['sortOrder'] as int? ?? 0),
    createdAt: c['createdAt'] != null
        ? DateTime.parse(c['createdAt'] as String)
        : DateTime.now().toUtc(),
  );
}

TransactionsCompanion _transaction(
    Map<String, Object?> t, TxType Function(Object?) typeOf) {
  return TransactionsCompanion.insert(
    id: t['id'] as String,
    type: typeOf(t['type']),
    amountMinor: t['amountMinor'] as int,
    categoryId: t['categoryId'] as String,
    currencyCode: t['currencyCode'] as String,
    createdAtUtc: DateTime.parse(t['createdAtUtc'] as String),
    localDateKey: t['localDateKey'] as String,
    note: Value(t['note'] as String?),
  );
}

/// CSV для людини (тех. спека п.8): мажорні одиниці, без часу.
/// [nameOf] віддає видиму назву категорії поточною мовою.
String buildCsv(
  List<Transaction> transactions,
  Map<String, Category> categoriesById,
  String Function(Category?) nameOf,
) {
  final b = StringBuffer('date,type,category,amount,currency,note\r\n');
  for (final t in transactions) {
    b.write([
      t.localDateKey,
      t.type.name,
      _csvCell(nameOf(categoriesById[t.categoryId])),
      t.amountMinor.toMajor.toString(),
      t.currencyCode,
      _csvCell(t.note ?? ''),
    ].join(','));
    b.write('\r\n');
  }
  return b.toString();
}

String _csvCell(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
