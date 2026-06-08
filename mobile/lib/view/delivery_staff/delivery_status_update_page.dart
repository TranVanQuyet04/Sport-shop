import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryStatusUpdatePage extends StatelessWidget {
  const DeliveryStatusUpdatePage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Cập nhật vận chuyển', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text('Đơn #$orderId', style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.map_outlined, color: Colors.white24, size: 120)),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Text(
                    'Lộ trình: Cửa hàng Quận 1 -> 12 Nguyễn Trãi',
                    style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Trạng thái giao hàng', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _DeliveryStep(title: 'WAITING_PICKUP', subtitle: 'Chờ nhận hàng từ cửa hàng', done: true),
          const _DeliveryStep(title: 'PICKED_UP', subtitle: 'Đã nhận kiện hàng', done: true),
          const _DeliveryStep(title: 'IN_TRANSIT', subtitle: 'Đang di chuyển đến khu vực giao', done: true),
          const _DeliveryStep(title: 'OUT_FOR_DELIVERY', subtitle: 'Đang giao cho khách', active: true),
          const _DeliveryStep(title: 'DELIVERED', subtitle: 'Giao thành công cho khách'),
          const SizedBox(height: AppSpacing.xl),
          Text('Ghi chú nhanh', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Khách hẹn nhận sau 15 phút...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(label: 'Cập nhật: Đã giao thành công', icon: Icons.check_circle_outline, onPressed: () {}),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Báo cáo giao thất bại',
                icon: Icons.report_problem_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/delivery-staff/orders/$orderId/failed-report'),
              ),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({required this.title, required this.subtitle, this.done = false, this.active = false});

  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.secondary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Icon(done ? Icons.check : Icons.circle, color: Colors.white, size: 14),
            ),
            Container(width: 2, height: 54, color: AppColors.border),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFCE8EE) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: active ? AppColors.secondary : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
