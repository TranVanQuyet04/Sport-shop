import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/auth/reset_password_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/auth_brand_header.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordController _controller = ResetPasswordController(
    authRepository: AppDependencies.instance.authRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final success = await _controller.submit();
    if (success && mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('Đặt lại mật khẩu', style: AppTextStyles.display.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nhập token và mật khẩu mới cho tài khoản của bạn.',
            style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Token đặt lại mật khẩu',
                    hintText: 'Nhập token từ email',
                    prefixIcon: Icons.key_outlined,
                    onChanged: _controller.changeToken,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_controller.form.isNewPasswordVisible,
                    onChanged: _controller.changeNewPassword,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Xác nhận mật khẩu mới',
                    hintText: 'Xác nhận mật khẩu mới',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: !_controller.form.isConfirmPasswordVisible,
                    onChanged: _controller.changeConfirmPassword,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.secondary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Yêu cầu bảo mật\nMật khẩu phải bao gồm ít nhất 8 ký tự, 1 chữ hoa và 1 số.',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _controller.errorMessage!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'XÁC NHẬN  ›',
                    variant: AppButtonVariant.secondary,
                    isLoading: _controller.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
