part of '../checkout_page.dart';

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.totalItemsPrice,
    required this.shippingFee,
    required this.discount,
    required this.totalPayment,
  });

  final int totalItemsPrice;
  final int shippingFee;
  final int discount;
  final int totalPayment;

  @override
  Widget build(BuildContext context) {
    final totalText = NumberFormat.decimalPattern('vi_VN').format(totalPayment);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _PriceRow(label: 'Tổng tiền hàng', value: _money(totalItemsPrice)),
            _PriceRow(label: 'Phí vận chuyển', value: _money(shippingFee)),
            _PriceRow(
              label: 'Giảm giá',
              value: '-${_money(discount)}',
              valueColor: AppColors.secondary,
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tổng thanh toán',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '$totalTextđ',
                  style: AppTextStyles.display.copyWith(fontSize: 30),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Số tiền này sẽ được gửi sang backend khi tạo đơn hàng.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _money(int value) {
    return '${NumberFormat.decimalPattern('vi_VN').format(value)}đ';
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _WhitePanel extends StatelessWidget {
  const _WhitePanel({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
