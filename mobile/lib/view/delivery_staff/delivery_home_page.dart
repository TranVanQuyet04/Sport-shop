import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class DeliveryHomePage extends StatelessWidget {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Chào buổi sáng, Minh', style: AppTextStyles.display.copyWith(fontSize: 32)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ca hôm nay có 14 đơn cần xử lý. Ưu tiên nhận hàng và cập nhật trạng thái đúng thời gian.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _HeroDeliveryCard(),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(child: _MetricCard(label: 'Cần nhận', value: '05', icon: Icons.inventory_2_outlined)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricCard(label: 'Đang giao', value: '07', icon: Icons.local_shipping_outlined)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(child: _MetricCard(label: 'Thất bại', value: '01', icon: Icons.warning_amber_outlined, isAlert: true)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricCard(label: 'Hoàn trả', value: '01', icon: Icons.keyboard_return_outlined)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Tác vụ nhanh', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Xem đơn được giao',
            icon: Icons.assignment_outlined,
            onPressed: () => context.go(AppRoutes.deliveryAssignedOrders),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Quét mã đơn hàng',
            icon: Icons.qr_code_scanner,
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Đơn ưu tiên', style: AppTextStyles.title)),
              TextButton(
                onPressed: () => context.go(AppRoutes.deliveryAssignedOrders),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          _DeliveryTile(
            code: '#AV-8842',
            address: '12 Nguyễn Trãi, Quận 1',
            status: 'OUT_FOR_DELIVERY',
            time: 'Giao trước 16:30',
            onTap: () => context.go('/delivery-staff/orders/AV-8842/status'),
          ),
          _DeliveryTile(
            code: '#AV-8846',
            address: '88 Lê Văn Sỹ, Quận 3',
            status: 'PICKED_UP',
            time: 'Nhận lúc 10:15',
            onTap: () => context.go('/delivery-staff/orders/AV-8846/status'),
          ),
        ],
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 0),
    );
  }
}

class _HeroDeliveryCard extends StatelessWidget {
  const _HeroDeliveryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tỷ lệ giao thành công', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSpacing.sm),
                Text('98%', style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 42)),
                const SizedBox(height: AppSpacing.sm),
                Text('Bạn đang đứng top 2 trong ca hôm nay.', style: AppTextStyles.body.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.delivery_dining, color: Colors.white, size: 38),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, this.isAlert = false});

  final String label;
  final String value;
  final IconData icon;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppColors.warning : AppColors.secondary;
    return Container(
      height: 128,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 30)),
        ],
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.code, required this.address, required this.status, required this.time, required this.onTap});

  final String code;
  final String address;
  final String status;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.secondary,
          child: Icon(Icons.location_on_outlined),
        ),
        title: Text('$code - $status', style: AppTextStyles.subtitle),
        subtitle: Text('$address\n$time'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
