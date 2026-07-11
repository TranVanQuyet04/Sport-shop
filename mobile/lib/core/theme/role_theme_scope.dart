import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class RoleThemeScope extends StatelessWidget {
  const RoleThemeScope({super.key, required this.palette, required this.child});

  final AppRolePalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final roleScheme = base.colorScheme.copyWith(
      primary: palette.primary,
      secondary: palette.action,
      tertiary: palette.accent,
      surface: AppColors.surface,
      outline: AppColors.border,
    );

    return Theme(
      data: base.copyWith(
        colorScheme: roleScheme,
        scaffoldBackgroundColor: palette.background,
        hoverColor: palette.action.withValues(alpha: 0.06),
        highlightColor: palette.action.withValues(alpha: 0.06),
        focusColor: palette.action.withValues(alpha: 0.14),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: AppColors.surface,
          foregroundColor: palette.primary,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
            foregroundColor: const WidgetStatePropertyAll(
              AppColors.textInverse,
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return palette.action.withValues(alpha: 0.38);
              }
              if (states.contains(WidgetState.pressed)) {
                return palette.primary;
              }
              if (states.contains(WidgetState.hovered)) {
                return palette.accent;
              }
              return palette.action;
            }),
            overlayColor: WidgetStatePropertyAll(
              AppColors.textInverse.withValues(alpha: 0.12),
            ),
            elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered) ? 4 : 1,
            ),
            textStyle: WidgetStatePropertyAll(
              AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: palette.action, width: 1.5),
          ),
          prefixIconColor: palette.primary,
          suffixIconColor: palette.primary,
        ),
        navigationBarTheme: base.navigationBarTheme.copyWith(
          indicatorColor: palette.soft,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return AppTextStyles.caption.copyWith(
              color: selected ? palette.action : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? palette.action : AppColors.textSecondary,
              size: selected ? 24 : 22,
            );
          }),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: palette.accent,
          foregroundColor: AppColors.textInverse,
          elevation: 5,
          focusElevation: 7,
          hoverElevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          ),
        ),
      ),
      child: child,
    );
  }
}
