import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'pressable.dart';

/// Рядок списку — один на весь застосунок.
///
/// До зведення та сама розмітка стояла в семи місцях: налаштування,
/// перемикач у налаштуваннях, вибір зі списку опцій, рядок категорії у
/// шторці, рядок валюти, рядок керування категоріями і рядок стрічки.
/// Розійшлись вони не в дрібницях: висоти були 52 і 56 без правила, а
/// відгук на натискання мав РІВНО ОДИН із семи — решта шість не
/// реагували на дотик ніяк.
///
/// **Масштабу при натисканні тут немає** — і це не спрощення. Рядок на
/// всю ширину при 0.96 зсуває обидва краї на ~8dp усередину: виглядає
/// так, ніби він тікає від пальця, а не втискається під ним. Лишається
/// підсвітка ([AppColors.pressOverlay]) — накладка, яка світлішає
/// однаково і на [AppColors.bgBase] під налаштуваннями, і на
/// [AppColors.bgSheet] під шторками.
///
/// **Затримка перед підсвіткою** ([_pressDelay]) — не смак, а вимога:
/// рядки живуть у скролі, а два з них ще й у [Dismissible]. На початку
/// свайпу чи скролу tap-розпізнавач спрацьовує першим і програє арену
/// лише за кілька кадрів, тож без затримки кожне перетягування
/// починалося б спалахом. Деталі — у [Pressable.pressDelay].
class AppRow extends StatelessWidget {
  const AppRow({
    super.key,
    required this.child,
    this.onTap,
    this.height = AppSize.row,
    this.padding = defaultPadding,
  });

  final Widget child;

  /// null — рядок не натискний (наприклад, рядок із перемикачем:
  /// натискається сам перемикач, а не рядок під ним).
  final VoidCallback? onTap;

  /// Одна з трьох щільностей: [AppSize.rowCompact], [AppSize.row],
  /// [AppSize.rowTall].
  final double height;

  /// Типове бічне поле екрана з обох боків.
  static const defaultPadding =
      EdgeInsets.symmetric(horizontal: AppSpace.side);

  /// Поле для рядка, що закінчується кнопкою-іконкою: праворуч 8 замість
  /// 20, бо решту добирає власна 48-точка самої кнопки. Без цього гліф
  /// відходить від краю на 44dp і починає плавати.
  static const actionPadding = EdgeInsets.only(left: AppSpace.side, right: 8);

  final EdgeInsets padding;

  /// Скільки чекати, перш ніж показати підсвітку. Двох кадрів вистачає,
  /// щоб арена жестів вирішилась; 80 мс — із запасом на повільний кадр.
  static const _pressDelay = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      enabled: onTap != null,
      pressDelay: _pressDelay,
      scaleOnPress: false,
      builder: (context, pressed) => AnimatedContainer(
        duration: AppDurations.of(context, AppDurations.micro),
        curve: AppCurves.standard,
        height: height,
        // Гасне в ТОЙ САМИЙ колір із нульовою альфою, а не в
        // `Colors.transparent`: [Color.lerp] інтерполює канали окремо,
        // тож перехід від прозорого ЧОРНОГО до білого серпанку йшов би
        // через сірий — на світлій половині переходу це видно.
        color: pressed
            ? AppColors.pressOverlay
            : AppColors.pressOverlay.withValues(alpha: 0),
        padding: padding,
        child: child,
      ),
    );
  }
}
