import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
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
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.09),
            blurRadius: 28,
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
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    final color = active ? AdminColors.primary : AdminColors.textSecondary;

    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.data.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: InkWell(
            onTap: widget.onTap,
            splashColor: AdminColors.primary.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: widget.selected ? 32 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(999),
                    ),
                    boxShadow: widget.selected
                        ? [
                            BoxShadow(
                              color: AdminColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: _pressed ? 0.9 : (active ? 1.08 : 1),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          widget.selected
                              ? widget.data.selectedIcon
                              : widget.data.icon,
                          color: color,
                          size: widget.selected ? 23 : 21,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
