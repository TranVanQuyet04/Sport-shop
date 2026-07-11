part of '../customer_home_page.dart';

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            0,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: AppTextStyles.title),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

class _SeasonSaleHero extends StatelessWidget {
  const _SeasonSaleHero();

  @override
  Widget build(BuildContext context) {
    return const HoverLift(
      interactive: true,
      child: SportPerformanceHero(
        title: 'Gear sẵn sàng cho từng buổi tập',
        subtitle:
            'Giày, áo và phụ kiện thể thao chính hãng. Chọn nhanh theo môn, thương hiệu và nhịp vận động của bạn.',
        icon: Icons.directions_run_rounded,
        minHeight: 340,
        badges: [
          SportHeroBadge(label: 'RUN', icon: Icons.bolt_outlined),
          SportHeroBadge(
            label: 'GYM',
            icon: Icons.fitness_center_rounded,
            color: AppColors.accent,
          ),
          SportHeroBadge(label: '24H', icon: Icons.local_shipping_outlined),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories, required this.onTap});

  final List<NavigationCategoryModel> categories;
  final ValueChanged<NavigationCategoryModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return HoverLift(
            interactive: true,
            scale: 1.018,
            dy: -2,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () => onTap(category),
              child: Container(
                width: 106,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconForCategory(category.name),
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForCategory(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('giày') || normalized.contains('shoe')) {
      return Icons.directions_run;
    }
    if (normalized.contains('áo') || normalized.contains('ao')) {
      return Icons.checkroom;
    }
    if (normalized.contains('túi') || normalized.contains('tui')) {
      return Icons.backpack_outlined;
    }
    if (normalized.contains('quần') || normalized.contains('quan')) {
      return Icons.sports_martial_arts;
    }
    return Icons.sports_basketball;
  }
}
