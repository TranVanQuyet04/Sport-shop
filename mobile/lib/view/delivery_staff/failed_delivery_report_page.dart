import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class FailedDeliveryReportPage extends StatelessWidget {
  const FailedDeliveryReportPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Báo cáo giao thất bại', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text('Đơn #$orderId cần ghi nhận lý do rõ ràng trước khi chuyển FAILED hoặc RETURNED.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          Text('Lý do', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          const _ReasonTile(label: 'Khách không nghe máy', selected: true),
          const _ReasonTile(label: 'Sai địa chỉ giao hàng'),
          const _ReasonTile(label: 'Khách hẹn giao lại'),
          const _ReasonTile(label: 'Khách từ chối nhận hàng'),
          const SizedBox(height: AppSpacing.xl),
          Text('Ảnh minh chứng', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AppColors.secondary),
                  SizedBox(height: AppSpacing.sm),
                  Text('Chụp hoặc tải ảnh lên'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ghi chú chi tiết', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú cho shop/admin...',
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
              AppButton(label: 'Gửi báo cáo FAILED', icon: Icons.report_problem_outlined, variant: AppButtonVariant.secondary, onPressed: () {}),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Đánh dấu RETURNED', icon: Icons.keyboard_return_outlined, variant: AppButtonVariant.outline, onPressed: () {}),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFCE8EE) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: selected ? AppColors.secondary : AppColors.border),
      ),
      child: ListTile(
        leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.secondary : AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
