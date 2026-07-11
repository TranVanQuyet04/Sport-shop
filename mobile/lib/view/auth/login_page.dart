import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../presenter/auth/login_presenter.dart';
import 'widgets/auth_brand_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginPresenter _presenter = LoginPresenter(
    authRepository: AppDependencies.instance.authRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
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

  Future<void> _submit() async {
    final targetRoute = await _presenter.submit();
    if (targetRoute != null && mounted) {
      context.go(targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chào mừng trở lại',
              style: AppTextStyles.display.copyWith(fontSize: 34),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đăng nhập bằng tài khoản để bắt đầu mua sắm và theo dõi đơn hàng.',
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Email',
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline,
              errorText: _presenter.emailError,
              onChanged: _presenter.changeEmail,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Mật khẩu',
              hintText: 'Nhập mật khẩu',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: _presenter.passwordError,
              onChanged: _presenter.changePassword,
              onSubmitted: (_) => _submit(),
            ),
            if (_presenter.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _presenter.errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Đăng nhập',
              isLoading: _presenter.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('Tập luyện ngay? Tạo tài khoản mới'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go(AppRoutes.guestChat),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Chat hỗ trợ khách'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AuthTrustStrip(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
