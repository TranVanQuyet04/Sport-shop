abstract final class RoleMapper {
  static String normalize(String? role) {
    final value = (role ?? '')
        .trim()
        .toUpperCase()
        .replaceFirst('ROLE_', '')
        .replaceAll(RegExp(r'\s+'), ' ');

    return switch (value) {
      'ADMIN' || 'QUAN TRI VIEN' || 'QU\u1ea2N TR\u1eca VI\u00caN' => 'ADMIN',
      'SHIPPER' ||
      'NGUOI GIAO HANG' ||
      'NG\u01af\u1edcI GIAO H\u00c0NG' => 'SHIPPER',
      'MEMBER' ||
      'CUSTOMER' ||
      'THANH VIEN' ||
      'TH\u00c0NH VI\u00caN' => 'MEMBER',
      'STAFF' || 'SHOP_STAFF' => 'ADMIN',
      'DELIVERY_STAFF' => 'SHIPPER',
      _ => value,
    };
  }

  static String backendRoleName(String role) {
    return switch (normalize(role)) {
      'ADMIN' => 'ADMIN',
      'SHIPPER' => 'SHIPPER',
      'MEMBER' => 'MEMBER',
      _ => role,
    };
  }
}
