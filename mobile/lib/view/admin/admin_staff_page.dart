import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _StaffHeader(),
          SizedBox(height: AppSpacing.xl),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm kiếm tên, email hoặc mã nhân viên...')),
          SizedBox(height: AppSpacing.lg),
          Row(children: [
            _RoleChip(label: 'Bộ lọc', active: true, icon: Icons.filter_list),
            SizedBox(width: AppSpacing.md),
            _RoleChip(label: 'SHOP_STAFF'),
            SizedBox(width: AppSpacing.md),
            _RoleChip(label: 'DELIVERY_STAFF'),
          ]),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => context.go(AppRoutes.adminShiftPlanning), icon: const Icon(Icons.calendar_month), label: const Text('Lịch trực'))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: OutlinedButton.icon(onPressed: () => context.go(AppRoutes.adminStaffPerformance), icon: const Icon(Icons.query_stats), label: const Text('Hiệu suất'))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => context.go(AppRoutes.adminOrderAssignment), icon: const Icon(Icons.assignment_ind), label: const Text('Phân công'))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: OutlinedButton.icon(onPressed: () => context.go(AppRoutes.adminLeaveManagement), icon: const Icon(Icons.event_busy), label: const Text('Nghỉ phép'))),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _StaffCard(name: 'Lê Minh Đức', role: 'SHOP_STAFF', active: true, accent: AppColors.secondary, onTap: () => context.go('/admin/staff/AV-99283')),
          SizedBox(height: AppSpacing.lg),
          _StaffCard(name: 'Nguyễn Thu Hà', role: 'DELIVERY_STAFF', active: true, accent: AppColors.primary, onTap: () => context.go('/admin/staff/AV-99284')),
          SizedBox(height: AppSpacing.lg),
          _StaffCard(name: 'Trần Hoàng Nam', role: 'DELIVERY_STAFF', active: false, accent: AppColors.textSecondary, onTap: () => context.go('/admin/staff/AV-99285')),
          SizedBox(height: AppSpacing.lg),
          _StaffCard(name: 'Phạm Minh Anh', role: 'SHOP_STAFF', active: true, accent: AppColors.secondary, onTap: () => context.go('/admin/staff/AV-99286')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _StaffHeader extends StatelessWidget {
  const _StaffHeader();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quản lý Nhân viên', style: AppTextStyles.display.copyWith(fontSize: 36)),
      const SizedBox(height: AppSpacing.sm),
      Text('Vận hành đội ngũ hiệu suất cao của bạn.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18)),
    ]);
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.active = false, this.icon});

  final String label;
  final bool active;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: AppSpacing.sm)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.w900))),
        ]),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.name, required this.role, required this.active, required this.accent, this.onTap});

  final String name;
  final String role;
  final bool active;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(children: [
          CircleAvatar(radius: 48, backgroundColor: AppColors.surfaceMuted, foregroundColor: accent, child: const Icon(Icons.person, size: 44)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppTextStyles.display.copyWith(fontSize: 26)),
            Text(role, style: AppTextStyles.subtitle.copyWith(color: accent)),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              CircleAvatar(radius: 5, backgroundColor: active ? AppColors.success : AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(active ? 'Đang hoạt động' : 'Ngừng hoạt động', style: AppTextStyles.body.copyWith(color: active ? AppColors.textPrimary : AppColors.textSecondary)),
            ]),
          ])),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ]),
        ),
      ),
    );
  }
}
