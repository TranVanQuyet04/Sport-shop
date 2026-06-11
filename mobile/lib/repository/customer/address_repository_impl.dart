import '../../model/customer/address_model.dart';
import '../../service/customer/address_service.dart';
import 'address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._addressService);

  final AddressService _addressService;

  @override
  Future<List<AddressModel>> getAddresses() {
    return _addressService.getAddresses();
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
  }) {
    return _addressService.createAddress(
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      city: city,
      district: district,
      ward: ward,
      street: street,
      isDefault: isDefault,
    );
  }

  @override
  Future<void> deleteAddress(String id) {
    return _addressService.deleteAddress(id);
  }

  @override
  Future<void> setDefault(String id) {
    return _addressService.setDefault(id);
  }
}
