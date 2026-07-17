import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/common/backend_models.dart';

abstract interface class NavigationService {
  Future<List<NavigationCategoryModel>> getMainNavigation();
}

class NavigationApiService implements NavigationService {
  const NavigationApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<NavigationCategoryModel>> getMainNavigation() async {
    // The public category endpoint is the backend's complete category
    // contract. It returns a flat list with parentId, which is rebuilt into
    // the hierarchy consumed by the home page and drawer.
    final json = await _apiClient.getJson(ApiEndpoints.productCategories);
    final rawItems = json['result'] ?? json['data'] ?? json['content'] ?? [];
    if (rawItems is! List) {
      return const [];
    }
    return NavigationCategoryModel.treeFromFlatJson(rawItems);
  }
}
