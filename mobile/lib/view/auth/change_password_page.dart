import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../admin/widgets/admin_design_system.dart';

part 'change_password_page_parts/password_form_widgets.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminThemeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Đổi mật khẩu'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const _PasswordHeader(),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AdminColors.surface,
                borderRadius: BorderRadius.circular(AdminDesign.radius),
                boxShadow: AdminDesign.cardShadow,
              ),
              child: Column(
                children: [
                  _PasswordField(
                    controller: _currentPasswordController,
                    label: 'Mật khẩu hiện tại',
                    hintText: 'Nhập mật khẩu đang sử dụng',
                    obscureText: _obscureCurrentPassword,
                    textInputAction: TextInputAction.next,
                    onToggleVisibility: () {
                      setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordField(
                    controller: _newPasswordController,
                    label: 'Mật khẩu mới',
                    hintText: 'Ít nhất 8 ký tự, gồm chữ và số',
                    obscureText: _obscureNewPassword,
                    textInputAction: TextInputAction.next,
                    onToggleVisibility: () {
                      setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu mới',
                    hintText: 'Nhập lại mật khẩu mới',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onToggleVisibility: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _ErrorBanner(message: _errorMessage!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SecurityNote(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AdminColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AdminColors.navy.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: _SubmitButton(isLoading: _isSubmitting, onPressed: _submit),
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.adminSettings);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin.');
      return;
    }
    if (!RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    ).hasMatch(newPassword)) {
      setState(
        () =>
            _errorMessage = 'Mật khẩu mới cần ít nhất 8 ký tự, gồm chữ và số.',
      );
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppDependencies.instance.authRepository.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đổi mật khẩu thành công.')),
      );
      _goBack();
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
