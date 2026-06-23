import 'package:flutter/foundation.dart';

import '../../model/customer/address_model.dart';
import '../../repository/customer/address_repository.dart';

class AddressController extends ChangeNotifier {
  AddressController({required this.addressRepository});

  final AddressRepository addressRepository;

  List<AddressModel> addresses = const [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadAddresses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      addresses = await addressRepository.getAddresses();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAddress({
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await addressRepository.createAddress(
        recipientName: recipientName,
        phoneNumber: phoneNumber,
        city: city,
        district: district,
        ward: ward,
        street: street,
        isDefault: isDefault,
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

  Future<bool> updateAddress({
    required String id,
    required String recipientName,
    required String phoneNumber,
    required String city,
    required String district,
    required String ward,
    required String street,
    required bool isDefault,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await addressRepository.updateAddress(
        id: id,
        recipientName: recipientName,
        phoneNumber: phoneNumber,
        city: city,
        district: district,
        ward: ward,
        street: street,
        isDefault: isDefault,
      );
      addresses = await addressRepository.getAddresses();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    await _mutate(() => addressRepository.deleteAddress(id));
  }

  Future<void> setDefault(String id) async {
    await _mutate(() => addressRepository.setDefault(id));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      addresses = await addressRepository.getAddresses();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
