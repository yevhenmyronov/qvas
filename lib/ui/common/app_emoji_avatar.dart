import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Кружечок емодзі в рядку списку: [AppSize.avatar] на [AppColors.bgSurface].
///
/// Три місця (рядок стрічки, рядок шторки категорій, рядок керування
/// категоріями) тримали три однакові копії — тобто три місця, де
/// достатньо було розійтись одному числу.
///
/// **Граней [EdgeLight] тут немає, і це рішення про продуктивність, а не
/// про смак** (рішення 60). На 40dp при 8.5% світла дуга по верхньому
/// краю кружечка невидима, а коштує вона `Path` і шейдер на кожен рядок
/// на кожну перемальовку — у стрічці, тобто в єдиному місці застосунку,
/// яке скролиться й уже несе `ImageFiltered` ефекту зникнення.
/// Оскільки в трьох місцях кружечок один і той самий, вимикати грані
/// вибірково нема сенсу: різницю не видно, а розбіжність з'явилась би.
class AppEmojiAvatar extends StatelessWidget {
  const AppEmojiAvatar({
    super.key,
    required this.emoji,
    this.size = AppSize.avatar,
    this.fontSize = 20,
  });

  final String emoji;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: fontSize)),
    );
  }
}
