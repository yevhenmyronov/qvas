import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/l10n/emoji_set.dart';

/// Звірка `emoji-set.txt` з емодзі, які реально трапляються в коді.
///
/// Сабсет шрифту ріжеться по цьому файлу (тех. спека п.7), і зв'язок між
/// ним і кодом тримається лише на тому, що хтось не забув запустити
/// `tool/build_emoji_font.py`. Забути легко й непомітно: локально гліф
/// домалює системний шрифт, а на пристрої з вшитим сабсетом на його
/// місці буде порожній квадрат.
///
/// Тому розбіжність ловиться тут, а не оком на пристрої.
void main() {
  /// Межа «це напевно емодзі». Нижче за неї живуть і емодзі (`⌚`, `➕`),
  /// і типографіка (`✕`, `−`, `→`) — причому в одних блоках, тож
  /// відрізнити їх діапазоном не вийде. Це робить скрипт збірки, звіряючи
  /// кандидатів із cmap самого Noto; тут перевіряється лише беззаперечна
  /// частина, де хибних спрацювань не буває.
  const astralEmojiFloor = 0x1F000;

  late Set<int> declared;
  late Set<int> inCode;

  setUpAll(() {
    final file = File('emoji-set.txt');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'немає emoji-set.txt — запусти tool/build_emoji_font.py',
    );
    declared = file
        .readAsLinesSync()
        .map((line) => RegExp(r'^([0-9A-F]{4,6})\b').firstMatch(line))
        .nonNulls
        .map((m) => int.parse(m.group(1)!, radix: 16))
        .toSet();

    final literal = RegExp(r"'([^']*)'");
    inCode = {
      for (final entity in Directory('lib').listSync(recursive: true))
        if (entity is File && entity.path.endsWith('.dart'))
          for (final match in literal.allMatches(entity.readAsStringSync()))
            ...match.group(1)!.runes.where((r) => r >= 0x2100),
    };
  });

  test('кожне емодзі з коду є в наборі сабсету', () {
    final missing =
        inCode.where((cp) => cp >= astralEmojiFloor).toSet().difference(declared);
    expect(
      missing,
      isEmpty,
      reason: 'ці гліфи не потраплять у шрифт і стануть порожніми '
          'квадратами: ${_render(missing)}. '
          'Перезбери: python tool/build_emoji_font.py',
    );
  });

  test('у наборі немає гліфів, яких уже немає в коді', () {
    // Не косметика: кожен зайвий гліф — це вага в APK, а бюджет
    // (Чекпоінт 2026-08-15) і так перевищено.
    final stale = declared.difference(inCode);
    expect(
      stale,
      isEmpty,
      reason: 'набір застарів, ці гліфи вже не використовуються: '
          '${_render(stale)}. Перезбери: python tool/build_emoji_font.py',
    );
  });

  test('групи пікера не містять повторів', () {
    for (final group in emojiGroups) {
      final seen = <String>{};
      final duplicates = group.emojis.where((e) => !seen.add(e)).toList();
      expect(
        duplicates,
        isEmpty,
        reason: 'група "${group.key}" містить повтори: $duplicates',
      );
    }
  });
}

String _render(Set<int> codepoints) => codepoints
    .map((cp) =>
        'U+${cp.toRadixString(16).toUpperCase()} ${String.fromCharCode(cp)}')
    .join(', ');
