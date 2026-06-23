import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/profile_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/customer/profile_model.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class ShipperAccountPage extends StatefulWidget {
  const ShipperAccountPage({super.key});

  @override
  State<ShipperAccountPage> createState() => _ShipperAccountPageState();
}

class _ShipperAccountPageState extends State<ShipperAccountPage> {
  late final ProfileController _controller = ProfileController(
    profileRepository: AppDependencies.instance.profileRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadProfile();
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

  Future<void> _logout() async {
    await AppDependencies.instance.authRepository.logout();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadProfile,
        child: _buildBody(profile),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(ProfileModel? profile) {
    if (_controller.isLoading && profile == null) {
      return const AppLoadingState(title: 'Đang tải tài khoản');
    }
    if (_controller.errorMessage != null && profile == null) {
      return AppErrorState(
        title: 'Không tải được tài khoản',
        message: _controller.errorMessage!,
        onAction: _controller.loadProfile,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_controller.errorMessage != null) ...[
          _InfoBanner(message: _controller.errorMessage!),
          const SizedBox(height: AppSpacing.lg),
        ],
        _AccountHeader(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _AccountMetric(
                label: 'Vai trò',
                value: profile?.roleName ?? '-',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AccountMetric(
                label: 'Trạng thái',
                value: profile?.status == true ? 'Đang hoạt động' : 'Đã khóa',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Tài khoản', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.md),
        _InfoTile(
          icon: Icons.person_outline,
          title: profile?.fullName ?? 'Hồ sơ',
          subtitle: profile?.email ?? 'Chưa có email',
        ),
        _InfoTile(
          icon: Icons.phone_outlined,
          title: 'Số điện thoại',
          subtitle: profile?.phoneNumber.isNotEmpty == true
              ? profile!.phoneNumber
              : 'Chưa cập nhật',
        ),
        _InfoTile(
          icon: Icons.local_shipping_outlined,
          title: 'Đơn được phân công',
          subtitle: 'Xem danh sách đơn lấy từ backend',
          onTap: () => context.go(AppRoutes.deliveryAssignedOrders),
        ),
        _InfoTile(
          icon: Icons.logout,
          title: 'Đăng xuất',
          subtitle: 'Kết thúc phiên đăng nhập hiện tại',
          danger: true,
          onTap: _logout,
        ),
      ],
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.profile});

  final ProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.delivery_dining, size: 42),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile?.fullName ?? 'Tài khoản',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                Text(
                  profile?.roleName ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
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

class _AccountMetric extends StatelessWidget {
  const _AccountMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      scale: 1.01,
      dy: -1,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: AppTextStyles.caption.copyWith(color: AppColors.info),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HoverLift(
        enabled: onTap != null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: ListTile(
          tileColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.border),
          ),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceMuted,
            foregroundColor: color,
            child: Icon(icon),
          ),
          title: Text(
            title,
            style: AppTextStyles.subtitle.copyWith(color: color),
          ),
          subtitle: Text(subtitle),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
