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

  String get displayName => '$recipientName - $phoneNumber';

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
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return AddressModel(
      id: (source['id'] ?? '').toString(),
      recipientName: (source['recipientName'] ?? '').toString(),
      phoneNumber: (source['phoneNumber'] ?? '').toString(),
      city: (source['city'] ?? '').toString(),
      district: (source['district'] ?? '').toString(),
      ward: (source['ward'] ?? '').toString(),
      street: (source['street'] ?? '').toString(),
      isDefault: source['isDefault'] == true,
      fullAddress: (source['fullAddress'] ?? '').toString(),
    );
  }
}
