import '../../model/customer/profile_model.dart';
import '../../service/customer/profile_service.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._profileService);

  final ProfileService _profileService;

  @override
  Future<ProfileModel> getMyProfile() {
    return _profileService.getMyProfile();
  }

  @override
  Future<ProfileModel> updateMyProfile({
    required String fullName,
    required String phoneNumber,
  }) {
    return _profileService.updateMyProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}
