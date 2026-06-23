import 'package:go_router/go_router.dart';

import '../core/auth/role_mapper.dart';
import '../core/di/app_dependencies.dart';
import '../model/customer/order_model.dart';
import '../view/auth/login_page.dart';
import '../view/auth/change_password_page.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/register_page.dart';
import '../view/auth/reset_password_page.dart';
import '../view/admin/admin_dashboard_page.dart';
import '../view/admin/admin_add_product_page.dart';
import '../view/admin/admin_brand_management_page.dart';
import '../view/admin/admin_category_management_page.dart';
import '../view/admin/admin_collections_page.dart';
import '../view/admin/admin_chat_detail_page.dart';
import '../view/admin/admin_chat_rooms_page.dart';
import '../view/admin/admin_delivery_monitoring_page.dart';
import '../view/admin/admin_inventory_variants_page.dart';
import '../view/admin/admin_orders_page.dart';
import '../view/admin/admin_products_page.dart';
import '../view/admin/admin_revenue_page.dart';
import '../view/admin/admin_staff_page.dart';
import '../view/admin/admin_staff_detail_page.dart';
import '../view/admin/admin_sports_page.dart';
import '../view/admin/admin_system_settings_page.dart';
import '../view/admin/admin_user_management_page.dart';
import '../view/admin/widgets/admin_design_system.dart';
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
import '../view/delivery_staff/assigned_orders_page.dart';
import '../view/delivery_staff/delivery_home_page.dart';
import '../view/delivery_staff/delivery_status_update_page.dart';
import '../view/delivery_staff/shipper_account_page.dart';
import '../view/public/guest_chat_page.dart';
import '../view/public/not_found_page.dart';
import '../view/public/unauthorized_page.dart';
import '../view/splash/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const changePassword = '/change-password';
  static const guestChat = '/guest-chat';
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
  static const adminAddProduct = '/admin/products/new';
  static const adminInventoryVariants = '/admin/products/:id/variants';
  static const adminCategories = '/admin/categories';
  static const adminBrands = '/admin/brands';
  static const adminSports = '/admin/sports';
  static const adminCollections = '/admin/collections';
  static const adminDeliveryMonitoring = '/admin/deliveries';
  static const adminChatRooms = '/admin/chats';
  static const adminChatDetail = '/admin/chats/:id';
  static const adminUsers = '/admin/users';
  static const adminSettings = '/admin/settings';
  static const deliveryHome = '/delivery-staff/home';
  static const deliveryAssignedOrders = '/delivery-staff/orders';
  static const deliveryStatusUpdate = '/delivery-staff/orders/:id/status';
  static const deliveryAccount = '/delivery-staff/account';
}

final sportshopRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final path = state.uri.path;
    final dependencies = AppDependencies.instance;
    final token = await dependencies.tokenStorage.readAccessToken();
    final role = _normalizeRole(await dependencies.tokenStorage.readRole());

    if (token != null && token.isNotEmpty) {
      dependencies.apiClient.setBearerToken(token);
    }

    final isPublicPath =
        path == AppRoutes.splash ||
        path == AppRoutes.login ||
        path == AppRoutes.register ||
        path == AppRoutes.forgotPassword ||
        path == AppRoutes.resetPassword ||
        path == AppRoutes.guestChat ||
        path == AppRoutes.unauthorized ||
        path == AppRoutes.onboarding ||
        path.startsWith('/customer/products') ||
        path == AppRoutes.search ||
        path == AppRoutes.customerHome;

    if ((token == null || token.isEmpty) && !isPublicPath) {
      return AppRoutes.login;
    }

    if (token != null && token.isNotEmpty && path == AppRoutes.login) {
      return _homeForRole(role);
    }

    if (path.startsWith('/admin') && role != 'ADMIN') {
      return _homeForRole(role);
    }
    if (path.startsWith('/delivery-staff') &&
        role != 'SHIPPER' &&
        role != 'ADMIN') {
      return _homeForRole(role);
    }
    return null;
  },
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
      path: AppRoutes.changePassword,
      name: 'changePassword',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.guestChat,
      name: 'guestChat',
      builder: (context, state) => const GuestChatPage(),
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
      builder: (context, state) =>
          ProductDetailPage(productId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.productGallery,
      name: 'productGallery',
      builder: (context, state) =>
          ProductGalleryPage(productId: state.pathParameters['id'] ?? ''),
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
      builder: (context, state) {
        final extra = state.extra;
        final data = extra is Map ? extra : const {};
        final order = data['order'];
        return OrderSuccessPage(
          order: order is OrderModel ? order : null,
          paymentUrl: data['paymentUrl']?.toString(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orders,
      name: 'orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      name: 'orderDetail',
      builder: (context, state) =>
          OrderDetailPage(orderId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.tracking,
      name: 'tracking',
      builder: (context, state) =>
          TrackingPage(orderId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.confirmReceived,
      name: 'confirmReceived',
      builder: (context, state) =>
          ConfirmReceivedPage(orderId: state.pathParameters['id'] ?? ''),
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
      builder: (context, state) =>
          const AdminThemeScope(child: AdminDashboardPage()),
    ),
    GoRoute(
      path: AppRoutes.adminRevenue,
      name: 'adminRevenue',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminRevenuePage()),
    ),
    GoRoute(
      path: AppRoutes.adminOrders,
      name: 'adminOrders',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminOrdersPage()),
    ),
    GoRoute(
      path: AppRoutes.adminProducts,
      name: 'adminProducts',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminProductsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminStaff,
      name: 'adminStaff',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminStaffPage()),
    ),
    GoRoute(
      path: AppRoutes.adminStaffDetail,
      name: 'adminStaffDetail',
      builder: (context, state) => AdminThemeScope(
        child: AdminStaffDetailPage(staffId: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminAddProduct,
      name: 'adminAddProduct',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminAddProductPage()),
    ),
    GoRoute(
      path: AppRoutes.adminInventoryVariants,
      name: 'adminInventoryVariants',
      builder: (context, state) => AdminThemeScope(
        child: AdminInventoryVariantsPage(
          productId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminCategories,
      name: 'adminCategories',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminCategoryManagementPage()),
    ),
    GoRoute(
      path: AppRoutes.adminBrands,
      name: 'adminBrands',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminBrandManagementPage()),
    ),
    GoRoute(
      path: AppRoutes.adminSports,
      name: 'adminSports',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminSportsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminCollections,
      name: 'adminCollections',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminCollectionsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminDeliveryMonitoring,
      name: 'adminDeliveryMonitoring',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminDeliveryMonitoringPage()),
    ),
    GoRoute(
      path: AppRoutes.adminChatRooms,
      name: 'adminChatRooms',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminChatRoomsPage()),
    ),
    GoRoute(
      path: AppRoutes.adminChatDetail,
      name: 'adminChatDetail',
      builder: (context, state) => AdminThemeScope(
        child: AdminChatDetailPage(chatId: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      name: 'adminUsers',
      builder: (context, state) => AdminThemeScope(
        child: AdminUserManagementPage(
          initialRole: state.uri.queryParameters['role'],
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.adminSettings,
      name: 'adminSettings',
      builder: (context, state) =>
          const AdminThemeScope(child: AdminSystemSettingsPage()),
    ),
    GoRoute(
      path: AppRoutes.deliveryHome,
      name: 'deliveryHome',
      builder: (context, state) => const DeliveryHomePage(),
    ),
    GoRoute(
      path: AppRoutes.deliveryAssignedOrders,
      name: 'deliveryAssignedOrders',
      builder: (context, state) => const AssignedOrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.deliveryStatusUpdate,
      name: 'deliveryStatusUpdate',
      builder: (context, state) =>
          DeliveryStatusUpdatePage(orderId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.deliveryAccount,
      name: 'deliveryAccount',
      builder: (context, state) => const ShipperAccountPage(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);

String _normalizeRole(String? role) {
  return RoleMapper.normalize(role);
}

String _homeForRole(String role) {
  return switch (role) {
    'ADMIN' => AppRoutes.adminDashboard,
    'SHIPPER' => AppRoutes.deliveryHome,
    'MEMBER' => AppRoutes.customerHome,
    _ => AppRoutes.login,
  };
}
