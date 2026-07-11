// ignore_for_file: unused_element

part of '../admin_dashboard_page.dart';

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Thao tác nhanh',
          subtitle: 'Truy cập nhanh các nghiệp vụ thường dùng',
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: columns == 4 ? 1.05 : 1.45,
              ),
              itemBuilder: (context, index) =>
                  _QuickActionCard(data: actions[index]),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.015,
      dy: -2,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Material(
        color: _DashboardColors.surface,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: data.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBadge(
                  icon: data.icon,
                  background: data.softColor,
                  foreground: data.color,
                  size: 42,
                  iconSize: 21,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: _DashboardColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayOverviewSection extends StatelessWidget {
  const _TodayOverviewSection({
    required this.pendingOrders,
    required this.pendingOrdersCount,
    required this.newUsers,
  });

  final String pendingOrders;
  final int pendingOrdersCount;
  final String newUsers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Tổng quan hôm nay',
          subtitle: 'Các cập nhật mới nhất từ hệ thống',
        ),
        const SizedBox(height: AppSpacing.md),
        _ActivityCard(
          icon: Icons.inventory_2_outlined,
          title: '$pendingOrders đơn chờ xử lý',
          subtitle: 'Cần kiểm tra và xác nhận trạng thái đơn hàng.',
          accent: _DashboardColors.orange,
          softAccent: _DashboardColors.orangeSoft,
          meta: 'Đơn hàng',
          highlighted: pendingOrdersCount > 0,
        ),
        const SizedBox(height: AppSpacing.md),
        _ActivityCard(
          icon: Icons.person_add_alt_1_outlined,
          title: '$newUsers người dùng mới',
          subtitle: 'Tài khoản mới được tạo trong ngày hôm nay.',
          accent: _DashboardColors.blue,
          softAccent: _DashboardColors.blueSoft,
          meta: 'Người dùng',
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.softAccent,
    required this.meta,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color softAccent;
  final String meta;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.008,
      dy: -1,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _DashboardColors.surface,
          borderRadius: BorderRadius.circular(_DashboardStyle.radius),
          boxShadow: _DashboardStyle.cardShadow,
        ),
        child: Row(
          children: [
            _IconBadge(
              icon: icon,
              background: softAccent,
              foreground: accent,
              size: 44,
              iconSize: 21,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: _DashboardColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: _DashboardColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: highlighted ? softAccent : _DashboardColors.subtle,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meta,
                style: AppTextStyles.caption.copyWith(
                  color: highlighted ? accent : _DashboardColors.muted,
                  fontSize: 10,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            color: _DashboardColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: _DashboardColors.muted),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.minHeight,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.006,
      dy: -1,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight ?? 0),
        padding: padding,
        decoration: BoxDecoration(
          color: _DashboardColors.surface,
          borderRadius: BorderRadius.circular(_DashboardStyle.radius),
          boxShadow: _DashboardStyle.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 44,
    this.iconSize = 22,
    this.glowColor,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
        boxShadow: glowColor == null
            ? null
            : [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.32),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: foreground, size: iconSize),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _DashboardColors.redSoft,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _DashboardColors.red),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: _DashboardColors.red,
              ),
            ),
          ),
          TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
