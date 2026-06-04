# 03. Role Flows

## Guest Flow

### Guest xem sản phẩm

1. Vào trang chủ.
2. Xem hero, brand nổi bật, sản phẩm gợi ý.
3. Vào collections.
4. Tìm kiếm/lọc sản phẩm.
5. Click xem chi tiết sản phẩm.

Kết quả mong muốn:
- Guest hiểu shop bán gì.
- Guest tìm được sản phẩm trước khi đăng nhập.

### Guest đăng ký/đăng nhập

1. Click icon tài khoản.
2. Chọn đăng nhập hoặc đăng ký.
3. Nhập thông tin.
4. Hệ thống validate và xử lý.
5. Sau login, header hiển thị menu tài khoản.

Kết quả mong muốn:
- Guest chuyển thành Customer.

## Customer Flow

### Customer mua hàng

1. Đăng nhập.
2. Xem/lọc sản phẩm.
3. Mở chi tiết sản phẩm.
4. Chọn variant: size, color, quantity.
5. Add to cart.
6. Mở cart sheet.
7. Kiểm tra item và tổng tiền.
8. Checkout.
9. Chọn địa chỉ.
10. Chọn payment method.
11. Tạo order.

Kết quả mong muốn:
- Order được tạo từ cart.
- Cart được clear sau khi order thành công.

### Customer theo dõi đơn hàng

1. Vào menu tài khoản.
2. Chọn Theo dõi đơn hàng.
3. Xem danh sách order.
4. Xem timeline trạng thái.
5. Mở chi tiết order.
6. Khi trạng thái là DELIVERED, customer xác nhận đã nhận hàng.
7. Order chuyển sang COMPLETED.

Timeline:
- PENDING: Chờ xác nhận.
- PAID: Đã thanh toán.
- SHIPPING: Đang giao.
- DELIVERED: Đã giao.
- COMPLETED: Hoàn tất.
- CANCELLED: Đã hủy.

Kết quả mong muốn:
- Customer biết đơn đang ở bước nào.
- Customer tự xác nhận hoàn tất đơn.

### Customer quản lý tài khoản

1. Vào Hồ sơ cá nhân.
2. Cập nhật tên.
3. Thêm/sửa/xóa địa chỉ.
4. Đặt địa chỉ mặc định.

Kết quả mong muốn:
- Checkout dùng được địa chỉ đã lưu.

### Customer chat support

1. Mở chat bubble.
2. Gửi câu hỏi.
3. Admin trả lời trong dashboard.
4. Customer nhận phản hồi.

Kết quả mong muốn:
- Có kênh hỗ trợ trực tiếp.

## Admin Flow

### Admin quản lý catalog

1. Đăng nhập admin.
2. Vào dashboard.
3. Tạo brand/category/sport/color/size.
4. Kiểm tra dữ liệu xuất hiện trong form product và filter storefront.

Kết quả mong muốn:
- Dữ liệu nền đầy đủ để tạo product.

### Admin quản lý product

1. Vào Product Manager.
2. Tạo product.
3. Thêm images.
4. Thêm variants.
5. Lưu product.
6. Kiểm tra product hiển thị ngoài storefront.

Kết quả mong muốn:
- Product có thể bán được.

### Admin quản lý order

1. Vào Order Manager.
2. Xem danh sách order.
3. Mở order detail.
4. Kiểm tra thông tin khách, địa chỉ, items.
5. Cập nhật status theo flow.

Kết quả mong muốn:
- Customer order tracking cập nhật theo status admin đổi.

### Admin chat support

1. Vào tab Chat.
2. Xem room list.
3. Chọn customer.
4. Trả lời tin nhắn.

Kết quả mong muốn:
- Customer nhận phản hồi.

## Shipper Flow

### Shipper xử lý giao hàng

1. Đăng nhập shipper.
2. Hệ thống chỉ cho vào module order.
3. Xem danh sách đơn SHIPPING.
4. Mở chi tiết đơn.
5. Giao hàng.
6. Cập nhật DELIVERED nếu giao thành công.
7. Cập nhật CANCELLED nếu giao thất bại.

Kết quả mong muốn:
- Order status được cập nhật đúng.
- Customer thấy trạng thái mới ở trang theo dõi đơn hàng.
