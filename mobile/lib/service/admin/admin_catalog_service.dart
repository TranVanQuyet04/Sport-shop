import '../../core/network/api_client.dart';
import '../../core/auth/role_mapper.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/admin/collection_model.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

part 'admin_catalog_service_parts/admin_catalog_service_contract.dart';
part 'admin_catalog_service_parts/admin_product_catalog_api.dart';
part 'admin_catalog_service_parts/admin_category_brand_api.dart';
part 'admin_catalog_service_parts/admin_user_catalog_api.dart';
part 'admin_catalog_service_parts/admin_sport_collection_api.dart';
part 'admin_catalog_service_parts/admin_catalog_api_helpers.dart';

abstract class _AdminCatalogApiBase {
  const _AdminCatalogApiBase();

  ApiClient get _apiClient;
}

class AdminCatalogApiService extends _AdminCatalogApiBase
    with
        _AdminProductCatalogApi,
        _AdminCategoryBrandApi,
        _AdminUserCatalogApi,
        _AdminSportCollectionApi
    implements AdminCatalogService {
  const AdminCatalogApiService(this._apiClient);

  @override
  final ApiClient _apiClient;
}
