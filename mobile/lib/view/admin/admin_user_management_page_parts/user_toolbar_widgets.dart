part of '../admin_user_management_page.dart';

class _UserCountBadge extends StatelessWidget {
  const _UserCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$count tài khoản',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _UserToolbar extends StatelessWidget {
  const _UserToolbar({
    required this.controller,
    required this.selectedRole,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.totalUsers,
    required this.activeUsers,
    required this.adminUsers,
  });

  final TextEditingController controller;
  final String selectedRole;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onRoleChanged;
  final int totalUsers;
  final int activeUsers;
  final int adminUsers;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserMetric(label: 'Tổng', value: totalUsers),
              const SizedBox(width: AppSpacing.sm),
              _UserMetric(label: 'Hoạt động', value: activeUsers),
              const SizedBox(width: AppSpacing.sm),
              _UserMetric(label: 'Admin', value: adminUsers),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Tìm tên hoặc email...',
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RoleChip(
                  label: 'Tất cả',
                  value: 'ALL',
                  active: selectedRole == 'ALL',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Admin',
                  value: 'ADMIN',
                  active: selectedRole == 'ADMIN',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Shipper',
                  value: 'SHIPPER',
                  active: selectedRole == 'SHIPPER',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Member',
                  value: 'MEMBER',
                  active: selectedRole == 'MEMBER',
                  onSelected: onRoleChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMetric extends StatelessWidget {
  const _UserMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AdminColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: AppTextStyles.title.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
