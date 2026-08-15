import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Зерно на темних площинах (рішення 61, 2026-08-16).
///
/// Рівна заливка на майже-чорному читається як пластик; десята частка
/// відсотка шуму дає поверхні матеріальність і заодно прибирає бендинг
/// на градієнті заголовка дня. Ефект помічають лише тоді, коли його
/// прибрати — це й є ознака того, що він на місці.
///
/// **Чому тайл генерується, а не лежить ассетом.** Випадковий шум
/// майже не стискається: PNG 128×128 коштував би ~16 КБ при бюджеті
/// APK, вже перевищеному на 0.8 МБ. Генерація в рантаймі коштує нуль
/// байтів і ~1–2 мс, і ці міллісекунди виносяться за перший кадр.
///
/// **Чому не фрагментний шейдер.** Той перемальовувався б щокадру й
/// компілювався при першому малюванні. Тут — один статичний шар під
/// [RepaintBoundary]: скрол бруднить шар ПІД зерном, а не саме зерно.
///
/// Сід фіксований, щоб зерно було однаковим між запусками — інакше
/// скріншоти застосунку відрізнялись би один від одного нізащо.
const _seed = 42;
const _tileSize = 128;

/// Максимальна альфа зернини. Середня виходить удвічі меншою — близько
/// 1.4%. Прозорість запечена в самі пікселі навмисно: модулювати шейдер
/// через `Opacity` чи `saveLayer` означало б повноекранний офскрін
/// щокадру, а це рівно та ціна, якої цей ефект не вартий.
const _maxGrainAlpha = 7;

final grainTile = ValueNotifier<ui.Image?>(null);

/// Викликається з відкладеної ініціалізації в `main.dart` — до того
/// моменту [GrainOverlay] просто нічого не малює, тож холодний старт
/// не чекає ні на що.
Future<void> prepareGrainTile() async {
  if (grainTile.value != null) return;

  final random = math.Random(_seed);
  final pixels = Uint8List(_tileSize * _tileSize * 4);
  for (var i = 0; i < pixels.length; i += 4) {
    // Біле зерно змінної прозорості. Колірного зерна не буває — воно
    // читалось би як биті пікселі; а темне на #0C0D10 і так невидиме,
    // тож шум тільки висвітлює.
    pixels[i] = 255;
    pixels[i + 1] = 255;
    pixels[i + 2] = 255;
    pixels[i + 3] = random.nextInt(_maxGrainAlpha + 1);
  }

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    _tileSize,
    _tileSize,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  grainTile.value = await completer.future;
}

/// Накладає зерно поверх усього застосунку. Живе в `MaterialApp.builder`,
/// тобто малюється рівно один раз, а не по разу на поверхню.
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: ValueListenableBuilder<ui.Image?>(
                valueListenable: grainTile,
                builder: (context, image, _) => image == null
                    ? const SizedBox.shrink()
                    : CustomPaint(painter: _GrainPainter(image)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        ),
    );
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.image != image;
}
