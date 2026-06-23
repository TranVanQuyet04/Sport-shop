# 00. Prompt Tổng Cho Stitch

Tôi đang làm frontend cho dự án Sportswear E-Commerce Website.

Hãy thiết kế UI dạng web app responsive, không phải mobile app. Ưu tiên desktop trước, sau đó responsive cho tablet/mobile.

Phong cách thiết kế:
- Sport e-commerce hiện đại, mạnh mẽ, rõ ràng, chuyên nghiệp.
- Customer UI dễ mua hàng, trực quan, có nhiều hình ảnh sản phẩm.
- Admin/Staff/Delivery UI là dashboard/workspace thực dụng, dễ scan dữ liệu, có bảng, filter, badge, timeline.
- Màu chủ đạo: trắng, đen, xám, đỏ accent.
- Text UI dùng tiếng Việt có dấu.
- Không để text tràn, không để UI overlap trên mobile.

Trạng thái cần có:
- Loading
- Empty
- Error
- Success
- Disabled

Component nên dùng nhất quán:
- Button
- Input
- Select
- Checkbox
- Table
- Modal
- Badge
- Tabs
- Sidebar
- Timeline
- Product card

Business roles:
- Guest: xem sản phẩm, tìm kiếm, đăng ký, đăng nhập, chat nếu được phép.
- Customer: mua hàng, quản lý giỏ hàng, checkout, quản lý địa chỉ, xem đơn, tracking đơn, xác nhận đã nhận hàng.
- Shop Staff: xử lý đơn trước khi giao gồm confirm, pack, handover.
- Delivery Staff/Shipper: cập nhật trạng thái giao hàng.
- Admin: quản lý toàn bộ hệ thống, sản phẩm, user, đơn hàng, giao hàng, chat, báo cáo.

Order Status:
- PENDING
- CONFIRMED
- PACKING
- SHIPPED
- COMPLETED
- CANCELLED

Delivery Status:
- WAITING_PICKUP
- PICKED_UP
- IN_TRANSIT
- OUT_FOR_DELIVERY
- DELIVERED
- FAILED
- RETURNED

Luồng nghiệp vụ:
1. Customer đặt hàng.
2. Shop Staff/Admin xác nhận đơn: PENDING -> CONFIRMED.
3. Shop Staff/Admin đóng gói: CONFIRMED -> PACKING.
4. Shop Staff/Admin bàn giao giao hàng: PACKING -> SHIPPED.
5. Delivery Staff cập nhật deliveryStatus.
6. Customer xem tracking gồm cả orderStatus và deliveryStatus.
7. Customer xác nhận đã nhận hàng khi deliveryStatus = DELIVERED.
8. Admin xem dashboard doanh thu theo ngày, tuần, tháng, quý, năm.

Cách xử lý theo trạng thái:
- Đã có: không tạo lại từ đầu, chỉ polish UI/UX, layout, responsive, loading/empty/error states.
- Đã có một phần: giữ ý tưởng hiện có, bổ sung phần còn thiếu.
- Cần bổ sung: thiết kế thêm component/modal/panel/section cần thiết.
- Cần tạo mới: tạo màn hình web mới hoàn chỉnh.

Hãy đọc file batch được upload cùng prompt này và chỉ xử lý đúng batch đó.
