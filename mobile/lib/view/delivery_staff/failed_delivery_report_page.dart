import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
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
  final _noteController = TextEditingController();
  String _reason = 'Khach khong nghe may';
  bool _hasPhoto = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Bao cao giao that bai',
            style: AppTextStyles.display.copyWith(fontSize: 30),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Don #${widget.orderId} se duoc luu truc tiep len backend.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ly do', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.md),
          ...[
            'Khach khong nghe may',
            'Sai dia chi giao hang',
            'Khach hen giao lai',
            'Khach tu choi nhan hang',
          ].map(
            (reason) => _ReasonTile(
              label: reason,
              selected: _reason == reason,
              onTap: () => setState(() => _reason = reason),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Anh minh chung', style: AppTextStyles.subtitle),
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
                          ? 'Da dinh kem anh minh chung'
                          : 'Danh dau co anh minh chung',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _noteController,
            label: 'Ghi chu chi tiet',
            prefixIcon: Icons.edit_note_outlined,
            maxLines: 4,
            hintText: 'Nhap ghi chu cho shop/admin...',
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
                label: 'Gui bao cao FAILED',
                icon: Icons.report_problem_outlined,
                variant: AppButtonVariant.secondary,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _submit('FAILED'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Danh dau RETURNED',
                icon: Icons.keyboard_return_outlined,
                variant: AppButtonVariant.outline,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _submit('RETURNED'),
              ),
              const SizedBox(height: AppSpacing.md),
              const DeliveryBottomNav(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(String status) async {
    setState(() => _isSubmitting = true);
    try {
      await AppDependencies.instance.apiClient.postJson(
        '/orders/${widget.orderId.replaceAll('#', '')}/delivery-reports',
        data: {
          'status': status,
          'reason': _reason,
          'note': _noteController.text.trim(),
          'evidenceImageUrl': _hasPhoto ? 'mobile://evidence-attached' : null,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da luu bao cao $status cho don #${widget.orderId}.')),
      );
      context.go(AppRoutes.deliveryAssignedOrders);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
