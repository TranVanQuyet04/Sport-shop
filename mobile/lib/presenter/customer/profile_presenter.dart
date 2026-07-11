import 'package:flutter/foundation.dart';

import '../../model/customer/profile_model.dart';
import '../../repository/customer/profile_repository.dart';

class ProfilePresenter extends ChangeNotifier {
  ProfilePresenter({required this.profileRepository});

  final ProfileRepository profileRepository;

  ProfileModel? profile;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await profileRepository.getMyProfile();
    } catch (error) {
      profile = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await profileRepository.updateMyProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
