part of '../admin_catalog_service.dart';

mixin _AdminUserCatalogApi on _AdminCatalogApiBase {
  Future<List<AdminUserModel>> getUsers() async {
    final json = await _apiClient.getJson('/admin/users');
    return _parseList(
      json,
    ).map((item) => AdminUserModel.fromJson(item)).toList();
  }

  Future<List<AdminRoleModel>> getRoles() async {
    final json = await _apiClient.getJson('/admin/roles');
    return _parseList(
      json,
    ).map((item) => AdminRoleModel.fromJson(item)).toList();
  }

  Future<AdminUserModel> getUserDetail(String id) async {
    final json = await _apiClient.getJson('/admin/users/$id');
    return AdminUserModel.fromJson(_parseObject(json));
  }

  Future<AdminUserModel> createUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String roleName,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/users',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'roleName': RoleMapper.backendRoleName(roleName),
      },
    );
    return AdminUserModel.fromJson(_parseObject(json));
  }

  Future<AdminUserModel> updateUser({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String roleName,
    required bool status,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/users/$id',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'roleName': RoleMapper.backendRoleName(roleName),
        'status': status,
      },
    );
    return AdminUserModel.fromJson(_parseObject(json));
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.deleteJson('/admin/users/$id');
  }
}
