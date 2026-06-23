import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_dashboard_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hover_effect.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminDashboardController _controller = AdminDashboardController(
    adminReportRepository: AppDependencies.instance.adminReportRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _controller.report;
    final revenue = _formatNumber(report?.totalRevenue ?? 0);
    final totalOrders = _formatNumber(report?.totalOrders ?? 0);
    final newUsers = _formatNumber(report?.newUsers ?? 0);
    final pendingOrdersCount = report?.pendingOrders ?? 0;
    final pendingOrders = _formatNumber(pendingOrdersCount);

    return Scaffold(
      backgroundColor: _DashboardColors.background,
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        color: _DashboardColors.blue,
        onRefresh: _controller.loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            108,
          ),
          children: [
            if (_controller.isLoading)
              const LinearProgressIndicator(
                minHeight: 3,
                color: _DashboardColors.blue,
                backgroundColor: _DashboardColors.blueSoft,
              ),
            if (_controller.errorMessage != null) ...[
              _ErrorBanner(
                message: _controller.errorMessage!,
                onRefresh: _controller.loadDashboard,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            const _DashboardHeader(),
            const SizedBox(height: AppSpacing.xl),
            _RevenueCard(value: '$revenueđ'),
            const SizedBox(height: AppSpacing.lg),
            _StatSummaryRow(
              totalOrders: totalOrders,
              pendingOrders: pendingOrders,
              newUsers: newUsers,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _OperationsSection(
              pendingOrders: pendingOrders,
              newUsers: newUsers,
              onOrders: () => context.go(AppRoutes.adminOrders),
              onDelivery: () => context.go(AppRoutes.adminDeliveryMonitoring),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _QuickActionsSection(
              actions: [
                _QuickActionData(
                  icon: Icons.add_box_outlined,
                  label: 'Thêm sản phẩm',
                  color: _DashboardColors.orange,
                  softColor: _DashboardColors.orangeSoft,
                  onTap: () => context.go(AppRoutes.adminProducts),
                ),
                _QuickActionData(
                  icon: Icons.task_alt_outlined,
                  label: 'Duyệt đơn',
                  color: _DashboardColors.blue,
                  softColor: _DashboardColors.blueSoft,
                  onTap: () => context.go(AppRoutes.adminOrders),
                ),
                _QuickActionData(
                  icon: Icons.straighten_outlined,
                  label: 'Size / Màu sắc',
                  color: _DashboardColors.purple,
                  softColor: _DashboardColors.purpleSoft,
                  onTap: () => context.go(AppRoutes.adminProducts),
                ),
                _QuickActionData(
                  icon: Icons.verified_outlined,
                  label: 'Thương hiệu',
                  color: _DashboardColors.green,
                  softColor: _DashboardColors.greenSoft,
                  onTap: () => context.go(AppRoutes.adminBrands),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _TodayOverviewSection(
              pendingOrders: pendingOrders,
              pendingOrdersCount: pendingOrdersCount,
              newUsers: newUsers,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }

  String _formatNumber(num value) =>
      NumberFormat.decimalPattern('vi_VN').format(value);
}

abstract final class _DashboardColors {
  static const background = AdminColors.background;
  static const surface = AdminColors.surface;
  static const ink = AdminColors.navy;
  static const muted = AdminColors.textSecondary;
  static const subtle = AdminColors.surfaceMuted;

  static const blue = AdminColors.primary;
  static const blueDark = AdminColors.primaryPressed;
  static const blueSoft = AdminColors.primarySoft;

  static const orange = AdminColors.accent;
  static const orangeSoft = AdminColors.accentSoft;
  static const green = AdminColors.success;
  static const greenSoft = AdminColors.successSoft;
  static const purple = AdminColors.primary;
  static const purpleSoft = AdminColors.primarySoft;
  static const red = AdminColors.danger;
  static const redSoft = AdminColors.dangerSoft;
}

abstract final class _DashboardStyle {
  static const radius = AdminDesign.radius;
  static const cardShadow = AdminDesign.cardShadow;
}

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
                'SPORTSHOP ADMIN',
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
                      Text(
                        'Tăng trưởng hôm nay: +0%',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF9BE7B9),
                          fontWeight: FontWeight.w700,
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

class _OperationsSection extends StatelessWidget {
  const _OperationsSection({
    required this.pendingOrders,
    required this.newUsers,
    required this.onOrders,
    required this.onDelivery,
  });

  final String pendingOrders;
  final String newUsers;
  final VoidCallback onOrders;
  final VoidCallback onDelivery;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Tình hình vận hành',
            subtitle: 'Các chỉ số cần quan tâm trong ngày',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  label: 'Chờ xử lý',
                  value: pendingOrders,
                  icon: Icons.pending_actions_outlined,
                  accent: _DashboardColors.orange,
                  softAccent: _DashboardColors.orangeSoft,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SnapshotMetric(
                  label: 'User mới',
                  value: newUsers,
                  icon: Icons.group_add_outlined,
                  accent: _DashboardColors.purple,
                  softAccent: _DashboardColors.purpleSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _OperationButton(
                  icon: Icons.receipt_long_outlined,
                  label: 'Đơn hàng',
                  primary: true,
                  onPressed: onOrders,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _OperationButton(
                  icon: Icons.local_shipping_outlined,
                  label: 'Giao hàng',
                  onPressed: onDelivery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  const _SnapshotMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.softAccent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color softAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _DashboardColors.subtle,
        borderRadius: BorderRadius.circular(_DashboardStyle.radius),
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            background: softAccent,
            foreground: accent,
            size: 38,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: _DashboardColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: _DashboardColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  const _OperationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.01,
      dy: -1,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 48,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: primary
                  ? const LinearGradient(
                      colors: [
                        _DashboardColors.blue,
                        _DashboardColors.blueDark,
                      ],
                    )
                  : null,
              color: primary ? null : _DashboardColors.blueSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: primary ? Colors.white : _DashboardColors.blue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        color: primary ? Colors.white : _DashboardColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
