import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';
import 'admin_design_system.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key, this.largeLogo = false});

  final bool largeLogo;

  @override
  Size get preferredSize => Size.fromHeight(largeLogo ? 88 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: _HeaderIconButton(
          icon: Icons.dashboard_outlined,
          tooltip: 'Tổng quan',
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: Text(
          largeLogo ? 'SPORTSHOP\nADMIN' : 'SPORTSHOP ADMIN',
          style: AppTextStyles.display.copyWith(
            fontSize: largeLogo ? 32 : 19,
            height: largeLogo ? 0.98 : 1,
            color: AdminColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          _HeaderIconButton(
            icon: Icons.local_shipping_outlined,
            tooltip: 'Theo dõi giao hàng',
            onPressed: () => context.go(AppRoutes.adminDeliveryMonitoring),
          ),
          if (!largeLogo)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AdminColors.primarySoft,
                child: Icon(Icons.person, size: 18, color: AdminColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: HoverLift(
        scale: 1.04,
        dy: -1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AdminColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon, color: AdminColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }
}
