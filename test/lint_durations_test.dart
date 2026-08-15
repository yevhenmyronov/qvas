import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Кожна тривалість мусить проходити через [AppDurations.of].
///
/// `AppDurations.of(context, base)` повертає нуль, коли в системі
/// увімкнено «Прибрати анімації» (DS п.6). Варто взяти токен напряму —
/// і саме цей рух перестає слухатись налаштування, мовчки: аналізатор
/// такого не бачить, тести теж, а на пристрої це помітно лише тому,
/// хто цим налаштуванням користується.
///
/// За час роботи над дизайном таких витоків знайшлось чотири, і
/// четвертий я побачив не сам. Тому це не одноразове виправлення, а
/// правило: репозиторій уже має цей патерн у app_version_test.dart,
/// який читає pubspec.yaml.
void main() {
  test('AppDurations.* завжди йде через of()', () {
    final tokens = RegExp(r'AppDurations\.(micro|standard|sheet|appear)');
    final offenders = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      // Місце оголошення самих токенів.
      if (file.path.replaceAll(r'\', '/').endsWith('lib/theme/tokens.dart')) {
        continue;
      }

      // Переноси рядків прибираються: dart format легко розриває
      // виклик `of(` і сам токен на два рядки, і порядкова перевірка
      // давала б хибні спрацювання.
      final source = file.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      for (final match in tokens.allMatches(source)) {
        final windowStart = (match.start - 48).clamp(0, source.length);
        final preceding = source.substring(windowStart, match.start);
        if (preceding.contains('AppDurations.of(')) continue;
        offenders.add('${file.path}: ${match.group(0)}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'ці тривалості не поважають «Прибрати анімації» — оберніть у '
          'AppDurations.of(context, ...)',
    );
  });
}
