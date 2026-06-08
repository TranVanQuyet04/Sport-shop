import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/sportshop_router.dart';
import '../../../core/theme/app_colors.dart';

class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      indicatorColor: Colors.transparent,
      backgroundColor: AppColors.surface,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Đơn hàng'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
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
              const SnackBar(content: Text('Màn hình đang được hoàn thiện')),
            );
            return;
        }
      },
    );
  }
}
