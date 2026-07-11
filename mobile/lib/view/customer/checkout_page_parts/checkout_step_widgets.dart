part of '../checkout_page.dart';

class _CheckoutReviewBanner extends StatelessWidget {
  const _CheckoutReviewBanner({
    required this.hasAddress,
    required this.itemCount,
    required this.paymentMethod,
  });

  final bool hasAddress;
  final int itemCount;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.textInverse.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sẵn sàng đặt hàng',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      Text(
                        'Hoàn tất các thông tin cần thiết trước khi xác nhận.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textInverse.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ReviewPill(
                  icon: hasAddress
                      ? Icons.check_circle
                      : Icons.add_location_alt_outlined,
                  label: hasAddress ? 'Đã có địa chỉ' : 'Cần địa chỉ',
                  complete: hasAddress,
                ),
                _ReviewPill(
                  icon: Icons.shopping_bag_outlined,
                  label: '$itemCount sản phẩm',
                  complete: itemCount > 0,
                ),
                _ReviewPill(
                  icon: Icons.payments_outlined,
                  label: _paymentLabel(paymentMethod),
                  complete: paymentMethod.isNotEmpty,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String value) {
    return switch (value) {
      'COD' => 'COD',
      'VNPAY' => 'VNPay',
      'MOMO' => 'Ví MoMo',
      _ => 'Chọn thanh toán',
    };
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({
    required this.icon,
    required this.label,
    required this.complete,
  });

  final IconData icon;
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final foreground = complete ? AppColors.textInverse : AppColors.primary;
    final background = complete
        ? AppColors.secondary
        : AppColors.textInverse.withValues(alpha: 0.92);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, this.onTap});

  final String title;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineCheckoutError extends StatelessWidget {
  const _InlineCheckoutError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
