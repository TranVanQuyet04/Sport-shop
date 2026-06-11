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
      name: (json['categoryName'] ?? json['name'] ?? 'Danh mục').toString(),
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
      name: (json['brandName'] ?? json['name'] ?? 'Thương hiệu').toString(),
      description: (json['description'] ?? '').toString(),
      logo: (json['logo'] ?? '').toString(),
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
      fullName: (json['fullName'] ?? 'Người dùng').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      status: json['status'] != false,
      roleName: (json['roleName'] ?? '').toString(),
    );
  }
}
