part of '../app_state.dart';

class PremiumShimmerList extends StatelessWidget {
  const PremiumShimmerList({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      0,
    ),
    this.itemHeight = 178,
    this.showThumbnail = true,
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;
  final double itemHeight;
  final bool showThumbnail;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _PremiumSkeletonCard(
        height: itemHeight,
        showThumbnail: showThumbnail,
      ),
    );
  }
}

class _PremiumSkeletonCard extends StatelessWidget {
  const _PremiumSkeletonCard({
    required this.height,
    required this.showThumbnail,
  });

  final double height;
  final bool showThumbnail;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height < 204 ? 204.0 : height;

    return _ShimmerShell(
      child: Container(
        height: effectiveHeight,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppElevation.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showThumbnail) ...[
                  const _SkeletonBox(width: 64, height: 64, radius: 14),
                  const SizedBox(width: AppSpacing.md),
                ],
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(widthFactor: 0.62, height: 16),
                      SizedBox(height: AppSpacing.sm),
                      _SkeletonBox(widthFactor: 0.42, height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const _SkeletonBox(width: 82, height: 26, radius: 999),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SkeletonBox(widthFactor: 1, height: 44, radius: 12),
            const Spacer(),
            const Row(
              children: [
                _SkeletonBox(width: 108, height: 14),
                Spacer(),
                _SkeletonBox(width: 96, height: 34, radius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    this.widthFactor,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double? widthFactor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (widthFactor == null) {
      return box;
    }
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: box,
    );
  }
}

class _ShimmerShell extends StatefulWidget {
  const _ShimmerShell({required this.child});

  final Widget child;

  @override
  State<_ShimmerShell> createState() => _ShimmerShellState();
}

class _ShimmerShellState extends State<_ShimmerShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerWidth = bounds.width * 0.55;
            final dx =
                (bounds.width + shimmerWidth) * _controller.value -
                shimmerWidth;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.surfaceMuted,
                AppColors.surface,
                AppColors.surfaceMuted,
              ],
              stops: const [0.2, 0.5, 0.8],
              transform: _SlidingGradientTransform(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.dx);

  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}
