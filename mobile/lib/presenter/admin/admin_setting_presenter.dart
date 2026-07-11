import 'package:flutter/foundation.dart';

import '../../repository/admin/admin_setting_repository.dart';
import '../../model/admin/system_setting_model.dart';

class AdminSettingPresenter extends ChangeNotifier {
  AdminSettingPresenter({required this.adminSettingRepository});

  static const notificationsKey = 'notifications.enabled';
  static const notificationsDescription =
      'Bật hoặc tắt thông báo hệ thống cho quản trị viên.';

  final AdminSettingRepository adminSettingRepository;

  bool notificationsEnabled = true;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<SystemSettingModel> settings = const [];

  Future<void> loadSettings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      settings = await adminSettingRepository.getSettings();
      final matchingSettings = settings.where(
        (setting) => setting.key == notificationsKey,
      );
      final notificationSetting = matchingSettings.isEmpty
          ? null
          : matchingSettings.first;
      if (notificationSetting != null) {
        notificationsEnabled = notificationSetting.boolValue;
      } else {
        await updateNotifications(notificationsEnabled);
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNotifications(bool value) async {
    isSaving = true;
    errorMessage = null;
    notificationsEnabled = value;
    notifyListeners();

    try {
      final setting = await adminSettingRepository.upsertSetting(
        key: notificationsKey,
        value: value.toString(),
        description: notificationsDescription,
      );
      _replaceSetting(setting);
      return true;
    } catch (error) {
      notificationsEnabled = !value;
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveSetting({
    required String key,
    required String value,
    required String description,
  }) async {
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      errorMessage = 'Khóa cài đặt là bắt buộc.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final setting = await adminSettingRepository.upsertSetting(
        key: normalizedKey,
        value: value.trim(),
        description: description.trim(),
      );
      _replaceSetting(setting);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSetting(String key) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await adminSettingRepository.deleteSetting(key);
      settings = settings.where((setting) => setting.key != key).toList();
      if (key == notificationsKey) {
        notificationsEnabled = true;
      }
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void _replaceSetting(SystemSettingModel setting) {
    final nextSettings = [...settings];
    final index = nextSettings.indexWhere((item) => item.key == setting.key);
    if (index == -1) {
      nextSettings.add(setting);
    } else {
      nextSettings[index] = setting;
    }
    nextSettings.sort((a, b) => a.key.compareTo(b.key));
    settings = nextSettings;
  }
}
