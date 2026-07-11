import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/customer/profile_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/profile_model.dart';
import 'widgets/admin_design_system.dart';

part 'admin_profile_page_parts/profile_identity_widgets.dart';
part 'admin_profile_page_parts/profile_actions_and_dialog.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Hồ sơ quản trị'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _presenter.isLoading ? null : _presenter.loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AdminColors.primary,
        onRefresh: _presenter.loadProfile,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final profile = _presenter.profile;
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

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        if (_presenter.errorMessage != null) ...[
          AdminInlineBanner(
            message: _presenter.errorMessage!,
            isError: true,
            onRefresh: _presenter.loadProfile,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _ProfileHero(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        _AccountStatusCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        _ActionList(
          onEditProfile: () => _openEditProfile(profile),
          onSecurity: () => context.push(AppRoutes.adminChangePassword),
        ),
      ],
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.adminSettings);
    }
  }

  Future<void> _openEditProfile(ProfileModel? profile) async {
    if (profile == null) {
      return;
    }

    final fullNameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final result = await showDialog<_ProfileUpdateData>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              controller: fullNameController,
              label: 'Họ và tên',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            _DialogField(
              controller: phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final fullName = fullNameController.text.trim();
              final phoneNumber = phoneController.text.trim();
              if (fullName.isEmpty || phoneNumber.isEmpty) {
                return;
              }
              Navigator.pop(
                dialogContext,
                _ProfileUpdateData(
                  fullName: fullName,
                  phoneNumber: phoneNumber,
                ),
              );
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
    fullNameController.dispose();
    phoneController.dispose();

    if (result == null || !mounted) {
      return;
    }

    try {
      await AppDependencies.instance.profileRepository.updateMyProfile(
        fullName: result.fullName,
        phoneNumber: result.phoneNumber,
      );
      await _presenter.loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin cá nhân.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
