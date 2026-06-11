import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/profile_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/profile_model.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/sportshop_logo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;

    return Scaffold(
      appBar: AppBar(
        title: const SportshopLogo(),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _controller.isLoading ? null : _controller.loadProfile,
            icon: const Icon(Icons.refresh),
          ),
          const IconButton(onPressed: null, icon: Icon(Icons.menu)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadProfile,
        child: _buildBody(profile),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 4),
    );
  }

  Widget _buildBody(ProfileModel? profile) {
    if (_controller.isLoading && profile == null) {
      return const AppLoadingState(title: 'Đang tải hồ sơ');
    }
    if (_controller.errorMessage != null && profile == null) {
      return AppErrorState(
        title: 'Không tải được hồ sơ',
        message: _controller.errorMessage!,
        onAction: _controller.loadProfile,
      );
    }

    final fullName = profile?.fullName ?? 'Khách hàng Sportshop';
    final email = profile?.email ?? '';
    final phone = profile?.phoneNumber ?? 'Chưa cập nhật số điện thoại';
    final role = profile?.roleName ?? 'CUSTOMER';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 70),
              ),
              Positioned(
                right: 0,
                bottom: 6,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          fullName,
          style: AppTextStyles.display.copyWith(fontSize: 34),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$role • $email',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          phone,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: const [
            Expanded(
              child: _MetricCard(value: '--', label: 'ĐƠN HÀNG'),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _MetricCard(value: '--', label: 'ĐIỂM THƯỞNG'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            children: const [
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
              ),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Sổ địa chỉ',
                route: AppRoutes.addressBook,
              ),
              _ProfileTile(
                icon: Icons.receipt_long_outlined,
                title: 'Đơn hàng của tôi',
                route: AppRoutes.orders,
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Trung tâm hỗ trợ',
                route: AppRoutes.customerSupport,
              ),
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: AppColors.surfaceMuted,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          onPressed: () => context.go(AppRoutes.login),
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Phiên bản 4.2.0 • Sportswear Pro',
          style: AppTextStyles.body.copyWith(color: AppColors.border),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.display.copyWith(
                color: AppColors.secondary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.body.copyWith(letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.last = false,
    this.route,
  });

  final IconData icon;
  final String title;
  final bool last;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: ListTile(
        onTap: route == null ? null : () => context.go(route!),
        minVerticalPadding: AppSpacing.lg,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
