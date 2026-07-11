part of '../admin_user_management_page.dart';

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullName.trim().isEmpty
        ? user.email
        : user.fullName.trim();
    final initial = displayName.isEmpty
        ? '?'
        : displayName.characters.first.toUpperCase();
    final role = RoleMapper.normalize(user.roleName);

    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AdminColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      initial,
                      style: AppTextStyles.title.copyWith(
                        color: AdminColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: user.status
                            ? AdminColors.success
                            : AdminColors.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AdminColors.surface,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AdminEntityMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _UserPill(
                label: role.isEmpty ? user.roleName : role,
                icon: Icons.admin_panel_settings_outlined,
                color: AdminColors.primary,
                background: AdminColors.primarySoft,
              ),
              const SizedBox(width: AppSpacing.sm),
              _UserPill(
                label: user.status ? 'Hoạt động' : 'Vô hiệu',
                icon: user.status
                    ? Icons.check_circle_outline
                    : Icons.block_outlined,
                color: user.status ? AdminColors.success : AdminColors.danger,
                background: user.status
                    ? AdminColors.successSoft
                    : AdminColors.dangerSoft,
              ),
            ],
          ),
          if (user.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AdminColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  user.phoneNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
