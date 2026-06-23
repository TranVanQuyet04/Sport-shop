import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text('Đổi mật khẩu'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppTextField(
          controller: _oldPassword,
          label: 'Mật khẩu cũ',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _newPassword,
          label: 'Mật khẩu mới',
          prefixIcon: Icons.lock_reset,
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _confirmPassword,
          label: 'Nhập lại mật khẩu mới',
          prefixIcon: Icons.verified_user_outlined,
          obscureText: true,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
        ],
      ],
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppButton(
          label: 'Cập nhật mật khẩu',
          variant: AppButtonVariant.secondary,
          isLoading: _isSubmitting,
          onPressed: _submit,
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await AppDependencies.instance.authRepository.changePassword(
        oldPassword: _oldPassword.text,
        newPassword: _newPassword.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu.')));
      context.pop();
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
