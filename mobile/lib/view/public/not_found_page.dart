import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../auth/widgets/auth_brand_header.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBrandHeader(trailing: IconButton(onPressed: null, icon: Icon(Icons.shopping_cart_outlined))),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                Text('404', style: AppTextStyles.display.copyWith(fontSize: 112, color: AppColors.surfaceMuted)),
                Container(
                  width: 260,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(Icons.sports_soccer, color: AppColors.secondary, size: 92),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('TRANG KHÔNG TÌM THẤY', style: AppTextStyles.display.copyWith(fontSize: 32), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Rất tiếc, trang bạn đang tìm kiếm không tồn tại hoặc đã bị dời đi.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(fontSize: 18, color: AppColors.textSecondary),
            ),
            const Spacer(),
            AppButton(label: 'VỀ TRANG CHỦ', variant: AppButtonVariant.secondary, onPressed: () => context.go(AppRoutes.customerHome)),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'TÌM SẢN PHẨM KHÁC', variant: AppButtonVariant.outline, onPressed: () => context.go(AppRoutes.search)),
            const SizedBox(height: AppSpacing.xl),
            Text('APEX VELOCITY • PERFORMANCE GEAR', style: AppTextStyles.caption.copyWith(letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
