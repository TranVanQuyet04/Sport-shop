import '../../core/auth/role_mapper.dart';
import '../../core/utils/image_url_utils.dart';

class AdminRoleModel {
  const AdminRoleModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  final String id;
  final String code;
  final String name;
  final String description;

  factory AdminRoleModel.fromJson(Map<String, dynamic> json) {
    final code = (json['roleCode'] ?? json['code'] ?? '').toString();
    return AdminRoleModel(
      id: (json['roleId'] ?? json['id'] ?? '').toString(),
      code: RoleMapper.normalize(code),
      name: (json['roleName'] ?? json['name'] ?? code).toString(),
      description: (json['roleDescription'] ?? json['description'] ?? '')
          .toString(),
    );
  }
}

class AdminCategoryModel {
  const AdminCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.parentId,
  });

  final String id;
  final String name;
  final String description;
  final String parentId;

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['categoryName'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      parentId: (json['parentId'] ?? '').toString(),
    );
  }
}

class AdminBrandModel {
  const AdminBrandModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final String logo;
  final bool isActive;

  factory AdminBrandModel.fromJson(Map<String, dynamic> json) {
    return AdminBrandModel(
      id: (json['id'] ?? '').toString(),
      name: (json['brandName'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logo: ImageUrlUtils.sanitize(json['logo']),
      isActive: json['isActive'] != false,
    );
  }
}

class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    required this.roleName,
  });

  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final bool status;
  final String roleName;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      status: json['status'] != false,
      roleName: RoleMapper.normalize((json['roleName'] ?? '').toString()),
    );
  }
}
