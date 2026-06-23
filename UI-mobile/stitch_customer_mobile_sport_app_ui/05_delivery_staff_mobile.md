# 05. Batch Delivery Staff Mobile

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: thiết kế mobile workflow cho DELIVERY_STAFF/Shipper cập nhật trạng thái giao hàng.

## Business Rule

- Delivery Staff không confirm/pack/handover đơn.
- Delivery Staff chỉ cập nhật deliveryStatus sau khi đơn đã SHIPPED.
- Flow chính: WAITING_PICKUP -> PICKED_UP -> IN_TRANSIT -> OUT_FOR_DELIVERY -> DELIVERED.
- Nếu giao thất bại: OUT_FOR_DELIVERY -> FAILED.
- Nếu hoàn trả: FAILED -> RETURNED.

## Screens

### Delivery home
- Trạng thái: Cần tạo mới
- Cần Stitch: tổng đơn cần nhận, đang giao, giao thất bại, hoàn trả.

### Assigned deliveries screen
- Trạng thái: Cần tạo mới
- Cần Stitch: danh sách đơn được giao, filter theo deliveryStatus.

### Delivery order detail screen
- Trạng thái: Cần tạo mới
- Cần Stitch: địa chỉ, khách hàng, items, payment method, deliveryStatus.

### Delivery status update screen
- Trạng thái: Cần tạo mới
- Cần Stitch: update từng bước deliveryStatus bằng stepper/actions.

### Delivery timeline screen
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline deliveryStatus.

### Failed delivery form
- Trạng thái: Cần tạo mới
- Cần Stitch: lý do giao thất bại, ghi chú, ảnh nếu cần.

### Returned order form
- Trạng thái: Cần tạo mới
- Cần Stitch: lý do hoàn trả, ghi chú.

### Delivery profile/account screen
- Trạng thái: Cần bổ sung
- Cần Stitch: thông tin tài khoản, ca làm việc, logout.

