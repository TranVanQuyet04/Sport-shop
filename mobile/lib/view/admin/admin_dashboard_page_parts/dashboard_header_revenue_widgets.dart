// ignore_for_file: unused_element

part of '../admin_dashboard_page.dart';

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StrideX ADMIN',
                style: AppTextStyles.caption.copyWith(
                  color: _DashboardColors.blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tổng quan vận hành',
                style: AppTextStyles.display.copyWith(
                  color: _DashboardColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Theo dõi nhanh hiệu suất cửa hàng hôm nay.',
                style: AppTextStyles.body.copyWith(
                  color: _DashboardColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const _IconBadge(
          icon: Icons.insights_rounded,
          background: _DashboardColors.blueSoft,
          foreground: _DashboardColors.blue,
          size: 48,
          iconSize: 24,
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.008,
      dy: -2,
      borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: _DashboardColors.ink,
          borderRadius: BorderRadius.circular(_DashboardStyle.radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24172033),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doanh thu hôm nay',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFF69DB9A),
                        size: 17,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Tăng trưởng hôm nay: +0%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF9BE7B9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            const _IconBadge(
              icon: Icons.account_balance_wallet_outlined,
              background: Color(0x26FFFFFF),
              foreground: Colors.white,
              size: 52,
              iconSize: 25,
              glowColor: _DashboardColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSummaryRow extends StatelessWidget {
  const _StatSummaryRow({
    required this.totalOrders,
    required this.pendingOrders,
    required this.newUsers,
  });

  final String totalOrders;
  final String pendingOrders;
  final String newUsers;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MiniStatCard(
            title: 'Tổng đơn hàng',
            value: totalOrders,
            subtitle: '$pendingOrders đơn đang chờ xử lý',
            icon: Icons.shopping_bag_outlined,
            accent: _DashboardColors.blue,
            softAccent: _DashboardColors.blueSoft,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MiniStatCard(
            title: 'Người dùng mới',
            value: newUsers,
            subtitle: 'Tài khoản mới trong ngày',
            icon: Icons.person_add_alt_1_outlined,
            accent: _DashboardColors.green,
            softAccent: _DashboardColors.greenSoft,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.softAccent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color softAccent;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      minHeight: 166,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: _DashboardColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _IconBadge(
                icon: icon,
                background: softAccent,
                foreground: accent,
                size: 40,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display.copyWith(
              color: _DashboardColors.ink,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: _DashboardColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
