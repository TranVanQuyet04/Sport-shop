part of '../admin_design_system.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            AdminIconBadge(icon: icon!),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class AdminSportHeroPanel extends StatelessWidget {
  const AdminSportHeroPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      enabled: false,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AdminDesign.actionGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppElevation.role(AdminColors.action),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -18,
              child: Icon(
                Icons.speed_rounded,
                size: 96,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSurface extends StatelessWidget {
  const AdminSurface({
    super.key,
    required this.child,
    this.padding = AdminDesign.cardPadding,
    this.onTap,
    this.color = AdminColors.surface,
    this.hoverEnabled = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final bool hoverEnabled;

  @override
  Widget build(BuildContext context) {
    final action = Theme.of(context).colorScheme.secondary;
    return HoverLift(
      enabled: hoverEnabled && onTap != null,
      interactive: onTap != null,
      scale: 1.012,
      dy: -2,
      borderRadius: BorderRadius.circular(AdminDesign.radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AdminDesign.radius),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, action.withValues(alpha: 0.055)],
            ),
            borderRadius: BorderRadius.circular(AdminDesign.radius),
            border: Border.all(color: action.withValues(alpha: 0.14)),
            boxShadow: AppElevation.role(action),
          ),
          child: onTap == null
              ? child
              : InkWell(
                  onTap: onTap,
                  splashColor: action.withValues(alpha: 0.1),
                  highlightColor: action.withValues(alpha: 0.04),
                  child: child,
                ),
        ),
      ),
    );
  }
}

class AdminOutlinedSurface extends StatelessWidget {
  const AdminOutlinedSurface({
    super.key,
    required this.child,
    this.padding = AdminDesign.cardPadding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final action = Theme.of(context).colorScheme.secondary;
    return HoverLift(
      enabled: onTap != null,
      interactive: onTap != null,
      scale: 1.008,
      dy: -1,
      hoverShadow: true,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Material(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AdminColors.surface, action.withValues(alpha: 0.025)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: action.withValues(alpha: 0.16)),
          ),
          child: onTap == null
              ? child
              : InkWell(
                  onTap: onTap,
                  splashColor: action.withValues(alpha: 0.08),
                  highlightColor: action.withValues(alpha: 0.03),
                  child: child,
                ),
        ),
      ),
    );
  }
}

enum AdminEntityAction { edit, delete }

class AdminEntityMenu extends StatelessWidget {
  const AdminEntityMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AdminEntityAction>(
      tooltip: 'Thao tác',
      color: AdminColors.surface,
      elevation: 8,
      shadowColor: AdminColors.navy.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AdminColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case AdminEntityAction.edit:
            onEdit();
            return;
          case AdminEntityAction.delete:
            onDelete();
            return;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: AdminEntityAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 19, color: AdminColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text('Sửa'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: AdminEntityAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 19,
                color: AdminColors.danger,
              ),
              SizedBox(width: AppSpacing.sm),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    );
  }
}
