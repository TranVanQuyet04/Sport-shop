import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/auth_brand_header.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('Đặt lại mật khẩu', style: AppTextStyles.display.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vui lòng nhập mật khẩu mới cho tài khoản của bạn để tiếp tục trải nghiệm hiệu năng đỉnh cao cùng Apex Velocity.',
            style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mật khẩu mới', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(obscureText: true, decoration: InputDecoration(prefixIcon: Icon(Icons.lock_outline), suffixIcon: Icon(Icons.visibility_outlined), hintText: 'Nhập mật khẩu mới')),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Xác nhận mật khẩu mới', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(obscureText: true, decoration: InputDecoration(prefixIcon: Icon(Icons.lock_reset_outlined), suffixIcon: Icon(Icons.visibility_outlined), hintText: 'Xác nhận mật khẩu mới')),
                  const SizedBox(height: AppSpacing.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.secondary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'YÊU CẦU BẢO MẬT\nMật khẩu phải bao gồm ít nhất 8 ký tự, 1 chữ hoa và 1 số.',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(label: 'XÁC NHẬN  ›', variant: AppButtonVariant.secondary, onPressed: () => context.go(AppRoutes.login)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
