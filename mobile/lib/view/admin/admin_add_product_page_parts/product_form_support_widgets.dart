part of '../admin_add_product_page.dart';

class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminIconBadge(
          icon: Icons.add_photo_alternate_outlined,
          size: 52,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo sản phẩm mới',
                style: AppTextStyles.display.copyWith(
                  color: AdminColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hoàn thiện dữ liệu cơ bản và biến thể đầu tiên để đưa sản phẩm vào danh mục.',
                style: AppTextStyles.body.copyWith(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              first,
              const SizedBox(height: AppSpacing.lg),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _TipBox extends StatelessWidget {
  const _TipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminIconBadge(
            icon: Icons.lightbulb_outline_rounded,
            color: AdminColors.accent,
            backgroundColor: AdminColors.accentSoft,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo nhập liệu',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tên danh mục, thương hiệu và môn thể thao cần khớp dữ liệu backend để sản phẩm được phân loại chính xác.',
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.label,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.submitting, required this.onSubmit});

  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        boxShadow: [
          BoxShadow(
            color: AdminColors.navy.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: submitting ? 'ĐANG LƯU...' : 'LƯU SẢN PHẨM',
            icon: Icons.save_outlined,
            isLoading: submitting,
            backgroundColor: AdminColors.primary,
            onPressed: submitting ? null : onSubmit,
          ),
        ),
      ),
    );
  }
}

IconData _sportIcon(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('bóng đá') ||
      normalized.contains('bong da') ||
      normalized.contains('football') ||
      normalized.contains('soccer')) {
    return Icons.sports_soccer_outlined;
  }
  if (normalized.contains('bóng rổ') ||
      normalized.contains('bong ro') ||
      normalized.contains('basketball')) {
    return Icons.sports_basketball_outlined;
  }
  if (normalized.contains('quần vợt') ||
      normalized.contains('quan vot') ||
      normalized.contains('tennis') ||
      normalized.contains('cầu lông') ||
      normalized.contains('badminton')) {
    return Icons.sports_tennis_outlined;
  }
  if (normalized.contains('chạy') ||
      normalized.contains('chay') ||
      normalized.contains('running')) {
    return Icons.directions_run_rounded;
  }
  if (normalized.contains('bơi') || normalized.contains('swim')) {
    return Icons.pool_outlined;
  }
  if (normalized.contains('gym') || normalized.contains('fitness')) {
    return Icons.fitness_center_rounded;
  }
  return Icons.sports_outlined;
}
