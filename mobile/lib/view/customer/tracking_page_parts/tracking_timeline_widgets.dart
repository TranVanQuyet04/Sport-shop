part of '../tracking_page.dart';

class _TrackingErrorBanner extends StatelessWidget {
  const _TrackingErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineData {
  const _TimelineData(this.status, this.title, this.subtitle);

  final OrderStatus status;
  final String title;
  final String subtitle;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.time,
    required this.subtitle,
    this.active = false,
    this.last = false,
  });

  final String title;
  final String time;
  final String subtitle;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active
                    ? AppColors.secondary
                    : const Color(0xFFD7CDD0),
                child: Icon(
                  active ? Icons.check : Icons.circle,
                  size: active ? 14 : 8,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFD7CDD0)),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.subtitle.copyWith(
                            color: active
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
