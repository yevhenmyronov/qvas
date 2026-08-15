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

  test('рівні поверхонь ідуть за зростанням світлості', () {
    // Модель світла (DS, розділ «Глибина»): що вище шар, то світліша
    // поверхня. Натиснута піднята поверхня втоплена, тобто темніша за
    // свій спокійний стан.
    double lum(c) => c.computeLuminance() as double;

    expect(lum(AppColors.bgBase), lessThan(lum(AppColors.bgPanel)));
    expect(lum(AppColors.bgPanel), lessThan(lum(AppColors.bgSurface)));
    expect(lum(AppColors.bgSurface), lessThan(lum(AppColors.bgSheet)));
    expect(
      lum(AppColors.bgSheet),
      lessThan(lum(AppColors.bgToast)),
      reason: 'тост поверх шторки має лишатись окремою поверхнею',
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
