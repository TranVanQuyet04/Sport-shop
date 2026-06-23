import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/customer/address_model.dart';

abstract interface class AddressService {
  Future<List<AddressModel>> getAddresses();

  Future<AddressModel> createAddress({
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  });

  Future<AddressModel> updateAddress({
    required String id,
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  });

  Future<void> deleteAddress(String id);

  Future<void> setDefault(String id);
}

class AddressApiService implements AddressService {
  const AddressApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<AddressModel>> getAddresses() async {
    final json = await _apiClient.getJson(ApiEndpoints.addresses);
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<AddressModel> createAddress({
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  }) async {
    final json = await _apiClient.postJson(
      ApiEndpoints.addresses,
      data: {
        'recipientName': recipientName,
        'phoneNumber': phoneNumber,
        'city': city,
        'district': district,
        'ward': ward,
        'street': street,
        'isDefault': isDefault,
      },
    );
    return AddressModel.fromJson(json);
  }

  @override
  Future<AddressModel> updateAddress({
    required String id,
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  }) async {
    final json = await _apiClient.putJson(
      '${ApiEndpoints.addresses}/$id',
      data: {
        'recipientName': recipientName,
        'phoneNumber': phoneNumber,
        'city': city,
        'district': district,
        'ward': ward,
        'street': street,
        'isDefault': isDefault,
      },
    );
    return AddressModel.fromJson(json);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _apiClient.deleteJson('${ApiEndpoints.addresses}/$id');
  }

  @override
  Future<void> setDefault(String id) async {
    await _apiClient.patchJson('${ApiEndpoints.addresses}/$id/default');
  }
}
