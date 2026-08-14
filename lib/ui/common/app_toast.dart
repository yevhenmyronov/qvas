import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Тост (Екрани п.0.2): знизу, над врізом, живе 5 секунд, зникає плавно.
/// Дія праворуч — акцентним кольором.
void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
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
      bottom: MediaQuery.viewPaddingOf(context).bottom + AppSpace.side,
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
            color: AppColors.bgSurfaceHigh,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
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
