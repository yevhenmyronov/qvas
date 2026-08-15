import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Верхнє світло на піднятій поверхні (рішення 59, 2026-08-16).
///
/// До цього глибина в застосунку виражалась лише тим, що поверхні мають
/// різну яскравість заливки. Цього мало: рівномірно залита плашка не має
/// джерела світла, тому й об'єму не читається. Тут з'являється рівно одне
/// джерело — згори, — і кожна піднята поверхня отримує тонку світлу грань
/// по верхньому краю.
///
/// **Це не обводка.** Обводка описує форму й малюється по всьому контуру;
/// тут малюється тільки верхня грань і дві верхні дуги, а горизонтальний
/// градієнт гасить її до боків. Правило DS «обводок заради обводок немає»
/// лишається чинним.
///
/// Реалізовано як [ShapeBorder] і споживається через
/// `AnimatedContainer.foregroundDecoration` — саме тому, що в нього є
/// справжній `DecorationTween`. Завдяки цьому «натиснуте втрачає світло»
/// анімується наявним твіном за `--d-micro` й не потребує ані окремого
/// контролера, ані зайвого шару малювання: кожен виклик отримує рівно
/// один новий аргумент.
@immutable
class TopLight extends ShapeBorder {
  const TopLight({
    required this.borderRadius,
    this.opacity = defaultOpacity,
    this.width = 1.0,
  });

  static const defaultOpacity = 0.06;

  final BorderRadius borderRadius;

  /// 0 — світла немає. Гаситься саме прозорістю, а не підміною на `null`:
  /// [ShapeDecoration.lerp] розгортає результат [ShapeBorder.lerp] через
  /// `!`, тож лерпити проти `null` не можна — буде стрибок замість
  /// переходу.
  final double opacity;

  final double width;

  /// Єдине, що бачать місця виклику.
  static ShapeDecoration decoration(
    BorderRadius radius, {
    bool on = true,
    double opacity = defaultOpacity,
  }) {
    return ShapeDecoration(
      shape: TopLight(borderRadius: radius, opacity: on ? opacity : 0),
    );
  }

  /// Світло не займає місця: воно малюється поверх готової поверхні й
  /// ніколи не впливає на розкладку.
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => TopLight(
    borderRadius: borderRadius * t,
    opacity: opacity * t,
    width: width * t,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is TopLight ? _lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is TopLight ? _lerp(this, b, t) : super.lerpTo(b, t);

  static TopLight _lerp(TopLight a, TopLight b, double t) => TopLight(
    borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t)!,
    opacity: ui.lerpDouble(a.opacity, b.opacity, t)!,
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
    if (opacity <= 0.001 || rect.isEmpty) return;

    // scaleRadii обов'язковий: --r-pill це 999, і на капсулі 44dp реальний
    // радіус має бути 22, а не 999.
    final rr = borderRadius.resolve(textDirection).toRRect(rect).scaleRadii();

    final inset = width / 2;
    final left = rect.left + inset;
    final right = rect.right - inset;
    final top = rect.top + inset;
    final rtl = math.max(rr.tlRadiusX - inset, 0.0);
    final rtr = math.max(rr.trRadiusX - inset, 0.0);

    if (right - left <= rtl + rtr) return;

    // Тільки верхня грань і дві верхні дуги. Дуги йдуть у прозорі хвости
    // градієнта, тому вертикальний спад виходить сам — без другого
    // градієнта й без saveLayer.
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

    final white = Color.fromRGBO(255, 255, 255, opacity);
    const clear = Color(0x00FFFFFF);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [clear, white, white, clear],
          stops: const [0.0, 0.22, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TopLight &&
      other.borderRadius == borderRadius &&
      other.opacity == opacity &&
      other.width == width;

  @override
  int get hashCode => Object.hash(borderRadius, opacity, width);
}
