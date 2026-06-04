# 01. Project Overview

## Topic

Sport Shop System là hệ thống thương mại điện tử chuyên bán sản phẩm thể thao như quần áo, giày, phụ kiện, đồ tập gym, đồ chạy bộ và sản phẩm theo môn thể thao hoặc thương hiệu.

Hệ thống gồm ba khu vực chính:

- Customer Storefront: giao diện mua hàng cho khách.
- Admin Dashboard: giao diện quản trị sản phẩm, đơn hàng, người dùng, báo cáo và chat.
- Shipper Workspace: khu vực xử lý đơn giao hàng.

## Mục tiêu

- Số hóa quy trình bán đồ thể thao online.
- Giúp khách hàng tìm sản phẩm nhanh theo brand, category, sport, màu, giá.
- Giúp admin quản lý hàng hóa, tồn kho, đơn hàng và khách hàng.
- Giúp shipper theo dõi và cập nhật trạng thái giao hàng.
- Cho phép khách theo dõi trạng thái đơn hàng của mình.
- Hỗ trợ chăm sóc khách hàng qua chat.

## Role chính

### Guest

Người chưa đăng nhập.

Có thể:
- Xem trang chủ.
- Xem danh sách sản phẩm.
- Tìm kiếm và lọc sản phẩm.
- Xem chi tiết sản phẩm.
- Đăng ký.
- Đăng nhập.

Không thể:
- Checkout.
- Xem đơn hàng.
- Quản lý hồ sơ.

### Customer

Người mua hàng đã đăng nhập.

Có thể:
- Quản lý hồ sơ cá nhân.
- Quản lý địa chỉ giao hàng.
- Thêm sản phẩm vào giỏ.
- Checkout.
- Chọn COD hoặc online payment.
- Xem lịch sử đơn hàng.
- Theo dõi trạng thái đơn hàng.
- Xác nhận đã nhận hàng.
- Chat với shop.

### Admin

Người quản trị hệ thống.

Có thể:
- Quản lý product.
- Quản lý product variant.
- Quản lý brand, category, sport, size, color.
- Quản lý order.
- Quản lý user.
- Xem dashboard report.
- Chat với customer.

### Shipper

Người giao hàng.

Có thể:
- Xem đơn được giao hoặc đơn đang ở trạng thái cần giao.
- Xem thông tin khách, địa chỉ, sản phẩm, tổng tiền.
- Cập nhật trạng thái giao hàng.
- Xác nhận giao thành công hoặc thất bại.

## Entity chính

- User
- Role
- UserAddress
- Product
- ProductImage
- ProductVariant
- Brand
- Category
- Sport
- Color
- Size
- Cart
- CartItem
- Order
- OrderItem
- Payment
- ChatRoom
- ChatMessage

## Trạng thái đơn hàng đề xuất

- PENDING: Đơn mới tạo, chờ xác nhận hoặc chờ thanh toán.
- PAID: Đã thanh toán online.
- SHIPPING: Đang giao hàng.
- DELIVERED: Shipper đã giao thành công.
- COMPLETED: Customer xác nhận đã nhận hàng.
- CANCELLED: Đơn đã hủy hoặc giao thất bại.
