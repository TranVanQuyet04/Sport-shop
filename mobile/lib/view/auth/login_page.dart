import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/auth/login_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào mừng trở lại', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Đăng nhập để tiếp tục mua sắm tại Sportshop.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: _controller.changeEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                obscureText: !_controller.form.isPasswordVisible,
                onChanged: _controller.changePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: _controller.togglePasswordVisibility,
                    icon: Icon(
                      _controller.form.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
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
                label: 'Đăng nhập',
                isLoading: _controller.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Xem nhanh UI theo vai trò', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _RolePreviewChip(
                    label: 'Customer',
                    icon: Icons.storefront_outlined,
                    onTap: () => context.go(AppRoutes.customerHome),
                  ),
                  _RolePreviewChip(
                    label: 'Admin',
                    icon: Icons.dashboard_outlined,
                    onTap: () => context.go(AppRoutes.adminDashboard),
                  ),
                  _RolePreviewChip(
                    label: 'Shop Staff',
                    icon: Icons.inventory_2_outlined,
                    onTap: () => context.go(AppRoutes.shopStaffHome),
                  ),
                  _RolePreviewChip(
                    label: 'Delivery',
                    icon: Icons.local_shipping_outlined,
                    onTap: () => context.go(AppRoutes.deliveryHome),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
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
                  label: const Text('Chat hỗ trợ khách vãng lai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePreviewChip extends StatelessWidget {
  const _RolePreviewChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
      side: const BorderSide(color: AppColors.border),
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
