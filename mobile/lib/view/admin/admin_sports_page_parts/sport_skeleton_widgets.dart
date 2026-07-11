part of '../admin_sports_page.dart';

class _SportSkeletonList extends StatelessWidget {
  const _SportSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        104,
      ),
      itemBuilder: (_, _) => const _SportSkeletonCard(),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemCount: 5,
    );
  }
}

class _SportSkeletonCard extends StatelessWidget {
  const _SportSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SuperSportsTheme.colorSurface,
        borderRadius: SuperSportsTheme.borderRadius,
        border: SuperSportsTheme.borderThin,
        boxShadow: SuperSportsTheme.softShadow,
      ),
      child: Row(
        children: [
          const _SkeletonBox(width: 48, height: 48, radius: 8),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonBox(width: 150, height: 16, radius: 8),
                SizedBox(height: AppSpacing.sm),
                _SkeletonBox(width: double.infinity, height: 12, radius: 8),
                SizedBox(height: AppSpacing.xs),
                _SkeletonBox(width: 180, height: 12, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
