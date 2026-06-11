import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/auth/register_controller.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/auth_brand_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller = RegisterController(
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
          Text('Đăng ký', style: AppTextStyles.display.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tham gia cộng đồng Apex Velocity để nhận ưu đãi và trải nghiệm mua sắm tốt nhất.',
            style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Họ và tên',
            hintText: 'Nguyễn Văn A',
            prefixIcon: Icons.person_outline,
            onChanged: _controller.changeFullName,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            hintText: 'example@apex.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            onChanged: _controller.changeEmail,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Số điện thoại',
            hintText: '09xx xxx xxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: _controller.changePhoneNumber,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Mật khẩu',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: !_controller.form.isPasswordVisible,
            onChanged: _controller.changePassword,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Xác nhận mật khẩu',
            hintText: '••••••••',
            prefixIcon: Icons.lock_reset_outlined,
            obscureText: !_controller.form.isConfirmPasswordVisible,
            onChanged: _controller.changeConfirmPassword,
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
            label: 'ĐĂNG KÝ  →',
            variant: AppButtonVariant.secondary,
            isLoading: _controller.isLoading,
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
        ],
      ),
    );
  }
}
