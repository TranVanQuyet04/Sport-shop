import 'package:flutter/foundation.dart';

import '../../model/customer/profile_model.dart';
import '../../repository/customer/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required this.profileRepository});

  final ProfileRepository profileRepository;

  ProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await profileRepository.getMyProfile();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
