import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../presenter/auth/register_presenter.dart';
import 'widgets/auth_brand_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterPresenter _presenter = RegisterPresenter(
    authRepository: AppDependencies.instance.authRepository,
  );

  @override
  void initState() {
    super.initState();
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
          Text('Đăng ký', style: AppTextStyles.display.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tạo tài khoản để mua sắm và theo dõi đơn hàng từ hệ thống.',
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Họ và tên',
            hintText: 'Nhập họ và tên',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            errorText: _presenter.fullNameError,
            onChanged: _presenter.changeFullName,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            hintText: 'email@example.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            errorText: _presenter.emailError,
            onChanged: _presenter.changeEmail,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Số điện thoại',
            hintText: 'Ví dụ: 0900000000',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            errorText: _presenter.phoneError,
            onChanged: _presenter.changePhoneNumber,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Mật khẩu',
            hintText: 'Ít nhất 8 ký tự, gồm chữ và số',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.next,
            errorText: _presenter.passwordError,
            onChanged: _presenter.changePassword,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: Icons.lock_reset_outlined,
            obscureText: true,
            textInputAction: TextInputAction.done,
            errorText: _presenter.confirmPasswordError,
            onChanged: _presenter.changeConfirmPassword,
            onSubmitted: (_) => _submit(),
          ),
          if (_presenter.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _presenter.errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Đăng ký',
            variant: AppButtonVariant.secondary,
            isLoading: _presenter.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Đã có tài khoản? Đăng nhập ngay'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthTrustStrip(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
