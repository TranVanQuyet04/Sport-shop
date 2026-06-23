import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/auth/forgot_password_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/auth_brand_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController _controller = ForgotPasswordController(
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
      context.go(AppRoutes.resetPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(color: Color(0xFFF4E9ED), shape: BoxShape.circle),
                child: const Icon(Icons.security, color: AppColors.secondary, size: 88),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Quên mật khẩu', style: AppTextStyles.display.copyWith(fontSize: 34), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Email của bạn',
                hintText: 'email@example.com',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                errorText: _controller.emailError,
                onChanged: _controller.changeEmail,
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
                label: 'Gửi yêu cầu  ▷',
                variant: AppButtonVariant.secondary,
                isLoading: _controller.isLoading,
                onPressed: _submit,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.guestChat),
                child: const Text('Bạn cần trợ giúp thêm? Liên hệ hỗ trợ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
