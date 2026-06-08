import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';

class SharedStatesDemoPage extends StatelessWidget {
  const SharedStatesDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared States')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('State dùng chung', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Các widget này dùng cho loading, empty, error và success trên toàn bộ app.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _PreviewCard(child: AppLoadingState()),
          const _PreviewCard(
            child: AppEmptyState(
              title: 'Chưa có đơn hàng',
              message: 'Khi khách đặt hàng, đơn mới sẽ xuất hiện trong danh sách này.',
            ),
          ),
          _PreviewCard(
            child: AppErrorState(
              title: 'Không tải được sản phẩm',
              message: 'Kết nối API đang gặp sự cố. Hãy thử lại sau.',
              onAction: () {},
            ),
          ),
          _PreviewCard(
            child: AppSuccessState(
              title: 'Đã cập nhật trạng thái',
              message: 'Trạng thái giao hàng đã được lưu thành công.',
              actionLabel: 'Xem đơn hàng',
              onAction: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      constraints: const BoxConstraints(minHeight: 280),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
