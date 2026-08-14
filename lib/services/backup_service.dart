import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';
import '../models/dates.dart';
import '../repositories/settings_repository.dart';
import 'backup.dart';

/// Експорт і відновлення (Функціонал п.7). Файли віддаються через
/// системний Share Sheet, імпорт — через системний пікер (SAF):
/// жодних дозволів на сховище, ми нікуди нічого не відправляємо.
class BackupService {
  BackupService(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  Future<File> _tempFile(String name) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}${Platform.pathSeparator}$name');
  }

  String _stamp() => localDateKeyOf(DateTime.now());

  /// «Зберегти резервну копію» → JSON через Share Sheet.
  Future<void> exportJson() async {
    final settings = await _settings.get();
    final categories = await _db.select(_db.categories).get();
    final transactions = await (_db.select(_db.transactions)
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final map = buildBackupMap(
      settings: settings,
      categories: categories,
      transactions: transactions,
      exportedAt: DateTime.now(),
    );
    final file = await _tempFile('qvas-backup-${_stamp()}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    await _settings.markBackupDone();
  }

  /// «Експортувати в CSV» → плоска таблиця для людини.
  /// [nameOf] локалізує назви вбудованих категорій.
  Future<void> exportCsv(String Function(Category?) nameOf) async {
    final categories = await _db.select(_db.categories).get();
    final byId = {for (final c in categories) c.id: c};
    final transactions = await (_db.select(_db.transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.localDateKey),
            (t) => OrderingTerm.desc(t.createdAtUtc),
          ]))
        .get();

    final csv = buildCsv(transactions, byId, nameOf);
    final file = await _tempFile('qvas-${_stamp()}.csv');
    // BOM — щоб Excel правильно відкрив UTF-8 із кирилицею.
    await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  /// Системний пікер → розібраний бекап для екрана підтвердження.
  /// null — користувач скасував вибір. Кидає FormatException на
  /// несумісному файлі.
  Future<ParsedBackup?> pickBackup() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    return parseBackupMap(json);
  }

  /// Транзакційне застосування: або весь файл, або нічого.
  /// [replace] — знищити поточні дані; інакше «додати» з дедуплікацією
  /// за id (тех. спека п.8).
  Future<void> applyImport(ParsedBackup backup,
      {required bool replace}) async {
    await _db.transaction(() async {
      if (replace) {
        await _db.delete(_db.transactions).go();
        await _db.delete(_db.categories).go();
      }
      await _db.batch((b) {
        b.insertAll(_db.categories, backup.categories,
            mode: InsertMode.insertOrIgnore);
        b.insertAll(_db.transactions, backup.transactions,
            mode: InsertMode.insertOrIgnore);
      });
      final currency = backup.currencyCode;
      if (replace && currency != null) {
        await _settings.setCurrency(currency);
      }
    });
  }
}
