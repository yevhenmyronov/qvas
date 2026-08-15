import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Правила, які тримають зведення Етапу 4 зведеним.
///
/// Дублі, які довелось прибирати, з'явились не тому, що хтось вирішив
/// їх завести. Вони з'являються по одному: поруч немає компонента, є
/// дедлайн, і скопіювати сусідній рядок швидше, ніж шукати спільний. За
/// двадцять ітерацій догфудингу так набралось сім реалізацій рядка,
/// вісім кнопок і сім копій хроми шторки.
///
/// Аналізатор такого не бачить — це не помилка мови. Тому межі
/// стереже тест, як уже стереже їх [lint_durations_test] для
/// тривалостей і `app_version_test` для версії.
///
/// Кожне правило — це «ось єдине місце, де так можна». Якщо файл до
/// списку треба додати, спершу варто спитати, чи не компонент це.
void main() {
  test('сирі кольори живуть тільки в палітрі', () {
    _expectOnlyIn(
      pattern: RegExp(r'Color\(0x'),
      allowed: {'lib/theme/tokens.dart'},
      reason:
          'шістнадцятковий колір поза tokens.dart — це значення, яке '
          'ніхто не перегляне при зміні палітри. Саме так у градієнті '
          'заголовка дня застряг прозорий варіант СТАРОГО фону',
    );
  });

  test('радіус береться з AppRadius, а не з голови', () {
    _expectOnlyIn(
      pattern: RegExp(r'Radius\.circular\([0-9]'),
      allowed: const {},
      reason:
          'радіус виводиться з висоти (AppRadius.forHeight) або '
          'оголошується формою (AppRadius.pill, .sheet). Число на місці '
          'виклику — це третій спосіб, якого немає',
    );
  });

  test('шторка відкривається одним способом', () {
    _expectOnlyIn(
      pattern: RegExp(r'showModalBottomSheet<'),
      allowed: {'lib/ui/common/app_sheet.dart'},
      reason:
          'showAppSheet несе хрому, скрим, клавіатурні вставки, каскад '
          'рядків і — головне — власний контролер переходу, без якого '
          'шторка не слухається «Прибрати анімації»',
    );
  });

  test('кружечок емодзі один на застосунок', () {
    _expectOnlyIn(
      pattern: RegExp(r'BoxShape\.circle'),
      allowed: {'lib/ui/common/app_emoji_avatar.dart'},
      reason: 'AppEmojiAvatar — три місця мали три копії того самого кола',
    );
  });
}

/// Шукає [pattern] по всьому `lib` і вимагає, щоб він траплявся лише у
/// файлах зі списку [allowed] (шляхи через `/`, від кореня пакета).
///
/// Коментарі й документація не рахуються: правило про те, як пишеться
/// КОД, а посилатись на `showModalBottomSheet` у поясненні, чому його
/// не варто кликати самому, — саме те, чого хочеться.
void _expectOnlyIn({
  required RegExp pattern,
  required Set<String> allowed,
  required String reason,
}) {
  final offenders = <String>[];

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final path = entity.path.replaceAll(r'\', '/');
    if (allowed.any(path.endsWith)) continue;
    // Згенероване не редагується руками.
    if (path.endsWith('.g.dart') || path.contains('/l10n/gen/')) continue;

    for (final (i, line) in entity.readAsLinesSync().indexed) {
      final code = line.trimLeft();
      if (code.startsWith('//') || code.startsWith('///')) continue;
      if (pattern.hasMatch(line)) {
        offenders.add('$path:${i + 1}: ${line.trim()}');
      }
    }
  }

  expect(offenders, isEmpty, reason: reason);
}
