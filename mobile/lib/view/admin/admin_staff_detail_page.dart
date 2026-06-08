import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AdminStaffDetailPage extends StatelessWidget {
  const AdminStaffDetailPage({super.key, required this.staffId});

  final String staffId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('CHI TIẾT NHÂN VIÊN'),
        centerTitle: true,
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.more_vert))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(radius: 82, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white, size: 90)),
                Positioned(
                  right: 4,
                  bottom: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Nguyễn Hoàng Nam', textAlign: TextAlign.center, style: AppTextStyles.display.copyWith(fontSize: 38)),
          const SizedBox(height: AppSpacing.sm),
          Text('CHUYÊN VIÊN VẬN HÀNH', textAlign: TextAlign.center, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, letterSpacing: 3)),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Trạng thái làm việc', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(width: AppSpacing.md),
                Switch(value: true, onChanged: (_) {}, activeThumbColor: AppColors.secondary),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['THÔNG TIN', 'LỊCH LÀM VIỆC', 'HIỆU SUẤT'].map((e) => Text(e, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900))).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 3, width: 120, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(children: [
                _InfoRow(label: 'MÃ NHÂN VIÊN', value: staffId.isEmpty ? 'AV-99283' : staffId),
                const Divider(height: AppSpacing.xl),
                const _InfoRow(label: 'EMAIL', value: 'nam.nguyen@apex.com'),
                const Divider(height: AppSpacing.xl),
                const _InfoRow(label: 'SỐ ĐIỆN THOẠI', value: '090 123 4567'),
                const Divider(height: AppSpacing.xl),
                const _InfoRow(label: 'NGÀY GIA NHẬP', value: '15/05/2023'),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            Expanded(child: AppButton(label: 'LÀM MỚI MẬT KHẨU', variant: AppButtonVariant.outline, onPressed: () {})),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppButton(label: 'SỬA HỒ SƠ', variant: AppButtonVariant.secondary, icon: Icons.edit, onPressed: () {})),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
      Text(value, style: AppTextStyles.body.copyWith(fontSize: 18)),
    ]);
  }
}
