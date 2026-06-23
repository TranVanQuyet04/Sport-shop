# 05. Batch Delivery Staff / Shipper Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: tạo workflow riêng cho DELIVERY_STAFF cập nhật trạng thái giao hàng.

Lưu ý nghiệp vụ:
- Delivery Staff không confirm/pack/handover đơn.
- Delivery Staff chỉ cập nhật deliveryStatus sau khi đơn đã SHIPPED.
- Delivery status flow: WAITING_PICKUP -> PICKED_UP -> IN_TRANSIT -> OUT_FOR_DELIVERY -> DELIVERED.
- Nếu giao thất bại: OUT_FOR_DELIVERY -> FAILED.
- Nếu hoàn trả: FAILED -> RETURNED.

## Screens Cần Tạo Mới

### Delivery dashboard
- Trạng thái: Cần tạo mới
- Cần Stitch: dashboard riêng cho DELIVERY_STAFF, hiển thị tổng đơn cần giao, đang giao, giao thất bại.

### Assigned delivery orders list
- Trạng thái: Cần tạo mới
- Cần Stitch: danh sách đơn đã bàn giao cho shipper, filter theo deliveryStatus.

### Delivery order detail page
- Trạng thái: Cần tạo mới
- Cần Stitch: chi tiết địa chỉ, sản phẩm, khách hàng, payment method, delivery status.

### Delivery status update screen
- Trạng thái: Cần tạo mới
- Cần Stitch: update WAITING_PICKUP -> PICKED_UP -> IN_TRANSIT -> OUT_FOR_DELIVERY -> DELIVERED.

### Delivery timeline screen
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline cho deliveryStatus.

### Failed delivery form
- Trạng thái: Cần tạo mới
- Cần Stitch: form lý do giao thất bại, ghi chú, ảnh nếu cần.

### Returned order form
- Trạng thái: Cần tạo mới
- Cần Stitch: form lý do hoàn trả, ghi chú.

### Delivery staff profile/account menu
- Trạng thái: Cần bổ sung
- Cần Stitch: UI account menu riêng cho delivery staff.
