import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/ui/common/grain.dart';

/// Зерно накладається поверх усього застосунку, тож помилка в самому
/// тайлі закриває екран і при цьому НЕ кидає виключення — у логах чисто,
/// а на пристрої білий екран. Саме так і сталось: rgba8888 у
/// [ui.decodeImageFromPixels] premultiplied, а тайл був записаний як
/// straight (RGB=255 при альфі 5), і Skia видала біле на повну.
///
/// Тому перевіряємо не «чи згенерувався тайл», а чи він справді ледь
/// помітний.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('тайл зерна майже прозорий і не має непрозорих пікселів', () async {
    await prepareGrainTile();
    final image = grainTile.value;
    expect(image, isNotNull);

    final data = await image!.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(data, isNotNull);

    final bytes = data!.buffer.asUint8List();
    var maxAlpha = 0;
    var maxChannel = 0;
    for (var i = 0; i < bytes.length; i += 4) {
      maxChannel = [
        maxChannel,
        bytes[i],
        bytes[i + 1],
        bytes[i + 2],
      ].reduce((a, b) => a > b ? a : b);
      if (bytes[i + 3] > maxAlpha) maxAlpha = bytes[i + 3];
    }

    expect(
      maxAlpha,
      lessThanOrEqualTo(8),
      reason: 'зерно має бути ледь помітним, а не шаром поверх екрана',
    );
    expect(
      maxChannel,
      lessThanOrEqualTo(maxAlpha),
      reason: 'premultiplied: канал кольору не може перевищувати альфу',
    );
  });
}
