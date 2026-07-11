part of '../app_state.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedMinHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - (AppSpacing.xl * 2)
            : 0.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: boundedMinHeight < 0 ? 0 : boundedMinHeight,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StateVisual(icon: icon, toneColor: toneColor),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
            ),
          ),
        );
      },
    );
  }
}
