import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../model/customer/order_model.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, this.order, this.paymentUrl});

  final OrderModel? order;
  final String? paymentUrl;

  @override
  Widget build(BuildContext context) {
    final order = this.order;
    final orderId = order?.id ?? '';
    final paymentMethod = order?.paymentMethod ?? '';
    final totalAmount = order == null
        ? ''
        : '${NumberFormat.decimalPattern('vi_VN').format(order.totalAmount)}đ';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFFBF3),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 72,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Đặt hàng thành công',
                style: AppTextStyles.display.copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                orderId.isEmpty
                    ? 'Đơn hàng đã được tạo trên backend.'
                    : 'Đơn hàng #$orderId đã được tạo. Shop sẽ xác nhận và chuẩn bị hàng sớm nhất.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _SuccessRow(
                        label: 'Mã đơn',
                        value: orderId.isEmpty ? '-' : '#$orderId',
                      ),
                      _SuccessRow(
                        label: 'Thanh toán',
                        value: paymentMethod.isEmpty ? '-' : paymentMethod,
                      ),
                      _SuccessRow(
                        label: 'Tổng tiền',
                        value: totalAmount.isEmpty ? '-' : totalAmount,
                      ),
                      if ((paymentUrl ?? '').isNotEmpty)
                        _SuccessRow(label: 'VNPay URL', value: paymentUrl!),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if ((paymentUrl ?? '').isNotEmpty) ...[
                AppButton(
                  label: 'Mở liên kết VNPay',
                  icon: Icons.account_balance_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _openPaymentUrl(context, paymentUrl!),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: 'Theo dõi đơn hàng',
                variant: AppButtonVariant.secondary,
                onPressed: orderId.isEmpty
                    ? () => context.go(AppRoutes.orders)
                    : () => context.go('/customer/orders/$orderId/tracking'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Tiếp tục mua sắm',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(AppRoutes.customerHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPaymentUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid payment URL.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
