import '../../model/admin/dashboard_report_model.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract final class AdminDemoData {
  static const dashboardReport = DashboardReportModel(
    totalRevenue: 128450000,
    totalOrders: 64,
    newUsers: 18,
    pendingOrders: 12,
  );

  static const products = [
    ProductSummaryModel(
      id: 'nike-air-max-270',
      name: 'Nike Air Max 270',
      category: 'Giày chạy bộ',
      price: 3500000,
      brand: 'Nike',
      rating: 4.9,
      isNew: true,
    ),
    ProductSummaryModel(
      id: 'adidas-terrex-wind',
      name: 'Adidas Terrex Wind',
      category: 'Áo khoác',
      price: 1890000,
      brand: 'Adidas',
      rating: 4.8,
    ),
    ProductSummaryModel(
      id: 'puma-training-tights',
      name: 'Puma Training Tights',
      category: 'Quần tập',
      price: 950000,
      brand: 'Puma',
      rating: 4.7,
    ),
  ];

  static const users = [
    AdminUserModel(
      id: 'staff-shop-01',
      email: 'shop.staff@sportshop.vn',
      fullName: 'Trần An Phát',
      phoneNumber: '0902 111 222',
      status: true,
      roleName: 'SHOP_STAFF',
    ),
    AdminUserModel(
      id: 'staff-delivery-01',
      email: 'shipper@sportshop.vn',
      fullName: 'Lê Minh Khang',
      phoneNumber: '0903 333 444',
      status: true,
      roleName: 'DELIVERY_STAFF',
    ),
    AdminUserModel(
      id: 'staff-shop-02',
      email: 'packing@sportshop.vn',
      fullName: 'Phạm Ngọc Linh',
      phoneNumber: '0904 555 666',
      status: false,
      roleName: 'SHOP_STAFF',
    ),
  ];

  static const categories = [
    AdminCategoryModel(
      id: 'cat-shoes',
      name: 'Giày thể thao',
      description: 'Giày chạy bộ, training và lifestyle.',
      parentId: '',
    ),
    AdminCategoryModel(
      id: 'cat-apparel',
      name: 'Quần áo thể thao',
      description: 'Áo, quần, áo khoác và đồ tập.',
      parentId: '',
    ),
    AdminCategoryModel(
      id: 'cat-accessories',
      name: 'Phụ kiện',
      description: 'Túi, tất, bình nước và phụ kiện tập luyện.',
      parentId: '',
    ),
  ];

  static const brands = [
    AdminBrandModel(
      id: 'brand-nike',
      name: 'Nike',
      description: 'Performance sportswear brand.',
      logo: '',
      isActive: true,
    ),
    AdminBrandModel(
      id: 'brand-adidas',
      name: 'Adidas',
      description: 'Training and running products.',
      logo: '',
      isActive: true,
    ),
    AdminBrandModel(
      id: 'brand-puma',
      name: 'Puma',
      description: 'Sport lifestyle and training.',
      logo: '',
      isActive: true,
    ),
  ];
}
