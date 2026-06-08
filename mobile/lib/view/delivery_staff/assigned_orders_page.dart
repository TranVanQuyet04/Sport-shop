import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class AssignedOrdersPage extends StatelessWidget {
  const AssignedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Đơn hàng được giao', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text('Theo dõi các đơn đã bàn giao cho bạn trong ca hiện tại.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm mã đơn hoặc địa chỉ',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.tune),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FilterChip(label: 'Tất cả', selected: true),
              _FilterChip(label: 'WAITING_PICKUP'),
              _FilterChip(label: 'IN_TRANSIT'),
              _FilterChip(label: 'OUT_FOR_DELIVERY'),
              _FilterChip(label: 'FAILED'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _AssignedOrderCard(
            code: '#AV-8842',
            customer: 'Trần Hoàng Long',
            address: '12 Nguyễn Trãi, Quận 1, TP.HCM',
            status: 'OUT_FOR_DELIVERY',
            phone: '0901 234 567',
            onTap: () => context.go('/delivery-staff/orders/AV-8842/status'),
          ),
          _AssignedOrderCard(
            code: '#AV-8846',
            customer: 'Nguyễn Minh Anh',
            address: '88 Lê Văn Sỹ, Quận 3, TP.HCM',
            status: 'PICKED_UP',
            phone: '0912 345 678',
            onTap: () => context.go('/delivery-staff/orders/AV-8846/status'),
          ),
          _AssignedOrderCard(
            code: '#AV-8851',
            customer: 'Phạm Quốc Huy',
            address: '20 Võ Văn Ngân, TP. Thủ Đức',
            status: 'WAITING_PICKUP',
            phone: '0988 777 666',
            onTap: () => context.go('/delivery-staff/orders/AV-8851/status'),
          ),
        ],
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 1),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? AppColors.primary : AppColors.surface,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w800),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}

class _AssignedOrderCard extends StatelessWidget {
  const _AssignedOrderCard({
    required this.code,
    required this.customer,
    required this.address,
    required this.status,
    required this.phone,
    required this.onTap,
  });

  final String code;
  final String customer;
  final String address;
  final String status;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(code, style: AppTextStyles.title)),
              Chip(label: Text(status), backgroundColor: const Color(0xFFFCE8EE), labelStyle: const TextStyle(color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(customer, style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(address, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.call), label: Text(phone))),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
