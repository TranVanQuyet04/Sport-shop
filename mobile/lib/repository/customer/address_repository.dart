import '../../model/customer/address_model.dart';

abstract interface class AddressRepository {
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

  Future<void> deleteAddress(String id);

  Future<void> setDefault(String id);
}
