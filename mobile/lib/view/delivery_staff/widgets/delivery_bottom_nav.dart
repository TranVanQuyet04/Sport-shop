import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/device_profiles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DeliveryBottomNav extends StatelessWidget {
  const DeliveryBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      _DeliveryNavItemData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Trang chủ',
        route: AppRoutes.deliveryHome,
      ),
      _DeliveryNavItemData(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: 'Đơn giao',
        route: AppRoutes.deliveryAssignedOrders,
      ),
      _DeliveryNavItemData(
        icon: Icons.location_on_outlined,
        selectedIcon: Icons.location_on_rounded,
        label: 'Cập nhật',
        route: AppRoutes.deliveryAssignedOrders,
      ),
      _DeliveryNavItemData(
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        label: 'Tài khoản',
        route: AppRoutes.deliveryAccount,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SuperSportsTheme.colorSurface,
        border: const Border(
          top: BorderSide(color: AppColors.successBorder, width: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shipperPrimary.withValues(alpha: 0.12),
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
                  child: _DeliveryNavItem(
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

class _DeliveryNavItemData {
  const _DeliveryNavItemData({
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

class _DeliveryNavItem extends StatefulWidget {
  const _DeliveryNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _DeliveryNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DeliveryNavItem> createState() => _DeliveryNavItemState();
}

class _DeliveryNavItemState extends State<_DeliveryNavItem> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final active = widget.selected || _hovered;
    final color = active ? AppColors.shipperPrimary : AppColors.textSecondary;
    final content = Semantics(
      button: true,
      selected: widget.selected,
      label: widget.data.label,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: InkWell(
          onTap: widget.onTap,
          splashColor: SuperSportsTheme.colorAccent.withValues(alpha: 0.08),
          highlightColor: SuperSportsTheme.colorAccent.withValues(alpha: 0.04),
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
                      ? AppColors.secondary.withValues(alpha: 0.20)
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
                                colors: [
                                  AppColors.shipperPrimary,
                                  AppColors.secondary,
                                ],
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
