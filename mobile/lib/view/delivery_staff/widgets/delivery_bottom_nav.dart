import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/theme/app_colors.dart';

class DeliveryBottomNav extends StatelessWidget {
  const DeliveryBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.surfaceMuted,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Đơn giao',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping),
          label: 'Cập nhật',
        ),
        NavigationDestination(
          icon: Icon(Icons.report_problem_outlined),
          selectedIcon: Icon(Icons.report_problem),
          label: 'Báo cáo',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.deliveryHome);
            return;
          case 1:
            context.go(AppRoutes.deliveryAssignedOrders);
            return;
          case 2:
            context.go('/delivery-staff/orders/AV-8842/status');
            return;
          case 3:
            context.go('/delivery-staff/orders/AV-8842/failed-report');
            return;
          case 4:
            context.go(AppRoutes.deliveryAccount);
            return;
        }
      },
    );
  }
}
