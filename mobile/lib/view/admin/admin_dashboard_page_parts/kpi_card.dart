// ──────────────────────────────────────────────────────────────────────────────
//  KPI Card (Admin Dashboard part file)
// ──────────────────────────────────────────────────────────────────────────────
part of '../admin_dashboard_page.dart';

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.background,
    required this.helper,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.012,
      dy: -2,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, background.withValues(alpha: 0.08)],
            ),
            border: Border.all(color: background.withValues(alpha: 0.22)),
            borderRadius: BorderRadius.circular(_DashboardStyle.radius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _IconBadge(
                  icon: icon,
                  background: background.withValues(alpha: 0.12),
                  foreground: background,
                  size: 38,
                  iconSize: 19,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: background,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: _DashboardColors.ink,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        helper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: _DashboardColors.muted,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
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
