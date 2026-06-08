import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

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

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Có lỗi xảy ra',
    this.message = 'Không thể tải dữ liệu. Vui lòng thử lại.',
    this.actionLabel = 'Thử lại',
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateShell(
      icon: Icons.error_outline,
      toneColor: AppColors.error,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class AppSuccessState extends StatelessWidget {
  const AppSuccessState({
    super.key,
    this.title = 'Thành công',
    this.message = 'Thao tác của bạn đã được xử lý.',
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
      icon: Icons.check_circle_outline,
      toneColor: AppColors.success,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _StateShell extends StatelessWidget {
  const _StateShell({
    required this.icon,
    required this.toneColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.extra,
  });

  final IconData icon;
  final Color toneColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: toneColor.withValues(alpha: 0.1),
              foregroundColor: toneColor,
              child: Icon(icon, size: 42),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            ?extra,
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
