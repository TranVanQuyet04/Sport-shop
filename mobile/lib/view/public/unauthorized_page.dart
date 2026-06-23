import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../auth/widgets/auth_brand_header.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5ED),
                borderRadius: BorderRadius.circular(42),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.inventory_2, color: AppColors.primary, size: 120),
                  Positioned(bottom: 42, child: Icon(Icons.lock_outline, color: AppColors.secondary, size: 92)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('CODE: 403', style: AppTextStyles.display.copyWith(color: AppColors.textInverse, backgroundColor: AppColors.primary, fontStyle: FontStyle.italic)),
            const SizedBox(height: AppSpacing.xxl),
            Text('KHÔNG CÓ QUYỀN TRUY CẬP', style: AppTextStyles.display.copyWith(fontSize: 34), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bạn không có quyền xem nội dung này. Vui lòng đăng nhập bằng tài khoản phù hợp để tiếp tục.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
            ),
            const Spacer(),
            AppButton(label: 'ĐĂNG NHẬP', variant: AppButtonVariant.secondary, onPressed: () => context.go(AppRoutes.login)),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'QUAY LẠI TRANG CHỦ', variant: AppButtonVariant.outline, onPressed: () => context.go(AppRoutes.customerHome)),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: () => context.go(AppRoutes.guestChat),
              child: const Text('Liên hệ hỗ trợ kỹ thuật'),
            ),
          ],
        ),
      ),
    );
  }
}
