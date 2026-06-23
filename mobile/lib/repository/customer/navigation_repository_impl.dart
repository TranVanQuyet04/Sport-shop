import '../../model/common/backend_models.dart';
import '../../service/customer/navigation_service.dart';
import 'navigation_repository.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  const NavigationRepositoryImpl(this._navigationService);

  final NavigationService _navigationService;

  @override
  Future<List<NavigationCategoryModel>> getMainNavigation() {
    return _navigationService.getMainNavigation();
  }
}
