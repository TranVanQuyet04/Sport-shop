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

class _PremiumEmptyStateState extends State<PremiumEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final Animation<double> _floatingAnimation =
      Tween<double>(begin: 0, end: -12).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle ?? widget.message ?? '';
    final onPressed = widget.onActionPressed ?? widget.onAction;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
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
                AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          size: 38,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.52,
                    ),
                  ),
                ],
                if (onPressed != null && widget.actionLabel != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(
                        widget.actionIcon,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    return _ShimmerShell(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
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
        color: const Color(0xFFEFF3F8),
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
                Color(0xFFEFF3F8),
                Color(0xFFF8FAFC),
                Color(0xFFEFF3F8),
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
    );
  }
}
