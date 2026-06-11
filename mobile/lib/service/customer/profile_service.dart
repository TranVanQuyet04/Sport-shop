import '../../core/network/api_client.dart';
import '../../model/customer/profile_model.dart';

abstract interface class ProfileService {
  Future<ProfileModel> getMyProfile();

  Future<ProfileModel> updateMyProfile({
    required String fullName,
    required String phoneNumber,
  });
}

class ProfileApiService implements ProfileService {
  const ProfileApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getMyProfile() async {
    final json = await _apiClient.getJson('/user/profile/me');
    return ProfileModel.fromJson(json);
  }

  @override
  Future<ProfileModel> updateMyProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final json = await _apiClient.putJson(
      '/user/profile/me',
      data: {'fullName': fullName, 'phoneNumber': phoneNumber},
    );
    return ProfileModel.fromJson(json);
  }
}
