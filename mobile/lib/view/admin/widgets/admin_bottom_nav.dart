import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/device_profiles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'admin_design_system.dart';

class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      _AdminNavItemData(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Tổng quan',
        route: AppRoutes.adminDashboard,
      ),
      _AdminNavItemData(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: 'Sản phẩm',
        route: AppRoutes.adminProducts,
      ),
      _AdminNavItemData(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: 'Đơn hàng',
        route: AppRoutes.adminOrders,
      ),
      _AdminNavItemData(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        label: 'Nhân sự',
        route: AppRoutes.adminStaff,
      ),
      _AdminNavItemData(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: 'Cài đặt',
        route: AppRoutes.adminSettings,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: const Border(
          top: BorderSide(color: AdminColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _AdminNavItem(
                    data: items[index],
                    selected: selectedIndex == index,
                    onTap: () => context.go(items[index].route),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItemData {
  const _AdminNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

class _AdminNavItem extends StatefulWidget {
  const _AdminNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _AdminNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_AdminNavItem> createState() => _AdminNavItemState();
}

class _AdminNavItemState extends State<_AdminNavItem> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final active = widget.selected || _hovered;
    final color = active ? AdminColors.primary : AdminColors.textSecondary;

    final content = Semantics(
      selected: widget.selected,
      button: true,
      label: widget.data.label,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: InkWell(
          onTap: widget.onTap,
          splashColor: AdminColors.action.withValues(alpha: 0.10),
          highlightColor: AdminColors.action.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: widget.selected
                    ? AdminColors.primarySoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: widget.selected
                      ? AdminColors.action.withValues(alpha: 0.18)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: _pressed ? 0.9 : (active ? 1.06 : 1),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 30,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: widget.selected
                            ? AdminDesign.actionGradient
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.selected
                            ? widget.data.selectedIcon
                            : widget.data.icon,
                        color: widget.selected ? Colors.white : color,
                        size: widget.selected ? 19 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: widget.selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!enableHover) return content;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: content,
    );
  }
}
