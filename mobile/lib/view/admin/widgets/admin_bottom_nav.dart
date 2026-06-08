import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      indicatorColor: AppColors.surfaceMuted,
      backgroundColor: AppColors.surface,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Catalog'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Staff'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.adminDashboard);
            return;
          case 1:
            context.go(AppRoutes.adminProducts);
            return;
          case 2:
            context.go(AppRoutes.adminOrders);
            return;
          case 3:
            context.go(AppRoutes.adminStaff);
            return;
          case 4:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Màn cài đặt Admin sẽ được hoàn thiện ở bước sau')),
            );
            return;
        }
      },
    );
  }
}
