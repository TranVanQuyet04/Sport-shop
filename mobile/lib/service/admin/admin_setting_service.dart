import '../../core/network/api_client.dart';
import '../../model/admin/system_setting_model.dart';

abstract interface class AdminSettingService {
  Future<List<SystemSettingModel>> getSettings();

  Future<SystemSettingModel> upsertSetting({
    required String key,
    required String value,
    required String description,
  });

  Future<void> deleteSetting(String key);
}

class AdminSettingApiService implements AdminSettingService {
  const AdminSettingApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SystemSettingModel>> getSettings() async {
    final json = await _apiClient.getJson('/admin/settings');
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map(
          (item) =>
              SystemSettingModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<SystemSettingModel> upsertSetting({
    required String key,
    required String value,
    required String description,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/settings/$key',
      data: {'value': value, 'description': description},
    );
    return SystemSettingModel.fromJson(json);
  }

  @override
  Future<void> deleteSetting(String key) async {
    await _apiClient.deleteJson('/admin/settings/$key');
  }
}
