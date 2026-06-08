import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminOrderAssignmentPage extends StatelessWidget {
  const AdminOrderAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Title(),
          SizedBox(height: AppSpacing.xl),
          _AssignmentCard(code: '#AV-2904', product: 'Giày Chạy Bộ Alphafly 3', location: 'Quận 1, TP. Hồ Chí Minh', priority: 'GẤP', assigned: true),
          SizedBox(height: AppSpacing.lg),
          _AssignmentCard(code: '#AV-2905', product: 'Áo Khoác Gió Pro Shield', location: 'Quận 7, TP. Hồ Chí Minh', priority: 'TIÊU CHUẨN'),
          SizedBox(height: AppSpacing.lg),
          _AssignmentCard(code: '#AV-2906', product: 'Túi Đựng Đồ Thể Thao Apex', location: 'Thủ Đức, TP. Hồ Chí Minh', priority: 'GẤP', note: 'Ưu tiên xử lý nhanh'),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Phân công đơn hàng', style: AppTextStyles.display.copyWith(fontSize: 38)),
      const SizedBox(height: AppSpacing.sm),
      Text.rich(TextSpan(text: 'Có ', style: AppTextStyles.body.copyWith(fontSize: 20), children: [TextSpan(text: '08', style: AppTextStyles.body.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 20)), const TextSpan(text: ' đơn hàng đang chờ xử lý.')]))
    ]);
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.code, required this.product, required this.location, required this.priority, this.assigned = false, this.note});

  final String code;
  final String product;
  final String location;
  final String priority;
  final bool assigned;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('MÃ ĐƠN $code', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, letterSpacing: 1))),
            Chip(label: Text(priority), backgroundColor: priority == 'GẤP' ? const Color(0xFFFCE8EE) : AppColors.surfaceMuted, labelStyle: TextStyle(color: priority == 'GẤP' ? AppColors.secondary : AppColors.textSecondary)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(product, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.textSecondary), const SizedBox(width: AppSpacing.md), Text(location, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]),
          const Divider(height: AppSpacing.xxl),
          Row(children: [
            Expanded(child: assigned ? const _AssigneeStack() : Text(note ?? 'Chưa có người xử lý', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(160, 56)), onPressed: () {}, child: const Text('Gắn người xử lý')),
          ]),
        ]),
      ),
    );
  }
}

class _AssigneeStack extends StatelessWidget {
  const _AssigneeStack();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const CircleAvatar(radius: 24, child: Icon(Icons.person)),
      CircleAvatar(radius: 24, backgroundColor: AppColors.surfaceMuted, child: Text('+3', style: AppTextStyles.subtitle)),
    ]);
  }
}
