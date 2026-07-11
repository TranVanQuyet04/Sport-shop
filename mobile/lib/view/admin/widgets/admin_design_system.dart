import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';

part 'admin_design_system_parts/admin_surfaces.dart';
part 'admin_design_system_parts/admin_content_widgets.dart';
part 'admin_design_system_parts/admin_form_and_stepper.dart';

abstract final class AdminColors {
  static const Color background = AppColors.adminBackground;
  static const Color backgroundDeep = Color(0xFFE8F0FA);
  static const Color surface = SuperSportsTheme.colorSurface;
  static const Color surfaceMuted = Color(0xFFF0F5FB);
  static const Color surfaceTint = Color(0xFFF7FAFF);
  static const Color navy = AppColors.adminPrimary;
  static const Color primary = AppColors.adminPrimary;
  static const Color primaryPressed = AppColors.primaryPressed;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color action = AppColors.adminAction;
  static const Color actionPressed = AppColors.electricPressed;
  static const Color actionSoft = AppColors.infoSoft;
  static const Color accent = AppColors.adminAccent;
  static const Color accentSoft = Color(0xFFE1F6F3);
  static const Color textPrimary = SuperSportsTheme.textDark;
  static const Color textSecondary = SuperSportsTheme.textMuted;
  static const Color label = AppColors.textSecondary;
  static const Color border = AppColors.border;
  static const Color inputBorder = AppColors.border;
  static const Color success = SuperSportsTheme.colorAccent;
  static const Color successSoft = AppColors.secondarySoft;
  static const Color danger = AppColors.error;
  static const Color dangerSoft = AppColors.errorSoft;
  static const Color warningSoft = AppColors.accentSoft;

  // ── Extended palette (dashboard design system) ─────────────────────────────
  static const Color ink = SuperSportsTheme.textDark;
  static const Color muted = SuperSportsTheme.textMuted;
  static const Color subtle = AppColors.surfaceMuted;

  static const Color blue = AppColors.info;
  static const Color blueDark = AppColors.info;
  static const Color blueSoft = actionSoft;

  static const Color orange = AppColors.accent;
  static const Color orangeSoft = AppColors.accentSoft;

  static const Color green = AppColors.success;
  static const Color greenSoft = AppColors.secondarySoft;

  static const Color red = AppColors.error;
  static const Color redSoft = AppColors.errorSoft;

  static const Color purple = AppColors.electric;
  static const Color purpleSoft = AppColors.electricSoft;
}

abstract final class AdminDesign {
  static const double radius = 8;
  static const EdgeInsets pagePadding = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.lg);
  static List<BoxShadow> get cardShadow => AppElevation.soft;
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AdminColors.backgroundDeep, AdminColors.background],
  );
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdminColors.surface, AdminColors.surfaceTint],
  );
  static const LinearGradient actionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AdminColors.primary, AdminColors.action],
  );
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
          secondary: AdminColors.action,
          tertiary: AdminColors.accent,
          surface: AdminColors.surface,
        ),
        scaffoldBackgroundColor: AdminColors.background,
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: AdminColors.surface,
          foregroundColor: AdminColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.subtitle.copyWith(
            color: AdminColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
          iconTheme: const IconThemeData(color: AdminColors.primary),
          actionsIconTheme: const IconThemeData(color: AdminColors.primary),
          shape: const Border(
            bottom: BorderSide(color: AdminColors.border, width: 0.5),
          ),
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
                return AdminColors.action.withValues(alpha: 0.42);
              }
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return AdminColors.actionPressed;
              }
              return AdminColors.action;
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
