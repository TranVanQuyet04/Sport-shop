class AddressModel {
  const AddressModel({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.city,
    required this.district,
    required this.ward,
    required this.street,
    required this.isDefault,
    required this.fullAddress,
  });

  final String id;
  final String recipientName;
  final String phoneNumber;
  final String city;
  final String district;
  final String ward;
  final String street;
  final bool isDefault;
  final String fullAddress;

  String get displayName => '$recipientName • $phoneNumber';

  String get displayAddress {
    if (fullAddress.isNotEmpty) {
      return fullAddress;
    }
    return [
      street,
      ward,
      district,
      city,
    ].where((value) => value.isNotEmpty).join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? '').toString(),
      recipientName: (json['recipientName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      ward: (json['ward'] ?? '').toString(),
      street: (json['street'] ?? '').toString(),
      isDefault: json['isDefault'] == true,
      fullAddress: (json['fullAddress'] ?? '').toString(),
    );
  }
}
