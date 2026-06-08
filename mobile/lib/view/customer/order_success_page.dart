import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 72),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Đặt hàng thành công', style: AppTextStyles.display.copyWith(fontSize: 30), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Đơn hàng #SW99281 đã được tạo. Shop sẽ xác nhận và chuẩn bị hàng trong thời gian sớm nhất.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
                      _SuccessRow(label: 'Mã đơn', value: '#SW99281'),
                      _SuccessRow(label: 'Thanh toán', value: 'COD'),
                      _SuccessRow(label: 'Tổng tiền', value: '4.930.000đ'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Theo dõi đơn hàng',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/customer/orders/SW99281/tracking'),
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
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
