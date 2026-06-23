# 04. Batch Shop Staff Mobile

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: thiết kế mobile workflow cho SHOP_STAFF xử lý đơn trước khi giao.

## Business Rule

- Shop Staff không cập nhật deliveryStatus.
- Shop Staff chỉ xử lý orderStatus trước khi giao.
- Luồng chính: PENDING -> CONFIRMED -> PACKING -> SHIPPED.

## Screens

### Shop staff home
- Trạng thái: Cần tạo mới
- Cần Stitch: tổng số đơn cần xác nhận, đang đóng gói, đã bàn giao.

### Orders to confirm screen
- Nền hiện có: `OrderManager`
- Trạng thái: Cần bổ sung
- Cần Stitch: danh sách đơn PENDING dạng card list, filter/search.

### Order detail screen
- Trạng thái: Đã có một phần
- Cần Stitch: customer, shipping info, items, payment, orderStatus.

### Confirm order action screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action PENDING -> CONFIRMED, confirmation bottom sheet.

### Packing order screen
- Trạng thái: Cần bổ sung
- Cần Stitch: checklist đóng gói, action CONFIRMED -> PACKING.

### Handover to delivery screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action PACKING -> SHIPPED, chọn/ghi nhận delivery staff nếu cần.

### Shop order status timeline
- Trạng thái: Cần bổ sung
- Cần Stitch: timeline riêng cho orderStatus.

### Customer/shipping info screen
- Trạng thái: Đã có một phần
- Cần Stitch: panel mobile thông tin khách và địa chỉ giao hàng.

### Order items screen
- Trạng thái: Đã có một phần
- Cần Stitch: danh sách item, quantity, price snapshot.

