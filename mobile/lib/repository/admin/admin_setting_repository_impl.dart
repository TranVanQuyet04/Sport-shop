import '../../model/admin/system_setting_model.dart';
import '../../service/admin/admin_setting_service.dart';
import 'admin_setting_repository.dart';

class AdminSettingRepositoryImpl implements AdminSettingRepository {
  const AdminSettingRepositoryImpl(this._service);

  final AdminSettingService _service;

  @override
  Future<List<SystemSettingModel>> getSettings() {
    return _service.getSettings();
  }

  @override
  Future<SystemSettingModel> upsertSetting({
    required String key,
    required String value,
    required String description,
  }) {
    return _service.upsertSetting(
      key: key,
      value: value,
      description: description,
    );
  }

  @override
  Future<void> deleteSetting(String key) {
    return _service.deleteSetting(key);
  }
}
