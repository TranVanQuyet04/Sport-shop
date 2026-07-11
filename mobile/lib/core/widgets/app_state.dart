import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

part 'app_state_parts/premium_empty_state.dart';
part 'app_state_parts/premium_shimmer_state.dart';
part 'app_state_parts/result_state_widgets.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.title = 'Đang tải dữ liệu',
    this.message = 'Vui lòng chờ trong giây lát.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StateShell(
      icon: Icons.hourglass_empty,
      toneColor: AppColors.info,
      title: title,
      message: message,
      extra: const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.title = 'Chưa có dữ liệu',
    this.message = 'Khi có dữ liệu mới, nội dung sẽ hiển thị tại đây.',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateShell(
      icon: Icons.inbox_outlined,
      toneColor: AppColors.textSecondary,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _StateVisual extends StatelessWidget {
  const _StateVisual({required this.icon, required this.toneColor});

  final IconData icon;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppElevation.raised,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var index = 0; index < 3; index++)
            Positioned(
              right: -18 + index * 18,
              top: 5 + index * 22,
              child: Transform.rotate(
                angle: -0.38,
                child: Container(
                  width: 78,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.textInverse.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              color: AppColors.secondary,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(height: 30, color: AppColors.accent),
              ),
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: toneColor.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, size: 30, color: toneColor),
          ),
        ],
      ),
    );
  }
}
