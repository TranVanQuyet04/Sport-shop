import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProductGalleryPage extends StatelessWidget {
  const ProductGalleryPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.secondary, AppColors.primary, const Color(0xFFE7E4FF), const Color(0xFFECEFF1)];

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.close)),
        title: const Text('Thư viện ảnh'),
      ),
      body: PageView.builder(
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors[index].withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Icon(Icons.directions_run, color: colors[index], size: 180),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('${index + 1}/${colors.length}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textInverse)),
              ],
            ),
          );
        },
      ),
    );
  }
}
