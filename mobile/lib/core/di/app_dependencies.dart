import '../../repository/auth/auth_repository.dart';
import '../../repository/auth/auth_repository_impl.dart';
import '../../repository/chat/chat_repository.dart';
import '../../repository/chat/chat_repository_impl.dart';
import '../../repository/admin/admin_report_repository.dart';
import '../../repository/admin/admin_report_repository_impl.dart';
import '../../repository/admin/admin_catalog_repository.dart';
import '../../repository/admin/admin_catalog_repository_impl.dart';
import '../../repository/customer/address_repository.dart';
import '../../repository/customer/address_repository_impl.dart';
import '../../repository/customer/cart_repository.dart';
import '../../repository/customer/cart_repository_impl.dart';
import '../../repository/customer/checkout_repository.dart';
import '../../repository/customer/checkout_repository_impl.dart';
import '../../repository/customer/order_repository.dart';
import '../../repository/customer/order_repository_impl.dart';
import '../../repository/customer/navigation_repository.dart';
import '../../repository/customer/navigation_repository_impl.dart';
import '../../repository/customer/payment_repository.dart';
import '../../repository/customer/payment_repository_impl.dart';
import '../../repository/customer/product_repository.dart';
import '../../repository/customer/product_repository_impl.dart';
import '../../repository/customer/profile_repository.dart';
import '../../repository/customer/profile_repository_impl.dart';
import '../../service/auth/auth_service.dart';
import '../../service/chat/chat_service.dart';
import '../../service/admin/admin_report_service.dart';
import '../../service/admin/admin_catalog_service.dart';
import '../../service/customer/address_service.dart';
import '../../service/customer/cart_service.dart';
import '../../service/customer/checkout_service.dart';
import '../../service/customer/order_service.dart';
import '../../service/customer/navigation_service.dart';
import '../../service/customer/payment_service.dart';
import '../../service/customer/product_service.dart';
import '../../service/customer/profile_service.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  final ApiClient apiClient = ApiClient();
  final TokenStorage tokenStorage = const TokenStorage();

  late final AuthService authService = AuthApiService(apiClient);
  late final AuthRepository authRepository = AuthRepositoryImpl(
    authService: authService,
    tokenStorage: tokenStorage,
    apiClient: apiClient,
  );

  late final ChatService chatService = ChatApiService(apiClient);
  late final ChatRepository chatRepository = ChatRepositoryImpl(chatService);

  late final AdminReportService adminReportService = AdminReportApiService(
    apiClient,
  );
  late final AdminReportRepository adminReportRepository =
      AdminReportRepositoryImpl(adminReportService);

  late final AdminCatalogService adminCatalogService = AdminCatalogApiService(
    apiClient,
  );
  late final AdminCatalogRepository adminCatalogRepository =
      AdminCatalogRepositoryImpl(adminCatalogService);

  late final ProductService productService = ProductApiService(apiClient);
  late final ProductRepository productRepository = ProductRepositoryImpl(
    productService,
  );

  late final NavigationService navigationService = NavigationApiService(
    apiClient,
  );
  late final NavigationRepository navigationRepository =
      NavigationRepositoryImpl(navigationService);

  late final AddressService addressService = AddressApiService(apiClient);
  late final AddressRepository addressRepository = AddressRepositoryImpl(
    addressService,
  );

  late final CartService cartService = CartApiService(apiClient);
  late final CartRepository cartRepository = CartRepositoryImpl(cartService);

  late final CheckoutService checkoutService = CheckoutApiService(apiClient);
  late final CheckoutRepository checkoutRepository = CheckoutRepositoryImpl(
    checkoutService,
  );

  late final OrderService orderService = OrderApiService(apiClient);
  late final OrderRepository orderRepository = OrderRepositoryImpl(
    orderService,
  );

  late final PaymentService paymentService = PaymentApiService(apiClient);
  late final PaymentRepository paymentRepository = PaymentRepositoryImpl(
    paymentService,
  );

  late final ProfileService profileService = ProfileApiService(apiClient);
  late final ProfileRepository profileRepository = ProfileRepositoryImpl(
    profileService,
  );
}
