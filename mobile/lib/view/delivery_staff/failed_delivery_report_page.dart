import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class FailedDeliveryReportPage extends StatefulWidget {
  const FailedDeliveryReportPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<FailedDeliveryReportPage> createState() =>
      _FailedDeliveryReportPageState();
}

class _FailedDeliveryReportPageState extends State<FailedDeliveryReportPage> {
  String _reason = 'Khách không nghe máy';
  bool _hasPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Báo cáo giao thất bại',
            style: AppTextStyles.display.copyWith(fontSize: 30),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Đơn #${widget.orderId} cần ghi nhận lý do rõ ràng trước khi chuyển FAILED hoặc RETURNED.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _DemoBanner(),
          const SizedBox(height: AppSpacing.xl),
          Text('Lý do', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          ...[
            'Khách không nghe máy',
            'Sai địa chỉ giao hàng',
            'Khách hẹn giao lại',
            'Khách từ chối nhận hàng',
          ].map(
            (reason) => _ReasonTile(
              label: reason,
              selected: _reason == reason,
              onTap: () => setState(() => _reason = reason),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ảnh minh chứng', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: () => setState(() => _hasPhoto = !_hasPhoto),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: _hasPhoto ? AppColors.success : AppColors.border,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasPhoto
                          ? Icons.check_circle_outline
                          : Icons.add_a_photo_outlined,
                      color: _hasPhoto
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _hasPhoto
                          ? 'Đã thêm ảnh minh chứng mẫu'
                          : 'Chụp hoặc tải ảnh lên',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            label: 'Ghi chú chi tiết',
            prefixIcon: Icons.edit_note_outlined,
            maxLines: 4,
            hintText: 'Nhập ghi chú cho shop/admin...',
          ),
          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Gửi báo cáo FAILED',
                icon: Icons.report_problem_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => _submit('FAILED'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Đánh dấu RETURNED',
                icon: Icons.keyboard_return_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => _submit('RETURNED'),
              ),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã ghi nhận $status cho đơn #${widget.orderId}: $_reason.',
        ),
      ),
    );
    context.go(AppRoutes.deliveryAssignedOrders);
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Báo cáo hiện lưu demo trên UI. Backend sau này cần endpoint lưu FAILED/RETURNED và ảnh minh chứng.',
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: selected ? const Color(0xFFFCE8EE) : AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.secondary : AppColors.textSecondary,
          ),
          title: Text(
            label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
