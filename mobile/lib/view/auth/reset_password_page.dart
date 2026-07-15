import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../presenter/auth/reset_password_presenter.dart';
import 'widgets/auth_brand_header.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordPresenter _presenter = ResetPasswordPresenter(
    authRepository: AppDependencies.instance.authRepository,
  );

  @override
  void initState() {
    super.initState();
    final initialToken = widget.initialToken?.trim();
    if (initialToken != null && initialToken.isNotEmpty) {
      _presenter.changeToken(initialToken);
    }
    _presenter.addListener(_onChanged);
  }

  @override
  void dispose() {
    _presenter
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
    final success = await _presenter.submit();
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
          Text(
            'Đặt lại mật khẩu',
            style: AppTextStyles.display.copyWith(fontSize: 34),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nhập token từ email và mật khẩu mới cho tài khoản của bạn.',
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Token đặt lại mật khẩu',
                    hintText: 'Nhập token từ email',
                    initialValue: widget.initialToken,
                    prefixIcon: Icons.key_outlined,
                    textInputAction: TextInputAction.next,
                    errorText: _presenter.tokenError,
                    onChanged: _presenter.changeToken,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Mật khẩu mới',
                    hintText: 'Ít nhất 8 ký tự, gồm chữ và số',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    errorText: _presenter.passwordError,
                    onChanged: _presenter.changeNewPassword,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Xác nhận mật khẩu mới',
                    hintText: 'Nhập lại mật khẩu mới',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    errorText: _presenter.confirmPasswordError,
                    onChanged: _presenter.changeConfirmPassword,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Yêu cầu bảo mật\nMật khẩu phải có ít nhất 8 ký tự, gồm chữ và số.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_presenter.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _presenter.errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Xác nhận',
                    variant: AppButtonVariant.secondary,
                    isLoading: _presenter.isLoading,
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
