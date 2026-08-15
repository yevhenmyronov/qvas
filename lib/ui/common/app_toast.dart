import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/top_light.dart';

/// Тост (Екрани п.0.2): знизу, над врізом, живе 5 секунд, зникає плавно.
/// Дія праворуч — акцентним кольором.
///
/// [clearance] піднімає тост над закріпленою знизу дією. Правило з
/// Екрани п.0.2 — «ніколи не перекриває кнопку Зберегти» — стосується
/// не лише Екрана 1: у шторці категорій знизу закріплена «Додати свою»,
/// і тост лягав рівно на неї. Оскільки в них однаковий фон і радіус,
/// разом вони читались як один зламаний елемент, а не як два.
void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  double clearance = 0,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  var dismissed = false;

  void dismiss() {
    if (dismissed) return;
    dismissed = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: AppSpace.side,
      right: AppSpace.side,
      bottom: MediaQuery.viewPaddingOf(context).bottom +
          AppSpace.side +
          clearance,
      child: _ToastBody(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                onAction();
                dismiss();
              },
        onExpired: dismiss,
      ),
    ),
  );
  overlay.insert(entry);
}

class _ToastBody extends StatefulWidget {
  const _ToastBody({
    required this.message,
    required this.onExpired,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onExpired;

  @override
  State<_ToastBody> createState() => _ToastBodyState();
}

class _ToastBodyState extends State<_ToastBody> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      setState(() => _opacity = 0);
      await Future.delayed(AppDurations.standard);
      widget.onExpired();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: AppDurations.of(context, AppDurations.standard),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgToast,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          foregroundDecoration:
              TopLight.decoration(BorderRadius.circular(AppRadius.button)),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.message,
                    style: AppText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (widget.actionLabel != null)
                GestureDetector(
                  onTap: widget.onAction,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    child: Text(
                      widget.actionLabel!,
                      style: AppText.bodyStrong
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
