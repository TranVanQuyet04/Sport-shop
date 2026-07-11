part of '../app_state.dart';

class PremiumEmptyState extends StatefulWidget {
  const PremiumEmptyState({
    super.key,
    required this.title,
    this.message,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onActionPressed,
    this.icon = Icons.inbox_outlined,
    this.actionIcon = Icons.refresh_rounded,
  });

  final String title;
  final String? message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onActionPressed;
  final IconData icon;
  final IconData actionIcon;

  @override
  State<PremiumEmptyState> createState() => _PremiumEmptyStateState();
}

class _PremiumEmptyStateState extends State<PremiumEmptyState> {
  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle ?? widget.message ?? '';
    final onPressed = widget.onActionPressed ?? widget.onAction;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StateVisual(icon: widget.icon, toneColor: AppColors.secondary),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (onPressed != null && widget.actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppElevation.glow(AppColors.primary),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(
                        widget.actionIcon,
                        size: 18,
                        color: AppColors.textInverse,
                      ),
                      label: Text(
                        widget.actionLabel!,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
