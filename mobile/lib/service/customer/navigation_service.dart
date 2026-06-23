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
    final json = await _apiClient.getJson(ApiEndpoints.navigationMain);
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map(
          (item) =>
              NavigationCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
