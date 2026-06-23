# 04. Batch Shop Staff Workflow Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: tạo workflow riêng cho SHOP_STAFF xử lý đơn trước khi giao.

Lưu ý nghiệp vụ:
- Shop Staff không cập nhật deliveryStatus.
- Shop Staff chỉ xử lý orderStatus trước khi giao.
- Luồng chính: PENDING -> CONFIRMED -> PACKING -> SHIPPED.

## Screens Cần Tạo Hoặc Bổ Sung

### Shop staff dashboard / Order workspace
- Trạng thái: Cần tạo mới hoặc tách từ admin
- Cần Stitch: workspace cho SHOP_STAFF, chỉ tập trung xử lý đơn trước khi giao.

### Orders to confirm list
- Trạng thái: Cần bổ sung
- Nền hiện có: `OrderManager`
- Cần Stitch: danh sách đơn PENDING, filter theo trạng thái, search order/customer.

### Order detail page
- Trạng thái: Đã có một phần trong admin
- Cần Stitch: UI chi tiết đơn cho staff gồm customer, địa chỉ, items, payment, orderStatus.

### Confirm order screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action PENDING -> CONFIRMED, confirmation modal.

### Packing order screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action CONFIRMED -> PACKING, checklist đóng gói nếu phù hợp.

### Handover to delivery screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action PACKING -> SHIPPED, chọn/ghi nhận delivery staff nếu cần.

### Shop order status timeline
- Trạng thái: Cần bổ sung
- Cần Stitch: timeline riêng cho orderStatus.

### Customer/shipping info panel
- Trạng thái: Đã có một phần
- Cần Stitch: polish panel thông tin khách và địa chỉ giao hàng.

### Order items panel
- Trạng thái: Đã có một phần
- Cần Stitch: polish danh sách sản phẩm trong đơn, quantity, price snapshot.
