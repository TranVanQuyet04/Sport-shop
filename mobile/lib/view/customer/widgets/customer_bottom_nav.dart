import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/device_profiles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      _CustomerNavItemData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Trang chủ',
        route: AppRoutes.customerHome,
      ),
      _CustomerNavItemData(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search_rounded,
        label: 'Tìm kiếm',
        route: AppRoutes.search,
      ),
      _CustomerNavItemData(
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart_rounded,
        label: 'Giỏ hàng',
        route: AppRoutes.cart,
      ),
      _CustomerNavItemData(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: 'Đơn hàng',
        route: AppRoutes.orders,
      ),
      _CustomerNavItemData(
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        label: 'Cá nhân',
        route: AppRoutes.profile,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SuperSportsTheme.colorSurface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 26,
            offset: const Offset(0, -10),
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
                  child: _CustomerNavItem(
                    data: items[index],
                    selected: selectedIndex == index,
                    onTap: () {
                      if (GoRouterState.of(context).uri.toString() !=
                          items[index].route) {
                        context.go(items[index].route);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNavItemData {
  const _CustomerNavItemData({
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

class _CustomerNavItem extends StatefulWidget {
  const _CustomerNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _CustomerNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CustomerNavItem> createState() => _CustomerNavItemState();
}

class _CustomerNavItemState extends State<_CustomerNavItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    final color = active
        ? SuperSportsTheme.colorAccent
        : AppColors.textSecondary;
    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final content = Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: SuperSportsTheme.colorAccent.withValues(alpha: 0.10),
        highlightColor: SuperSportsTheme.colorAccent.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.enter,
            height: 62,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppColors.secondarySoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: widget.selected
                    ? AppColors.secondary.withValues(alpha: 0.18)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: _pressed ? 0.92 : (active ? 1.05 : 1),
                  duration: AppMotion.fast,
                  curve: AppMotion.enter,
                  child: Container(
                    width: 30,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: widget.selected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.secondary, AppColors.electric],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
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
    );

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.data.label,
      child: enableHover
          ? MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              cursor: SystemMouseCursors.click,
              child: content,
            )
          : content,
    );
  }
}
