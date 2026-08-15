import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Грані піднятої поверхні під одним джерелом світла згори
/// (рішення 59, доповнено 2026-08-16).
///
/// Спершу малювалась лише світла верхня грань. Цього виявилось замало:
/// поверхня зі світлом угорі й нічим унизу читається як пляма трохи
/// іншого відтінку, а не як об'єм. Рельєф дає саме **пара** — світло
/// там, куди падає промінь, і тінь на протилежному краї, який від
/// нього відвертається.
///
/// **Це не обводка й не тінь у сенсі DS.** Обводка описує форму й
/// малюється по всьому контуру; тінь падає ПОЗА елементом. Тут обидві
/// грані живуть усередині самої поверхні й гаснуть до боків, тож
/// правила «обводок заради обводок немає» і «тіней немає» лишаються
/// чинними — це модель освітлення, а не декор.
///
/// Реалізовано як [ShapeBorder] і споживається через
/// `AnimatedContainer.foregroundDecoration` — у нього є справжній
/// `DecorationTween`, тож «натиснуте виходить з-під світла» анімується
/// наявним твіном, без окремого контролера й без зайвого шару.
@immutable
class EdgeLight extends ShapeBorder {
  const EdgeLight({
    required this.borderRadius,
    this.intensity = 1,
    this.width = 1.0,
  });

  /// Прозорість світлої верхньої грані на повній інтенсивності.
  static const lightOpacity = 0.085;

  /// Прозорість темної нижньої грані. Помітно більша за світлу: на
  /// майже-чорному тлі чорне «з'їдається» фоном, тож рівні альфи дали б
  /// однобокий рельєф — верх було б видно, низ ні.
  static const shadowOpacity = 0.30;

  final BorderRadius borderRadius;

  /// 0 — граней немає, 1 — повні. Гаситься саме множником, а не
  /// підміною на `null`: [ShapeDecoration.lerp] розгортає результат
  /// [ShapeBorder.lerp] через `!`, тож лерпити проти `null` не можна —
  /// буде стрибок замість переходу.
  final double intensity;

  final double width;

  /// Єдине, що бачать місця виклику.
  static ShapeDecoration decoration(
    BorderRadius radius, {
    bool on = true,
  }) {
    return ShapeDecoration(
      shape: EdgeLight(borderRadius: radius, intensity: on ? 1 : 0),
    );
  }

  /// Грані не займають місця: вони малюються поверх готової поверхні й
  /// ніколи не впливають на розкладку.
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => EdgeLight(
    borderRadius: borderRadius * t,
    intensity: intensity * t,
    width: width * t,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is EdgeLight ? _lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is EdgeLight ? _lerp(this, b, t) : super.lerpTo(b, t);

  static EdgeLight _lerp(EdgeLight a, EdgeLight b, double t) => EdgeLight(
    borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t)!,
    intensity: ui.lerpDouble(a.intensity, b.intensity, t)!,
    width: ui.lerpDouble(a.width, b.width, t)!,
  );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (intensity <= 0.004 || rect.isEmpty) return;

    // scaleRadii обов'язковий: --r-pill це 999, і на капсулі 44dp
    // реальний радіус має бути 22, а не 999.
    final rr = borderRadius.resolve(textDirection).toRRect(rect).scaleRadii();
    final inset = width / 2;
    final left = rect.left + inset;
    final right = rect.right - inset;

    _stroke(
      canvas,
      rect,
      _topPath(rect, rr, inset, left, right),
      Colors.white,
      lightOpacity * intensity,
    );
    _stroke(
      canvas,
      rect,
      _bottomPath(rect, rr, inset, left, right),
      Colors.black,
      shadowOpacity * intensity,
    );
  }

  /// Верхня грань і дві верхні дуги. Дуги йдуть у прозорі хвости
  /// горизонтального градієнта, тому вертикальний спад виходить сам —
  /// без другого градієнта й без saveLayer.
  Path? _topPath(
    Rect rect,
    RRect rr,
    double inset,
    double left,
    double right,
  ) {
    final rtl = math.max(rr.tlRadiusX - inset, 0.0);
    final rtr = math.max(rr.trRadiusX - inset, 0.0);
    if (right - left <= rtl + rtr) return null;

    final top = rect.top + inset;
    final path = Path()..moveTo(left, top + rtl);
    if (rtl > 0) {
      path.arcToPoint(
        Offset(left + rtl, top),
        radius: Radius.circular(rtl),
        clockwise: true,
      );
    } else {
      path.lineTo(left, top);
    }
    path.lineTo(right - rtr, top);
    if (rtr > 0) {
      path.arcToPoint(
        Offset(right, top + rtr),
        radius: Radius.circular(rtr),
        clockwise: true,
      );
    }
    return path;
  }

  /// Дзеркало верхньої: нижня грань і дві нижні дуги.
  Path? _bottomPath(
    Rect rect,
    RRect rr,
    double inset,
    double left,
    double right,
  ) {
    final rbl = math.max(rr.blRadiusX - inset, 0.0);
    final rbr = math.max(rr.brRadiusX - inset, 0.0);
    if (right - left <= rbl + rbr) return null;

    final bottom = rect.bottom - inset;
    final path = Path()..moveTo(left, bottom - rbl);
    if (rbl > 0) {
      path.arcToPoint(
        Offset(left + rbl, bottom),
        radius: Radius.circular(rbl),
        clockwise: false,
      );
    } else {
      path.lineTo(left, bottom);
    }
    path.lineTo(right - rbr, bottom);
    if (rbr > 0) {
      path.arcToPoint(
        Offset(right, bottom - rbr),
        radius: Radius.circular(rbr),
        clockwise: false,
      );
    }
    return path;
  }

  void _stroke(
    Canvas canvas,
    Rect rect,
    Path? path,
    Color color,
    double opacity,
  ) {
    if (path == null || opacity <= 0.004) return;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..shader = _shaderFor(rect, color, opacity),
    );
  }

  /// Градієнт залежить лише від ширини прямокутника, кольору й
  /// прозорості, тож перестворювати його на кожне малювання не треба —
  /// а малювань багато: дванадцять клітинок пада мають однакову ширину
  /// й перемальовуються разом на кожному натисканні.
  static final _shaders = <int, ui.Shader>{};

  static ui.Shader _shaderFor(Rect rect, Color color, double opacity) {
    // Прозорість квантується до байта альфи: під час згасання граней
    // вона змінюється неперервно, і без квантування кеш промахувався б
    // саме на анімації — тобто рівно тоді, коли він потрібен.
    final alpha = (opacity * 255).round();
    final key = Object.hash(
      rect.width.round(),
      rect.left.round(),
      alpha,
      color.toARGB32(),
    );

    final cached = _shaders[key];
    if (cached != null) return cached;

    if (_shaders.length > 128) _shaders.clear();

    final solid = color.withValues(alpha: alpha / 255);
    final clear = color.withValues(alpha: 0);
    final shader = LinearGradient(
      colors: [clear, solid, solid, clear],
      stops: const [0.0, 0.22, 0.78, 1.0],
    ).createShader(rect);
    return _shaders[key] = shader;
  }

  @override
  bool operator ==(Object other) =>
      other is EdgeLight &&
      other.borderRadius == borderRadius &&
      other.intensity == intensity &&
      other.width == width;

  @override
  int get hashCode => Object.hash(borderRadius, intensity, width);
}
