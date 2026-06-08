import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/auth_brand_header.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
          const _LabeledField(label: 'Họ và tên', hint: 'Nguyễn Văn A', icon: Icons.person_outline),
          const _LabeledField(label: 'Email', hint: 'example@apex.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
          const _LabeledField(label: 'Số điện thoại', hint: '09xx xxx xxx', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const _LabeledField(label: 'Mật khẩu', hint: '••••••••', icon: Icons.lock_outline, obscure: true),
          const _LabeledField(label: 'Xác nhận mật khẩu', hint: '••••••••', icon: Icons.lock_reset_outlined, obscure: true),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text.rich(
                    TextSpan(
                      text: 'Tôi đồng ý với ',
                      children: [
                        TextSpan(text: 'Điều khoản', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                        const TextSpan(text: ' và '),
                        TextSpan(text: 'Chính sách bảo mật', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                        const TextSpan(text: ' của Sportshop.'),
                      ],
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'ĐĂNG KÝ  →', variant: AppButtonVariant.secondary, onPressed: () => context.go(AppRoutes.login)),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Đã có tài khoản? Đăng nhập ngay'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              Expanded(child: OutlinedButton(onPressed: null, child: Text('GOOGLE'))),
              SizedBox(width: AppSpacing.md),
              Expanded(child: FilledButton(onPressed: null, child: Text('FACEBOOK'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(prefixIcon: Icon(icon), hintText: hint),
          ),
        ],
      ),
    );
  }
}
