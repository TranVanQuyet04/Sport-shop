import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            indicatorColor: AppColors.secondarySoft,
            backgroundColor: Colors.transparent,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: 'Tìm kiếm',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Giỏ hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Đơn hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.customerHome);
                  return;
                case 1:
                  context.go(AppRoutes.search);
                  return;
                case 2:
                  context.go(AppRoutes.cart);
                  return;
                case 3:
                  context.go(AppRoutes.orders);
                  return;
                case 4:
                  context.go(AppRoutes.profile);
                  return;
                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Màn hình đang được hoàn thiện'),
                    ),
                  );
                  return;
              }
            },
          ),
        ),
      ),
    );
  }
}
