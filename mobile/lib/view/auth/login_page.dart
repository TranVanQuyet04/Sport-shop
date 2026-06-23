import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/auth/login_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller = LoginController(
    authRepository: AppDependencies.instance.authRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
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

  Future<void> _submit() async {
    final targetRoute = await _controller.submit();
    if (targetRoute != null && mounted) {
      context.go(targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('Chào mừng trở lại', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đăng nhập bằng tài khoản backend để tiếp tục.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Email',
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline,
              errorText: _controller.emailError,
              onChanged: _controller.changeEmail,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Mật khẩu',
              hintText: 'Nhập mật khẩu',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: _controller.passwordError,
              onChanged: _controller.changePassword,
              onSubmitted: (_) => _submit(),
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
              label: 'Đăng nhập',
              isLoading: _controller.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('Tạo tài khoản'),
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
          ],
        ),
      ),
    );
  }
}
