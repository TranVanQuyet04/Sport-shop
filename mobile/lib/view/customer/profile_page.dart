import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/customer/profile_model.dart';
import '../../presenter/customer/profile_presenter.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/sportshop_logo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    final profile = _presenter.profile;

    return Scaffold(
      appBar: AppBar(
        title: const StrideXLogo(),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _presenter.isLoading ? null : _presenter.loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _presenter.loadProfile,
        child: _buildBody(profile),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 4),
    );
  }

  Widget _buildBody(ProfileModel? profile) {
    if (_presenter.isLoading && profile == null) {
      return const AppLoadingState(title: 'Đang tải hồ sơ');
    }
    if (_presenter.errorMessage != null && profile == null) {
      return AppErrorState(
        title: 'Không tải được hồ sơ',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadProfile,
      );
    }

    final fullName = profile?.fullName ?? '';
    final email = profile?.email ?? '';
    final phone = profile?.phoneNumber ?? '';
    final role = profile?.roleName ?? '';
    final status = profile?.status == true ? 'Hoạt động' : 'Đã khóa';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_presenter.errorMessage != null) ...[
          _ProfileErrorBanner(message: _presenter.errorMessage!),
          const SizedBox(height: AppSpacing.lg),
        ],
        const SizedBox(height: AppSpacing.xl),
        const Center(
          child: CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 64),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          fullName.isEmpty ? 'Hồ sơ của tôi' : fullName,
          style: AppTextStyles.display.copyWith(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email.isEmpty ? 'Chưa có email' : email,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          phone.isEmpty ? 'Chưa cập nhật số điện thoại' : phone,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Chỉnh sửa hồ sơ',
          variant: AppButtonVariant.secondary,
          onPressed: profile == null
              ? null
              : () => _showEditProfileSheet(profile),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ProfileInfoCard(profile: profile, status: status, role: role),
        const SizedBox(height: AppSpacing.xl),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: const Column(
            children: [
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
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }

  Future<void> _showEditProfileSheet(ProfileModel profile) async {
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    var hasSubmitted = false;
    var isSaving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              String? requiredError(TextEditingController controller) {
                if (!hasSubmitted || controller.text.trim().isNotEmpty) {
                  return null;
                }
                return 'Vui lòng nhập thông tin.';
              }

              final phoneText = phoneController.text.trim();
              final phoneError = !hasSubmitted || phoneText.isEmpty
                  ? requiredError(phoneController)
                  : _isVietnamesePhone(phoneText)
                  ? null
                  : 'Số điện thoại không hợp lệ.';
              final canSubmit =
                  nameController.text.trim().isNotEmpty &&
                  phoneText.isNotEmpty &&
                  phoneError == null;

              Future<void> save() async {
                setSheetState(() => hasSubmitted = true);
                if (!canSubmit || isSaving) {
                  return;
                }
                setSheetState(() => isSaving = true);
                final success = await _presenter.updateProfile(
                  fullName: nameController.text.trim(),
                  phoneNumber: phoneText,
                );
                if (!context.mounted) {
                  return;
                }
                setSheetState(() => isSaving = false);
                if (success) {
                  Navigator.of(context).pop();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _presenter.errorMessage ?? 'Không thể cập nhật hồ sơ.',
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chỉnh sửa hồ sơ',
                            style: AppTextStyles.title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Đóng',
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Họ và tên',
                      controller: nameController,
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      errorText: requiredError(nameController),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Số điện thoại',
                      controller: phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      errorText: phoneError,
                      onChanged: (_) => setSheetState(() {}),
                      onSubmitted: (_) => save(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Lưu hồ sơ',
                      variant: AppButtonVariant.secondary,
                      isLoading: isSaving,
                      onPressed: save,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  bool _isVietnamesePhone(String value) {
    return RegExp(
      r'^(0|\+84)(\s|\.)?((3[2-9])|(5[689])|(7[06-9])|(8[1-689])|(9[0-46-9]))(\d)(\s|\.)?(\d{3})(\s|\.)?(\d{3})$',
    ).hasMatch(value);
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
  const _ProfileInfoCard({
    required this.profile,
    required this.status,
    required this.role,
  });

  final ProfileModel? profile;
  final String status;
  final String role;

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
            _ProfileInfoRow(label: 'Mã tài khoản', value: profile?.id ?? '-'),
            const Divider(height: AppSpacing.xl),
            _ProfileInfoRow(label: 'Vai trò', value: role.isEmpty ? '-' : role),
            const Divider(height: AppSpacing.xl),
            _ProfileInfoRow(label: 'Trạng thái', value: status),
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
          foregroundColor: AppColors.secondary,
          child: Icon(icon),
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
