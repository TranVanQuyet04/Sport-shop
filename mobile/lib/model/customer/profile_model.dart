import '../../core/auth/role_mapper.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.roleName,
    required this.status,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String roleName;
  final bool status;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return ProfileModel(
      id: (source['id'] ?? '').toString(),
      fullName: (source['fullName'] ?? '').toString(),
      email: (source['email'] ?? '').toString(),
      phoneNumber: (source['phoneNumber'] ?? '').toString(),
      roleName: RoleMapper.normalize((source['roleName'] ?? '').toString()),
      status: source['status'] != false,
    );
  }
}
