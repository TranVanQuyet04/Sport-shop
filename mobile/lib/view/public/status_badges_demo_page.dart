import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import '../../model/common/order_status.dart';

class StatusBadgesDemoPage extends StatelessWidget {
  const StatusBadgesDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Badges')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Trạng thái đơn hàng', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Badge dùng chung cho orderStatus và deliveryStatus khi nối API.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Order Status', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: OrderStatus.values.map((status) => OrderStatusBadge(status: status)).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Delivery Status', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: DeliveryStatus.values.map((status) => DeliveryStatusBadge(status: status)).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ví dụ từ API', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          _ApiExampleRow(
            rawValue: 'PACKING',
            child: OrderStatusBadge(status: OrderStatus.fromApi('PACKING')),
          ),
          _ApiExampleRow(
            rawValue: 'OUT_FOR_DELIVERY',
            child: DeliveryStatusBadge(status: DeliveryStatus.fromApi('OUT_FOR_DELIVERY')),
          ),
          _ApiExampleRow(
            rawValue: 'FAILED',
            child: DeliveryStatusBadge(status: DeliveryStatus.fromApi('FAILED')),
          ),
        ],
      ),
    );
  }
}

class _ApiExampleRow extends StatelessWidget {
  const _ApiExampleRow({required this.rawValue, required this.child});

  final String rawValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(rawValue, style: AppTextStyles.subtitle)),
          child,
        ],
      ),
    );
  }
}
