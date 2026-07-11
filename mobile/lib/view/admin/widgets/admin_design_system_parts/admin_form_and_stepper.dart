part of '../admin_design_system.dart';

class AdminFormSection extends StatelessWidget {
  const AdminFormSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminIconBadge(icon: icon),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class AdminProgressStepper extends StatelessWidget {
  const AdminProgressStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: _AdminProgressStep(
                label: steps[index],
                number: index + 1,
                completed: index < currentStep,
                active: index == currentStep,
              ),
            ),
            if (index < steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 3,
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? AdminColors.success
                          : AdminColors.inputBorder,
                      borderRadius: BorderRadius.circular(AdminDesign.radius),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AdminProgressStep extends StatelessWidget {
  const _AdminProgressStep({
    required this.label,
    required this.number,
    required this.completed,
    required this.active,
  });

  final String label;
  final int number;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final foreground = completed
        ? AdminColors.success
        : active
        ? AdminColors.primary
        : AdminColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? AdminColors.successSoft
                : active
                ? AdminColors.primary
                : AdminColors.surfaceMuted,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AdminColors.primary.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: completed
              ? const Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: AdminColors.success,
                )
              : Text(
                  '$number',
                  style: AppTextStyles.caption.copyWith(
                    color: active ? Colors.white : foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: foreground,
            fontWeight: active || completed ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
