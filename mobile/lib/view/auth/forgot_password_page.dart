import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/sport_performance_hero.dart';
import '../../presenter/auth/forgot_password_presenter.dart';
import 'widgets/auth_brand_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordPresenter _presenter = ForgotPasswordPresenter(
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
      context.go(AppRoutes.resetPassword);
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
            const SizedBox(height: AppSpacing.xl),
            const Center(
              child: SportIconPanel(
                icon: Icons.security_rounded,
                tone: AppColors.electric,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Quên mật khẩu',
              style: AppTextStyles.display.copyWith(fontSize: 34),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nhập email để nhận hướng dẫn đặt lại mật khẩu từ hệ thống.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Email của bạn',
              hintText: 'email@example.com',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              errorText: _presenter.emailError,
              onChanged: _presenter.changeEmail,
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
              label: 'Gửi yêu cầu',
              variant: AppButtonVariant.secondary,
              isLoading: _presenter.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.guestChat),
                child: const Text('Bạn cần trợ giúp thêm? Liên hệ hỗ trợ'),
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
