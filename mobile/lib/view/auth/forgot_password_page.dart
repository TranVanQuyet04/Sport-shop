import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/auth_brand_header.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
                'Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu. Chúng tôi sẽ gửi một liên kết bảo mật đến hòm thư của bạn.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('EMAIL CỦA BẠN', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: AppSpacing.sm),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(prefixIcon: Icon(Icons.mail_outline), hintText: 'example@email.com'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'GỬI YÊU CẦU  ▷',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.resetPassword),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Bạn cần trợ giúp thêm? Liên hệ hỗ trợ')),
            ],
          ),
        ),
      ),
    );
  }
}
