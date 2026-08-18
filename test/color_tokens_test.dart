import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/theme/tokens.dart';

/// Токени, які мусять лишатись узгодженими між собою.
///
/// Приводом був реальний витік: у градієнті заголовка дня стояв хардкод
/// `Color(0x000D0D0D)` — прозорий варіант старого фону. Він ніде не був
/// пов'язаний із `bgBase`, тож перша ж зміна палітри мовчки лишила б
/// заголовок згасати в чужий відтінок. Такі пари має тримати тест, а не
/// пам'ять.
void main() {
  test('bgBaseFade — той самий RGB, що bgBase, з нульовою альфою', () {
    expect(
      AppColors.bgBaseFade.toARGB32() & 0x00FFFFFF,
      AppColors.bgBase.toARGB32() & 0x00FFFFFF,
      reason: 'градієнт заголовка дня згасатиме в чужий колір',
    );
    expect(AppColors.bgBaseFade.a, 0);
    expect(AppColors.bgBase.a, 1);
  });

  test('похідні акценту виводяться з нього, а не підбираються', () {
    // Сенс у тому, щоб обирати ОДИН хекс. Щойно похідні починають жити
    // власним життям, палітра знову стає набором випадкових значень —
    // рівно тим, від чого ця робота й відходила.
    final hsl = HSLColor.fromColor(AppColors.accent);
    final expected = hsl.withLightness(hsl.lightness * 0.885).toColor();

    expect(AppColors.accentPressed, expected);
    expect(AppColors.incomeSubtle.a, closeTo(0.12, 0.001));
    expect(
      AppColors.incomeSubtle.toARGB32() & 0x00FFFFFF,
      AppColors.accent.toARGB32() & 0x00FFFFFF,
    );
    expect(AppColors.income, AppColors.accent,
        reason: 'один зелений на весь застосунок (рішення 50)');

    // Приглушений зелений — теж похідна, а не другий відтінок: той
    // самий RGB, ослаблений прозорістю.
    expect(AppColors.incomeMuted.a, closeTo(0.60, 0.001));
    expect(
      AppColors.incomeMuted.toARGB32() & 0x00FFFFFF,
      AppColors.accent.toARGB32() & 0x00FFFFFF,
    );
  });

  test('приглушений зелений заміщає третинний текст, не гаснучи за нього',
      () {
    // Сенс рішення 78 саме в цьому: символ валюти й нуль міняють колір,
    // але не вагу в композиції. Якби зелений виявився помітно тьмянішим
    // за сірий, який тут стояв, «приглушено» перетворилось би на
    // «вимкнено» — а нуль не вимкнений, він просто порожній.
    double contrast(Color a, Color b) {
      final la = _composite(a, AppColors.bgBase).computeLuminance();
      final lb = b.computeLuminance();
      final (hi, lo) = la > lb ? (la, lb) : (lb, la);
      return (hi + 0.05) / (lo + 0.05);
    }

    final muted = contrast(AppColors.incomeMuted, AppColors.bgBase);
    final tertiary = contrast(AppColors.textTertiary, AppColors.bgBase);

    expect(muted, greaterThanOrEqualTo(tertiary));
    expect(
      muted,
      lessThan(contrast(AppColors.income, AppColors.bgBase)),
      reason: 'приглушений мусить лишатись тихішим за саму суму',
    );
    // Символ валюти й нуль — великий текст (≥45px, вага 700), тож поріг
    // AA для них 3.0:1, а не 4.5:1 (DS п.1.5).
    expect(muted, greaterThan(3.0));
  });

  test('акцент більше не системний зелений iOS', () {
    // Не смак, а суть рішення 68: поки тут стояло значення з коробки
    // Apple, застосунок кольором не відрізнявся ні від чого.
    expect(AppColors.accent, isNot(const Color(0xFF34C759)));
  });

  test('колір від\'ємної різниці не дорівнює кольору видалення', () {
    // ⚠️ Тут стояла сильніша перевірка: відтінки [warn] і [danger]
    // мусили розходитись щонайменше на 20°, бо червоний означає ТІЛЬКИ
    // видалення. 2026-08-16 правило свідомо призупинене на пробу —
    // від'ємна різниця отримала приглушений червоний, який за відтінком
    // від danger не відрізняється.
    //
    // Перевірка лишається в мінімальному вигляді: два різні значення
    // мають бути різними значеннями. Повний варіант треба повернути
    // разом із окремим відтінком — або викреслити правило з DS, якщо
    // проба лишається.
    expect(AppColors.warn, isNot(AppColors.danger));
  });

  test('підняте світліше за те, на чому лежить', () {
    // Модель світла (DS, розділ «Глибина»). Формулювання уточнене
    // рішенням 80: раніше тут стояв один ланцюжок base < panel <
    // surface < sheet, і він порівнював різні речі — заливку КОНТРОЛА
    // з поверхнею ШАРУ. Саме через це шторка мусила бути світлішою за
    // все, що на ній лежить, і виходила найсвітлішою площиною
    // застосунку.
    //
    // Правило одне: підняте світліше за своє тло. Ланцюжків, отже, два
    // — контроли на екрані й контроли на шторці.
    double lum(c) => c.computeLuminance() as double;

    expect(lum(AppColors.bgBase), lessThan(lum(AppColors.bgPanel)));
    expect(lum(AppColors.bgPanel), lessThan(lum(AppColors.bgSurface)));

    expect(
      lum(AppColors.bgBase),
      lessThan(lum(AppColors.bgSheet)),
      reason: 'край шторки має відділятись від затемненого екрана під нею',
    );
    expect(
      lum(AppColors.bgSheet),
      lessThan(lum(AppColors.bgSurface)),
      reason: 'контроли на шторці підняті над нею, а не втоплені в неї',
    );
    expect(
      lum(AppColors.bgSurface),
      lessThan(lum(AppColors.bgToast)),
      reason: 'тост поверх усього має лишатись найвищою поверхнею',
    );

    expect(
      lum(AppColors.bgPressed),
      lessThan(lum(AppColors.bgSurface)),
      reason: 'натиснуте має темніти, а не світлішати',
    );
    expect(
      lum(AppColors.bgPressed),
      greaterThan(lum(AppColors.bgBase)),
      reason: 'натиснута клітинка не має зливатися з фоном екрана',
    );
  });
}

/// Напівпрозорий колір поверх непрозорого фону — те, що реально бачить
/// око. Порівнювати альфа-колір із фоном напряму не можна: його власна
/// світлість про видиму нічого не каже.
Color _composite(Color fg, Color bg) {
  double mix(double a, double b) => a * fg.a + b * (1 - fg.a);
  return Color.from(
    alpha: 1,
    red: mix(fg.r, bg.r),
    green: mix(fg.g, bg.g),
    blue: mix(fg.b, bg.b),
  );
}
