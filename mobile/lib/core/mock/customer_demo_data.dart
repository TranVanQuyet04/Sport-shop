import '../../model/customer/address_model.dart';
import '../../model/customer/cart_model.dart';
import '../../model/customer/order_model.dart';
import '../../model/customer/profile_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract final class CustomerDemoData {
  static const products = [
    ProductSummaryModel(
      id: 'nike-air-max-270',
      name: 'Nike Air Max 270',
      category: 'Giày chạy bộ nam',
      price: 3500000,
      brand: 'Nike',
      rating: 4.9,
      isNew: true,
    ),
    ProductSummaryModel(
      id: 'adidas-terrex-wind',
      name: 'Adidas Terrex Wind',
      category: 'Áo khoác thể thao',
      price: 1890000,
      brand: 'Adidas',
      rating: 4.8,
    ),
    ProductSummaryModel(
      id: 'puma-training-tights',
      name: 'Puma Pro Training Tights',
      category: 'Quần tập luyện',
      price: 950000,
      brand: 'Puma',
      rating: 4.7,
    ),
    ProductSummaryModel(
      id: 'dry-fit-performance',
      name: 'Dry-Fit Performance Tee',
      category: 'Áo thể thao',
      price: 450000,
      brand: 'Nike',
      rating: 4.6,
      isNew: true,
    ),
  ];

  static const addresses = [
    AddressModel(
      id: 'demo-address-1',
      recipientName: 'Nguyễn Minh Anh',
      phoneNumber: '0901 234 567',
      city: 'TP. Hồ Chí Minh',
      district: 'Quận 1',
      ward: 'Phường Bến Nghé',
      street: '12 Nguyễn Huệ',
      isDefault: true,
      fullAddress: '12 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    ),
  ];

  static const profile = ProfileModel(
    id: 'demo-customer',
    fullName: 'Nguyễn Minh Anh',
    email: 'customer@sportshop.vn',
    phoneNumber: '0901 234 567',
    roleName: 'CUSTOMER',
    status: true,
  );

  static CartModel get cart {
    return const CartModel(
      id: 'demo-cart',
      totalPrice: 4840000,
      totalItems: 3,
      items: [
        CartItemModel(
          id: 'demo-cart-item-1',
          variantId: '1',
          productName: 'Nike Air Max 270',
          size: '40',
          color: 'Đỏ',
          price: 3500000,
          quantity: 1,
          subTotal: 3500000,
          imageUrl: '',
          maxStock: 8,
        ),
        CartItemModel(
          id: 'demo-cart-item-2',
          variantId: '2',
          productName: 'Dry-Fit Performance Tee',
          size: 'L',
          color: 'Đen',
          price: 450000,
          quantity: 2,
          subTotal: 900000,
          imageUrl: '',
          maxStock: 14,
        ),
        CartItemModel(
          id: 'demo-cart-item-3',
          variantId: '3',
          productName: 'Puma Training Tights',
          size: 'M',
          color: 'Xám',
          price: 440000,
          quantity: 1,
          subTotal: 440000,
          imageUrl: '',
          maxStock: 6,
        ),
      ],
    );
  }

  static List<OrderModel> get orders {
    return [
      OrderModel(
        id: 'SP24061201',
        status: 'SHIPPED',
        totalAmount: 4840000,
        paymentMethod: 'COD',
        recipientName: 'Nguyễn Minh Anh',
        phoneNumber: '0901 234 567',
        shippingAddress:
            '12 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        note: 'Gọi trước khi giao.',
        orderDate: DateTime(2026, 6, 12, 9, 30),
        items: const [
          OrderItemModel(
            id: 'demo-order-item-1',
            variantId: '1',
            productName: 'Nike Air Max 270',
            size: '40',
            color: 'Đỏ',
            price: 3500000,
            quantity: 1,
            subTotal: 3500000,
            variantImage: '',
          ),
          OrderItemModel(
            id: 'demo-order-item-2',
            variantId: '2',
            productName: 'Dry-Fit Performance Tee',
            size: 'L',
            color: 'Đen',
            price: 450000,
            quantity: 2,
            subTotal: 900000,
            variantImage: '',
          ),
        ],
      ),
      OrderModel(
        id: 'SP24061108',
        status: 'COMPLETED',
        totalAmount: 1890000,
        paymentMethod: 'VNPay',
        recipientName: 'Nguyễn Minh Anh',
        phoneNumber: '0901 234 567',
        shippingAddress:
            '12 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        note: '',
        orderDate: DateTime(2026, 6, 11, 18, 15),
        items: const [
          OrderItemModel(
            id: 'demo-order-item-3',
            variantId: '3',
            productName: 'Adidas Terrex Wind',
            size: 'M',
            color: 'Đen',
            price: 1890000,
            quantity: 1,
            subTotal: 1890000,
            variantImage: '',
          ),
        ],
      ),
    ];
  }

  static OrderModel orderById(String id) {
    return orders.firstWhere(
      (order) => order.id == id,
      orElse: () => orders.first,
    );
  }
}
