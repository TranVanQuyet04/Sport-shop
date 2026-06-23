import '../../model/common/backend_models.dart';

abstract interface class NavigationRepository {
  Future<List<NavigationCategoryModel>> getMainNavigation();
}
