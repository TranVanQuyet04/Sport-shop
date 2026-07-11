# Admin Mobile Button Inventory

- Generated: 2026-07-06T19:50:59
- Total interactive controls: 80
- Review notes: 1

## mobile/lib/view/admin/admin_add_product_page.dart

- line 175: `IconButton` - Thêm sản phẩm mới
- line 182: `IconButton` - Đóng

## mobile/lib/view/admin/admin_brand_management_page.dart

- line 130: `FloatingActionButton` - Thêm thương hiệu
- line 147: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_category_management_page.dart

- line 132: `FloatingActionButton` - Thêm danh mục
- line 149: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_chat_detail_page.dart

- line 90: `IconButton` - Room #${widget.chatId}\nSupport chat
- line 176: `IconButton` - Gửi tin nhắn

## mobile/lib/view/admin/admin_chat_rooms_page.dart

- line 130: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_collections_page.dart

- line 104: `IconButton` - Làm mới bộ sưu tập
- line 115: `FloatingActionButton` - Thêm bộ sưu tập
- line 124: `AdminBottomNav` - (icon/custom)
- line 189: `AdminEntityMenu` - (icon/custom)
- line 364: `SwitchListTile` - Đang hoạt động
- line 374: `TextButton` - Hủy
- line 378: `ElevatedButton` - Lưu

## mobile/lib/view/admin/admin_dashboard_page.dart

- line 84: `AdminBottomNav` - Chọn khoảng ngày
- line 113: `IconButton` - Chọn khoảng ngày

## mobile/lib/view/admin/admin_delivery_monitoring_page.dart

- line 130: `FloatingActionButton` - Làm mới danh sách giao hàng
- line 147: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_inventory_variants_page.dart

- line 83: `TextButton` - Hủy
- line 87: `FilledButton` - Xóa
- line 142: `IconButton` - Làm mới kho hàng
- line 155: `FloatingActionButton` - Thêm biến thể
- line 170: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_orders_page.dart

- line 128: `AdminBottomNav` - (icon/custom)
- line 231: `IconButton` - Làm mới

## mobile/lib/view/admin/admin_products_page.dart

- line 194: `AdminBottomNav` - (icon/custom)
- line 227: `GestureDetector` - (icon/custom)
- line 265: `GestureDetector` - (icon/custom)
- line 497: `IconButton` - (icon/custom)
- line 637: `TextButton` - Hủy
- line 641: `ElevatedButton` - Lưu
- line 699: `TextButton` - Hủy
- line 703: `ElevatedButton` - Lưu
- line 742: `TextButton` - Hủy
- line 746: `ElevatedButton` - Xóa
- line 1042: `OutlinedButton` - Hủy
- line 1046: `FilledButton` - Xóa
- line 1069: `ElevatedButton` - THÊM MÔN THỂ THAO MỚI +
- line 1162: `IconButton` - Chỉnh sửa
- line 1171: `IconButton` - Xóa

## mobile/lib/view/admin/admin_profile_page.dart

- line 53: `IconButton` - Hồ sơ quản trị
- line 60: `IconButton` - Làm mới
- line 154: `TextButton` - Hủy
- line 158: `FilledButton` - Lưu thay đổi

## mobile/lib/view/admin/admin_revenue_page.dart

- line 80: `AdminBottomNav` - (icon/custom)
- line 112: `IconButton` - Chọn khoảng ngày
- line 407: `GestureDetector` - (icon/custom)
- line 468: `GestureDetector` - (icon/custom)

## mobile/lib/view/admin/admin_revenue_report_page.dart

- line 77: `AdminBottomNav` - (icon/custom)
- line 106: `IconButton` - Chọn khoảng ngày
- line 535: `GestureDetector` - (icon/custom)
- line 688: `GestureDetector` - (icon/custom)
- line 749: `GestureDetector` - (icon/custom)

## mobile/lib/view/admin/admin_sports_page.dart

- line 107: `IconButton` - Làm mới
- line 124: `AdminBottomNav` - (icon/custom)

## mobile/lib/view/admin/admin_staff_detail_page.dart

- line 93: `IconButton` - Chi tiết nhân sự
- line 101: `IconButton` - Làm mới chi tiết nhân sự

## mobile/lib/view/admin/admin_staff_page.dart

- line 164: `FloatingActionButton` - Thêm nhân viên
- line 173: `AdminBottomNav` - (icon/custom)
- line 238: `IconButton` - Làm mới

## mobile/lib/view/admin/admin_system_settings_page.dart

- line 45: `_SettingTile` - (icon/custom) route=AppRoutes.adminProfile
- line 51: `_SettingTile` - (icon/custom) route=AppRoutes.adminChangePassword
- line 64: `_SettingTile` - (icon/custom) route=AppRoutes.adminCategories
- line 70: `_SettingTile` - (icon/custom) route=AppRoutes.adminBrands
- line 76: `_SettingTile` - (icon/custom) route='${AppRoutes.adminProducts}?tab=sport'
- line 82: `_SettingTile` - (icon/custom) route=AppRoutes.adminCollections
- line 88: `_SettingTile` - (icon/custom) route=AppRoutes.adminChatRooms
- line 101: `_SettingTile` - (icon/custom) route=AppRoutes.login
- line 126: `AdminBottomNav` - Cấu hình thông tin cửa hàng đang được hoàn thiện.
- line 197: `_SettingTile` - (icon/custom)
- line 213: `InkWell` - (icon/custom)
- line 300: `Switch.adaptive` - (icon/custom)
- line 322: `InkWell` - Đăng xuất

## mobile/lib/view/admin/admin_user_management_page.dart

- line 100: `TextButton` - Hủy
- line 104: `FilledButton` - Xóa
- line 139: `IconButton` - Làm mới người dùng
- line 147: `FloatingActionButton` - Thêm người dùng
- line 162: `AdminBottomNav` - (icon/custom)

## Review Notes

- [ICON_BUTTON_TOOLTIP_REVIEW] `mobile/lib/view/admin/admin_products_page.dart:497`: IconButton has no tooltip in the scanned block. Add a concise tooltip so Admin users understand the action.
