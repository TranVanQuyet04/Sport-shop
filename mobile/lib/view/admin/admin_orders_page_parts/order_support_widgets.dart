part of '../admin_orders_page.dart';

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.primary,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: primary
              ? AdminColors.primary
              : AdminColors.surfaceMuted,
          foregroundColor: primary ? Colors.white : AdminColors.textSecondary,
          disabledBackgroundColor: AdminColors.surfaceMuted,
          disabledForegroundColor: AdminColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AdminColors.border
      ..strokeWidth = 1;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

_StatusPresentation _statusPresentation(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => const _StatusPresentation(
      label: 'Chờ xác nhận',
      foreground: _OrderPalette.pendingText,
      background: _OrderPalette.pendingSurface,
    ),
    OrderStatus.confirmed => const _StatusPresentation(
      label: 'Đã xác nhận',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.packing => const _StatusPresentation(
      label: 'Đang đóng gói',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.shipped => const _StatusPresentation(
      label: 'Đang giao',
      foreground: _OrderPalette.infoText,
      background: _OrderPalette.infoSurface,
    ),
    OrderStatus.delivered => const _StatusPresentation(
      label: 'Shipper đã giao',
      foreground: _OrderPalette.successText,
      background: _OrderPalette.successSurface,
    ),
    OrderStatus.completed => const _StatusPresentation(
      label: 'Hoàn thành',
      foreground: _OrderPalette.successText,
      background: _OrderPalette.successSurface,
    ),
    OrderStatus.cancelled => const _StatusPresentation(
      label: 'Đã hủy',
      foreground: _OrderPalette.errorText,
      background: _OrderPalette.errorSurface,
    ),
  };
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
