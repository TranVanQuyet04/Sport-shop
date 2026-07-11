import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/hover_effect.dart';
import 'admin_design_system.dart';

enum AdminAppBarVariant { admin, shipper }

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    this.largeLogo = false,
    this.title,
    this.variant = AdminAppBarVariant.admin,
  });

  final bool largeLogo;
  final String? title;
  final AdminAppBarVariant variant;

  @override
  Size get preferredSize => Size.fromHeight(largeLogo ? 88 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isShipper = variant == AdminAppBarVariant.shipper;
    final defaultTitle = largeLogo ? 'StrideX\nADMIN' : 'StrideX ADMIN';
    final titleText = isShipper ? 'StrideX SHIPPER' : (title ?? defaultTitle);
    final homeRoute = isShipper
        ? AppRoutes.deliveryHome
        : AppRoutes.adminDashboard;
    final actionRoute = isShipper
        ? AppRoutes.deliveryAssignedOrders
        : AppRoutes.adminDeliveryMonitoring;
    final actionIcon = isShipper
        ? Icons.assignment_outlined
        : Icons.local_shipping_outlined;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AdminColors.surface, AdminColors.surfaceTint],
        ),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: _HeaderIconButton(
          icon: isShipper
              ? Icons.local_shipping_outlined
              : Icons.dashboard_outlined,
          tooltip: isShipper ? 'Trang giao hàng' : 'Tổng quan',
          onPressed: () => context.go(homeRoute),
        ),
        title: Text(
          titleText,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: largeLogo ? 32 : 19,
            height: largeLogo ? 0.98 : 1,
            color: AdminColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          _HeaderIconButton(
            icon: actionIcon,
            tooltip: isShipper ? 'Đơn được giao' : 'Theo dõi giao hàng',
            onPressed: () => context.go(actionRoute),
          ),
          if (!largeLogo)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AdminColors.primarySoft,
                child: Icon(
                  isShipper ? Icons.delivery_dining : Icons.person,
                  size: 18,
                  color: AdminColors.primary,
                ),
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
        interactive: true,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: AdminColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AdminColors.action.withValues(alpha: 0.12),
              ),
            ),
            child: SizedBox(
              width: 42,
              height: 42,
              child: IconButton(
                tooltip: tooltip,
                onPressed: onPressed,
                icon: Icon(icon, color: AdminColors.primary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
