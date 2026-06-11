import '../../model/customer/profile_model.dart';

abstract interface class ProfileRepository {
  Future<ProfileModel> getMyProfile();

  Future<ProfileModel> updateMyProfile({
    required String fullName,
    required String phoneNumber,
  });
}
