part of '../admin_delivery_monitoring_page.dart';

class DeliveryStatusStepper extends StatelessWidget {
  const DeliveryStatusStepper({super.key, required this.status});

  final DeliveryStatus status;

  int get _currentStep {
    return switch (status) {
      DeliveryStatus.waitingPickup || DeliveryStatus.pickedUp => 0,
      DeliveryStatus.inTransit ||
      DeliveryStatus.outForDelivery ||
      DeliveryStatus.failed ||
      DeliveryStatus.returned => 1,
      DeliveryStatus.delivered => 2,
    };
  }

  @override
  Widget build(BuildContext context) {
    final complete = status == DeliveryStatus.delivered;
    final issue =
        status == DeliveryStatus.failed || status == DeliveryStatus.returned;
    final activeColor = complete
        ? const Color(0xFF16A34A)
        : issue
        ? const Color(0xFFBE123C)
        : AdminColors.primary;

    return Column(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index.isOdd) {
              final connectorStep = index ~/ 2;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  color: connectorStep < _currentStep
                      ? activeColor
                      : AdminColors.border,
                ),
              );
            }
            final step = index ~/ 2;
            final reached = step <= _currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? activeColor : AdminColors.surface,
                border: Border.all(
                  color: reached ? activeColor : AdminColors.border,
                  width: 2,
                ),
              ),
              child: reached
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _StepLabel(
              label: 'Xác nhận',
              active: _currentStep >= 0,
              color: activeColor,
            ),
            _StepLabel(
              label: issue ? 'Có sự cố' : 'Đang giao',
              active: _currentStep >= 1,
              color: activeColor,
              centered: true,
            ),
            _StepLabel(
              label: 'Hoàn thành',
              active: _currentStep >= 2,
              color: activeColor,
              trailing: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.label,
    required this.active,
    required this.color,
    this.centered = false,
    this.trailing = false,
  });

  final String label;
  final bool active;
  final Color color;
  final bool centered;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: centered
            ? TextAlign.center
            : trailing
            ? TextAlign.end
            : TextAlign.start,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: active ? color : AdminColors.textSecondary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

({String label, Color background, Color foreground}) _statusPresentation(
  DeliveryStatus status,
) {
  return switch (status) {
    DeliveryStatus.waitingPickup => (
      label: 'Chờ lấy hàng',
      background: const Color(0xFFFEF3C7),
      foreground: const Color(0xFF92400E),
    ),
    DeliveryStatus.pickedUp => (
      label: 'Đã lấy hàng',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.inTransit => (
      label: 'Đang vận chuyển',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.outForDelivery => (
      label: 'Đang giao',
      background: AdminColors.primarySoft,
      foreground: AdminColors.primaryPressed,
    ),
    DeliveryStatus.delivered => (
      label: 'Đã giao',
      background: const Color(0xFFDCFCE7),
      foreground: const Color(0xFF166534),
    ),
    DeliveryStatus.failed => (
      label: 'Giao thất bại',
      background: const Color(0xFFFFE4E6),
      foreground: const Color(0xFFBE123C),
    ),
    DeliveryStatus.returned => (
      label: 'Hoàn trả',
      background: const Color(0xFFFFE4E6),
      foreground: const Color(0xFFBE123C),
    ),
  };
}
