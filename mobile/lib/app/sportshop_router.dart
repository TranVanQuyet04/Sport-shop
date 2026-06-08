import 'package:go_router/go_router.dart';

import '../view/auth/login_page.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/register_page.dart';
import '../view/auth/reset_password_page.dart';
import '../view/admin/admin_dashboard_page.dart';
import '../view/admin/admin_add_product_page.dart';
import '../view/admin/admin_inventory_variants_page.dart';
import '../view/admin/admin_leave_management_page.dart';
import '../view/admin/admin_orders_page.dart';
import '../view/admin/admin_order_assignment_page.dart';
import '../view/admin/admin_products_page.dart';
import '../view/admin/admin_revenue_page.dart';
import '../view/admin/admin_shift_planning_page.dart';
import '../view/admin/admin_staff_page.dart';
import '../view/admin/admin_staff_detail_page.dart';
import '../view/admin/admin_staff_performance_page.dart';
import '../view/customer/add_address_page.dart';
import '../view/customer/address_book_page.dart';
import '../view/customer/cart_page.dart';
import '../view/customer/checkout_page.dart';
import '../view/customer/confirm_received_page.dart';
import '../view/customer/customer_home_page.dart';
import '../view/customer/customer_chat_page.dart';
import '../view/customer/customer_support_page.dart';
import '../view/customer/onboarding_page.dart';
import '../view/customer/order_detail_page.dart';
import '../view/customer/order_success_page.dart';
import '../view/customer/orders_page.dart';
import '../view/customer/product_detail_page.dart';
import '../view/customer/product_gallery_page.dart';
import '../view/customer/profile_page.dart';
import '../view/customer/search_page.dart';
import '../view/customer/tracking_page.dart';
import '../view/public/not_found_page.dart';
import '../view/public/unauthorized_page.dart';
import '../view/splash/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const unauthorized = '/unauthorized';
  static const onboarding = '/onboarding';
  static const customerHome = '/customer/home';
  static const search = '/customer/search';
  static const productDetail = '/customer/products/:id';
  static const productGallery = '/customer/products/:id/gallery';
  static const cart = '/customer/cart';
  static const checkout = '/customer/checkout';
  static const addressBook = '/customer/addresses';
  static const addAddress = '/customer/addresses/new';
  static const orderSuccess = '/customer/order-success';
  static const orders = '/customer/orders';
  static const orderDetail = '/customer/orders/:id';
  static const tracking = '/customer/orders/:id/tracking';
  static const confirmReceived = '/customer/orders/:id/confirm-received';
  static const profile = '/customer/profile';
  static const customerSupport = '/customer/support';
  static const customerChat = '/customer/support/chat';
  static const adminDashboard = '/admin/dashboard';
  static const adminRevenue = '/admin/revenue';
  static const adminOrders = '/admin/orders';
  static const adminProducts = '/admin/products';
  static const adminStaff = '/admin/staff';
  static const adminStaffDetail = '/admin/staff/:id';
  static const adminShiftPlanning = '/admin/staff/shifts';
  static const adminOrderAssignment = '/admin/staff/assign-orders';
  static const adminLeaveManagement = '/admin/staff/leaves';
  static const adminStaffPerformance = '/admin/staff/performance';
  static const adminAddProduct = '/admin/products/new';
  static const adminInventoryVariants = '/admin/products/:id/variants';
}

final sportshopRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'resetPassword',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.unauthorized,
      name: 'unauthorized',
      builder: (context, state) => const UnauthorizedPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.customerHome,
      name: 'customerHome',
      builder: (context, state) => const CustomerHomePage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      name: 'productDetail',
      builder: (context, state) => ProductDetailPage(
        productId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.productGallery,
      name: 'productGallery',
      builder: (context, state) => ProductGalleryPage(
        productId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: AppRoutes.addressBook,
      name: 'addressBook',
      builder: (context, state) => const AddressBookPage(),
    ),
    GoRoute(
      path: AppRoutes.addAddress,
      name: 'addAddress',
      builder: (context, state) => const AddAddressPage(),
    ),
    GoRoute(
      path: AppRoutes.orderSuccess,
      name: 'orderSuccess',
      builder: (context, state) => const OrderSuccessPage(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      name: 'orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      name: 'orderDetail',
      builder: (context, state) => OrderDetailPage(
        orderId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.tracking,
      name: 'tracking',
      builder: (context, state) => TrackingPage(
        orderId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.confirmReceived,
      name: 'confirmReceived',
      builder: (context, state) => ConfirmReceivedPage(
        orderId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.customerSupport,
      name: 'customerSupport',
      builder: (context, state) => const CustomerSupportPage(),
    ),
    GoRoute(
      path: AppRoutes.customerChat,
      name: 'customerChat',
      builder: (context, state) => const CustomerChatPage(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      name: 'adminDashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.adminRevenue,
      name: 'adminRevenue',
      builder: (context, state) => const AdminRevenuePage(),
    ),
    GoRoute(
      path: AppRoutes.adminOrders,
      name: 'adminOrders',
      builder: (context, state) => const AdminOrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.adminProducts,
      name: 'adminProducts',
      builder: (context, state) => const AdminProductsPage(),
    ),
    GoRoute(
      path: AppRoutes.adminStaff,
      name: 'adminStaff',
      builder: (context, state) => const AdminStaffPage(),
    ),
    GoRoute(
      path: AppRoutes.adminStaffDetail,
      name: 'adminStaffDetail',
      builder: (context, state) => AdminStaffDetailPage(staffId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.adminShiftPlanning,
      name: 'adminShiftPlanning',
      builder: (context, state) => const AdminShiftPlanningPage(),
    ),
    GoRoute(
      path: AppRoutes.adminOrderAssignment,
      name: 'adminOrderAssignment',
      builder: (context, state) => const AdminOrderAssignmentPage(),
    ),
    GoRoute(
      path: AppRoutes.adminLeaveManagement,
      name: 'adminLeaveManagement',
      builder: (context, state) => const AdminLeaveManagementPage(),
    ),
    GoRoute(
      path: AppRoutes.adminStaffPerformance,
      name: 'adminStaffPerformance',
      builder: (context, state) => const AdminStaffPerformancePage(),
    ),
    GoRoute(
      path: AppRoutes.adminAddProduct,
      name: 'adminAddProduct',
      builder: (context, state) => const AdminAddProductPage(),
    ),
    GoRoute(
      path: AppRoutes.adminInventoryVariants,
      name: 'adminInventoryVariants',
      builder: (context, state) => AdminInventoryVariantsPage(productId: state.pathParameters['id'] ?? ''),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
