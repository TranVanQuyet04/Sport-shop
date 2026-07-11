import 'package:flutter/material.dart';

abstract final class AppColors {
  // StrideX performance palette: technical navy, track green, electric blue,
  // and a restrained energy orange for high-value highlights.
  static const Color primary = Color(0xFF06192B);
  static const Color primaryPressed = Color(0xFF03101C);
  static const Color primarySoft = Color(0xFFE6EEF8);
  static const Color secondary = Color(0xFF16A34A);
  static const Color secondaryPressed = Color(0xFF12823C);
  static const Color secondarySoft = Color(0xFFE6F8ED);
  static const Color accent = Color(0xFFF97316);
  static const Color accentPressed = Color(0xFFEA580C);
  static const Color accentSoft = Color(0xFFFFEFE3);
  static const Color electric = Color(0xFF2563EB);
  static const Color electricPressed = Color(0xFF1D4ED8);
  static const Color electricSoft = Color(0xFFEAF1FF);

  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEAF0F7);
  static const Color surfaceSport = Color(0xFFF7FAFC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD8E2ED);
  static const Color borderStrong = Color(0xFFBFD0E1);

  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF526174);
  static const Color textTertiary = Color(0xFF7B8A9C);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color success = secondary;
  static const Color warning = accent;
  static const Color error = Color(0xFFDC2626);
  static const Color info = electric;

  static const Color infoSoft = electricSoft;
  static const Color successSoft = secondarySoft;
  static const Color warningSoft = accentSoft;
  static const Color errorSoft = Color(0xFFFEECEE);

  static const Color infoBorder = Color(0xFFB9D7FF);
  static const Color successBorder = Color(0xFFBDECCB);
  static const Color warningBorder = Color(0xFFFFD2A8);
  static const Color errorBorder = Color(0xFFF8B4B4);

  static const Color scrim = Color(0xA603111F);

  static const Color customerPrimary = primary;
  static const Color customerAccent = secondary;
  static const Color customerEnergy = accent;
  static const Color customerAction = electric;
  static const Color customerBackground = background;

  static const Color adminPrimary = Color(0xFF08213A);
  static const Color adminAction = electric;
  static const Color adminAccent = Color(0xFF0F766E);
  static const Color adminBackground = Color(0xFFF2F6FB);

  static const Color shipperPrimary = Color(0xFF063826);
  static const Color shipperAction = secondary;
  static const Color shipperAccent = accent;
  static const Color shipperBackground = Color(0xFFF2F9F5);
}

enum AppRole { customer, admin, shipper }

class AppRolePalette {
  const AppRolePalette({
    required this.role,
    required this.primary,
    required this.action,
    required this.accent,
    required this.background,
    required this.soft,
    required this.name,
  });

  final AppRole role;
  final Color primary;
  final Color action;
  final Color accent;
  final Color background;
  final Color soft;
  final String name;

  static const customer = AppRolePalette(
    role: AppRole.customer,
    primary: AppColors.customerPrimary,
    action: AppColors.customerAccent,
    accent: AppColors.customerEnergy,
    background: AppColors.customerBackground,
    soft: AppColors.secondarySoft,
    name: 'Customer',
  );

  static const admin = AppRolePalette(
    role: AppRole.admin,
    primary: AppColors.adminPrimary,
    action: AppColors.adminAction,
    accent: AppColors.adminAccent,
    background: AppColors.adminBackground,
    soft: AppColors.electricSoft,
    name: 'Admin',
  );

  static const shipper = AppRolePalette(
    role: AppRole.shipper,
    primary: AppColors.shipperPrimary,
    action: AppColors.shipperAction,
    accent: AppColors.shipperAccent,
    background: AppColors.shipperBackground,
    soft: AppColors.secondarySoft,
    name: 'Shipper',
  );
}

abstract final class SuperSportsTheme {
  static const Color colorPrimary = AppColors.customerPrimary;
  static const Color colorAccent = AppColors.customerAccent;
  static const Color colorEnergy = AppColors.customerEnergy;
  static const Color colorAction = AppColors.customerAction;
  static const Color colorBackground = AppColors.customerBackground;
  static const Color colorSurface = Color(0xFFFFFFFF);
  static const Color textDark = AppColors.textPrimary;
  static const Color textMuted = AppColors.textSecondary;

  static final BorderRadius borderRadius = BorderRadius.circular(8);
  static const Border borderThin = Border.fromBorderSide(
    BorderSide(color: AppColors.border, width: 0.5),
  );
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

abstract final class AppElevation {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.20),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get raised => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: AppColors.electric.withValues(alpha: 0.07),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> role(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 26,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
