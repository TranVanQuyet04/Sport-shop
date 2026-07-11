import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/customer/profile_model.dart';
import '../../presenter/customer/profile_presenter.dart';
import '../admin/widgets/admin_app_bar.dart';
import 'widgets/delivery_bottom_nav.dart';

class ShipperAccountPage extends StatefulWidget {
  const ShipperAccountPage({super.key});

  @override
  State<ShipperAccountPage> createState() => _ShipperAccountPageState();
}

class _ShipperAccountPageState extends State<ShipperAccountPage> {
  late final ProfilePresenter _presenter = ProfilePresenter(
    profileRepository: AppDependencies.instance.profileRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadProfile();
  }

  @override
  void dispose() {
    _presenter
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
    final profile = _presenter.profile;
    return Scaffold(
      backgroundColor: AppColors.shipperBackground,
      appBar: const AdminAppBar(variant: AdminAppBarVariant.shipper),
      body: RefreshIndicator(
        onRefresh: _presenter.loadProfile,
        child: _buildBody(profile),
      ),
      bottomNavigationBar: const DeliveryBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody(ProfileModel? profile) {
    if (_presenter.isLoading && profile == null) {
      return const AppLoadingState(title: 'Đang tải tài khoản');
    }
    if (_presenter.errorMessage != null && profile == null) {
      return AppErrorState(
        title: 'Không tải được tài khoản',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadProfile,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_presenter.errorMessage != null) ...[
          _InfoBanner(message: _presenter.errorMessage!),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.shipperPrimary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.successBorder),
          boxShadow: AppElevation.role(AppColors.secondary),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.shipperPrimary,
              child: Icon(Icons.delivery_dining, size: 42),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile?.fullName ?? 'Tài khoản',
              style: AppTextStyles.title.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              profile?.roleName ?? '',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.secondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.successBorder),
          boxShadow: AppElevation.role(AppColors.secondary),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.title.copyWith(color: AppColors.info),
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
    final color = danger ? AppColors.error : AppColors.info;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HoverLift(
        enabled: onTap != null,
        interactive: onTap != null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: danger ? AppColors.errorBorder : AppColors.successBorder,
              ),
            ),
            child: ListTile(
              onTap: onTap,
              leading: CircleAvatar(
                backgroundColor: danger
                    ? AppColors.errorSoft
                    : AppColors.secondarySoft,
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
        ),
      ),
    );
  }
}
