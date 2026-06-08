import '../../repository/auth/auth_repository.dart';
import '../../repository/auth/auth_repository_impl.dart';
import '../../repository/customer/product_repository.dart';
import '../../repository/customer/product_repository_impl.dart';
import '../../service/auth/auth_service.dart';
import '../../service/customer/product_service.dart';
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

  late final ProductService productService = ProductApiService(apiClient);
  late final ProductRepository productRepository = ProductRepositoryImpl(productService);
}
