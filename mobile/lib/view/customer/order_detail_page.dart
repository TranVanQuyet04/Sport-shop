import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final total = NumberFormat.decimalPattern('vi_VN').format(4930000);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(child: Text('#$orderId', style: AppTextStyles.display.copyWith(fontSize: 30))),
              const StatusBadge(label: 'ĐANG GIAO', tone: StatusTone.error),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Đặt lúc 14:20, 22 Tháng 05, 2024', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          const _Panel(
            title: 'Địa chỉ nhận hàng',
            child: Text('Nguyễn Văn A • 090 123 4567\n123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Panel(
            title: 'Sản phẩm',
            child: Row(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 42),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nike Air Max 270 React', style: AppTextStyles.subtitle),
                      Text('Size: 42 | Màu: Đỏ/Đen', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                      Text('3.250.000đ x1', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Panel(
            title: 'Thanh toán',
            child: Column(
              children: [
                const _PriceLine(label: 'Tổng tiền hàng', value: '4.950.000đ'),
                const _PriceLine(label: 'Phí vận chuyển', value: '30.000đ'),
                const _PriceLine(label: 'Giảm giá', value: '-50.000đ'),
                const Divider(),
                Row(
                  children: [
                    Text('Tổng thanh toán', style: AppTextStyles.subtitle),
                    const Spacer(),
                    Text('$totalđ', style: AppTextStyles.title.copyWith(color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Theo dõi hành trình',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/customer/orders/$orderId/tracking'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Xác nhận đã nhận hàng',
            variant: AppButtonVariant.outline,
            onPressed: () => context.go('/customer/orders/$orderId/confirm-received'),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
