part of '../admin_delivery_monitoring_page.dart';

class _DeliveryEmptyPresentation {
  const _DeliveryEmptyPresentation({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({
    required this.activeCount,
    required this.deliveredCount,
  });

  final int activeCount;
  final int deliveredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$activeCount đang giao · $deliveredCount đã giao',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeliveryErrorBanner extends StatelessWidget {
  const _DeliveryErrorBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AdminColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AdminColors.primaryPressed,
              ),
            ),
          ),
          TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _DeliveryFilterBar extends StatelessWidget {
  const _DeliveryFilterBar({required this.selected, required this.onSelected});

  final _DeliveryFilter selected;
  final ValueChanged<_DeliveryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = <(_DeliveryFilter, String)>[
      (_DeliveryFilter.all, 'Tất cả'),
      (_DeliveryFilter.active, 'Đang giao'),
      (_DeliveryFilter.delivered, 'Đã giao'),
      (_DeliveryFilter.issue, 'Lỗi / Trả lại'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((entry) {
          final isSelected = selected == entry.$1;
          final isIssue = entry.$1 == _DeliveryFilter.issue;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(entry.$2),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.$1),
              showCheckmark: false,
              backgroundColor: AdminColors.surface,
              selectedColor: isIssue
                  ? const Color(0xFFFFE4E6)
                  : AdminColors.primary,
              side: BorderSide(
                color: isSelected && isIssue
                    ? const Color(0xFFBE123C)
                    : isSelected
                    ? AdminColors.primary
                    : AdminColors.border,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? isIssue
                          ? const Color(0xFFBE123C)
                          : Colors.white
                    : AdminColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.count, required this.hasFilter});

  final int count;
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hasFilter ? 'Kết quả lọc' : 'Danh sách vận đơn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AdminColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AdminColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '$count vận đơn',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AdminColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
