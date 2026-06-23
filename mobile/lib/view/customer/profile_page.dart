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
            tooltip: 'Refresh',
            onPressed: _controller.isLoading ? null : _controller.loadProfile,
            icon: const Icon(Icons.refresh),
          ),
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
      return const AppLoadingState(title: 'Loading profile');
    }
    if (_controller.errorMessage != null && profile == null) {
      return AppErrorState(
        title: 'Could not load profile',
        message: _controller.errorMessage!,
        onAction: _controller.loadProfile,
      );
    }

    final fullName = profile?.fullName ?? '';
    final email = profile?.email ?? '';
    final phone = profile?.phoneNumber ?? '';
    final role = profile?.roleName ?? '';
    final status = profile?.status == true ? 'Active' : 'Disabled';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_controller.errorMessage != null) ...[
          _ProfileErrorBanner(message: _controller.errorMessage!),
          const SizedBox(height: AppSpacing.lg),
        ],
        const SizedBox(height: AppSpacing.xl),
        const Center(
          child: CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 70),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          fullName.isEmpty ? 'Profile' : fullName,
          style: AppTextStyles.display.copyWith(fontSize: 34),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          [role, email].where((value) => value.isNotEmpty).join(' - '),
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          phone.isEmpty ? 'Phone not updated' : phone,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _ProfileInfoCard(
          profile: profile,
          status: status,
        ),
        const SizedBox(height: AppSpacing.xl),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: const Column(
            children: [
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Address book',
                route: AppRoutes.addressBook,
              ),
              _ProfileTile(
                icon: Icons.receipt_long_outlined,
                title: 'My orders',
                route: AppRoutes.orders,
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Support center',
                route: AppRoutes.customerSupport,
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
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    await AppDependencies.instance.authRepository.logout();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.login);
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile, required this.status});

  final ProfileModel? profile;
  final String status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _ProfileInfoRow(label: 'User ID', value: profile?.id ?? '-'),
            const Divider(height: AppSpacing.xl),
            _ProfileInfoRow(label: 'Role', value: profile?.roleName ?? '-'),
            const Divider(height: AppSpacing.xl),
            _ProfileInfoRow(label: 'Status', value: status),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ProfileErrorBanner extends StatelessWidget {
  const _ProfileErrorBanner({required this.message});

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
