// ──────────────────────────────────────────────────────────────────────────────
//  Quick Actions (Admin Dashboard part file)
// ──────────────────────────────────────────────────────────────────────────────
part of '../admin_dashboard_page.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.add_box_outlined,
        label: 'Thêm SP',
        color: const Color(0xFF2563EB),
        route: AppRoutes.adminAddProduct,
      ),
      _ActionItem(
        icon: Icons.receipt_long_outlined,
        label: 'Đơn hàng',
        color: const Color(0xFF16A34A),
        route: AppRoutes.adminOrders,
      ),
      _ActionItem(
        icon: Icons.people_outlined,
        label: 'Nhân viên',
        color: AdminColors.action,
        route: AppRoutes.adminStaff,
      ),
      _ActionItem(
        icon: Icons.bar_chart_outlined,
        label: 'Báo cáo',
        color: const Color(0xFFF97316),
        route: AppRoutes.adminRevenue,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Truy cập nhanh',
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Đi thẳng đến các nghiệp vụ quản trị thường dùng',
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: actions
              .map(
                (a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: HoverLift(
                      scale: 1.02,
                      dy: -2,
                      borderRadius: BorderRadius.circular(
                        _DashboardStyle.radius,
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          _DashboardStyle.radius,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.go(a.route),
                          splashColor: a.color.withValues(alpha: 0.12),
                          highlightColor: a.color.withValues(alpha: 0.05),
                          child: Ink(
                            height: 86,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  a.color.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                _DashboardStyle.radius,
                              ),
                              border: Border.all(
                                color: a.color.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(a.icon, size: 24, color: a.color),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  a.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AdminColors.textPrimary,
                                    fontSize: 10.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
}
