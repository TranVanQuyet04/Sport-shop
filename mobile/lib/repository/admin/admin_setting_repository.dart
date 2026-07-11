import '../../model/admin/system_setting_model.dart';

abstract interface class AdminSettingRepository {
  Future<List<SystemSettingModel>> getSettings();

  Future<SystemSettingModel> upsertSetting({
    required String key,
    required String value,
    required String description,
  });

  Future<void> deleteSetting(String key);
}
