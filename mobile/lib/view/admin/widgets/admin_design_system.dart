import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';

abstract final class AdminColors {
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF8F9FA);
  static const Color navy = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryPressed = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEAF2FF);
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentSoft = Color(0xFFFFF0E6);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF667085);
  static const Color label = Color(0xFF475569);
  static const Color border = Color(0xFFE7EAF0);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warningSoft = Color(0xFFFFF7ED);
}

abstract final class AdminDesign {
  static const double radius = AppRadius.xl;
  static const EdgeInsets pagePadding = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.lg);
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class AdminThemeScope extends StatelessWidget {
  const AdminThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: AdminColors.primary,
          secondary: AdminColors.accent,
          surface: AdminColors.surface,
        ),
        scaffoldBackgroundColor: AdminColors.background,
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: AdminColors.surface,
          foregroundColor: AdminColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AdminColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminDesign.radius),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AdminColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminDesign.radius),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AdminDesign.radius)),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AdminColors.primary,
          selectionColor: AdminColors.primary.withValues(alpha: 0.2),
          selectionHandleColor: AdminColors.primary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AdminColors.primary.withValues(alpha: 0.42);
              }
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return AdminColors.primaryPressed;
              }
              return AdminColors.primary;
            }),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.12),
            ),
            elevation: const WidgetStatePropertyAll(0),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? AdminColors.primaryPressed
                  : AdminColors.primary,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered)
                  ? AdminColors.primarySoft
                  : Colors.transparent,
            ),
            overlayColor: WidgetStatePropertyAll(
              AdminColors.primary.withValues(alpha: 0.08),
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AdminColors.border),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: AdminColors.surfaceMuted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(
              color: AdminColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.danger, width: 1.5),
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AdminColors.textSecondary.withValues(alpha: 0.72),
          ),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AdminColors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: AdminColors.surface,
          selectedColor: AdminColors.primary,
          disabledColor: AdminColors.surfaceMuted,
          side: const BorderSide(color: AdminColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AdminColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
          secondaryLabelStyle: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          showCheckmark: false,
        ),
        dividerTheme: const DividerThemeData(
          color: AdminColors.border,
          thickness: 1,
          space: 1,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AdminColors.navy,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
        ),
      ),
      child: child,
    );
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          AdminIconBadge(icon: icon!),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.display.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.body.copyWith(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}

class AdminSurface extends StatelessWidget {
  const AdminSurface({
    super.key,
    required this.child,
    this.padding = AdminDesign.cardPadding,
    this.onTap,
    this.color = AdminColors.surface,
    this.hoverEnabled = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final bool hoverEnabled;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      enabled: hoverEnabled,
      interactive: onTap != null,
      scale: 1.012,
      dy: -2,
      borderRadius: BorderRadius.circular(AdminDesign.radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AdminDesign.radius),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AdminDesign.radius),
            boxShadow: AdminDesign.cardShadow,
          ),
          child: onTap == null
              ? child
              : InkWell(
                  onTap: onTap,
                  splashColor: AdminColors.primary.withValues(alpha: 0.1),
                  highlightColor: AdminColors.primary.withValues(alpha: 0.04),
                  child: child,
                ),
        ),
      ),
    );
  }
}

class AdminOutlinedSurface extends StatelessWidget {
  const AdminOutlinedSurface({
    super.key,
    required this.child,
    this.padding = AdminDesign.cardPadding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      interactive: onTap != null,
      scale: 1.008,
      dy: -1,
      hoverShadow: true,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Material(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AdminColors.inputBorder),
          ),
          child: onTap == null
              ? child
              : InkWell(
                  onTap: onTap,
                  splashColor: AdminColors.primary.withValues(alpha: 0.08),
                  highlightColor: AdminColors.primary.withValues(alpha: 0.03),
                  child: child,
                ),
        ),
      ),
    );
  }
}

enum AdminEntityAction { edit, delete }

class AdminEntityMenu extends StatelessWidget {
  const AdminEntityMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AdminEntityAction>(
      tooltip: 'Thao tác',
      color: AdminColors.surface,
      elevation: 8,
      shadowColor: AdminColors.navy.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AdminColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case AdminEntityAction.edit:
            onEdit();
            return;
          case AdminEntityAction.delete:
            onDelete();
            return;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: AdminEntityAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 19, color: AdminColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text('Sửa'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: AdminEntityAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 19,
                color: AdminColors.danger,
              ),
              SizedBox(width: AppSpacing.sm),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminIconBadge extends StatelessWidget {
  const AdminIconBadge({
    super.key,
    required this.icon,
    this.color = AdminColors.primary,
    this.backgroundColor = AdminColors.primarySoft,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class AdminInlineBanner extends StatelessWidget {
  const AdminInlineBanner({
    super.key,
    required this.message,
    this.onRefresh,
    this.isError = false,
  });

  final String message;
  final VoidCallback? onRefresh;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AdminColors.primary;
    final background = isError
        ? AppColors.error.withValues(alpha: 0.08)
        : AdminColors.primarySoft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AdminDesign.radius),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
          if (onRefresh != null)
            TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class AdminFormField extends StatelessWidget {
  const AdminFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.required = false,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final bool obscureText;
  final bool required;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: AppTextStyles.caption.copyWith(
            color: AdminColors.label,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          minLines: minLines,
          maxLines: maxLines,
          enabled: enabled,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 20),
          ),
          validator:
              validator ??
              (value) {
                if (required && (value == null || value.trim().isEmpty)) {
                  return 'Vui lòng nhập thông tin.';
                }
                return null;
              },
        ),
      ],
    );
  }
}

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
                      borderRadius: BorderRadius.circular(999),
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
