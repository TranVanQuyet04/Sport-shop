# 00. Prompt Tổng Cho Stitch Mobile

Tôi đang chuyển dự án Sportswear E-Commerce System sang thiết kế mobile app.

Hãy thiết kế UI mobile app cho Android/iOS, không thiết kế website/web dashboard.

## Phong Cách

- Mobile-first, ưu tiên màn hình điện thoại.
- Tối ưu thao tác một tay.
- Sport e-commerce hiện đại, mạnh mẽ, rõ ràng, chuyên nghiệp.
- Màu chủ đạo: trắng, đen, xám, đỏ accent.
- Text UI dùng tiếng Việt có dấu.
- Không dùng sidebar desktop hoặc table rộng.
- Nếu có dữ liệu dạng bảng, hãy chuyển thành card list, filter, search, bottom sheet hoặc detail screen.

## Trạng Thái UI Cần Có

- Loading
- Empty
- Error
- Success
- Disabled

## Component Mobile Nên Dùng

- Splash screen
- Onboarding
- Bottom navigation
- Top app bar
- Search bar
- Product card
- Category shortcut
- Brand card
- Filter bottom sheet
- Sort bottom sheet
- Modal / bottom sheet
- Status badge
- Timeline
- Stepper
- Form input
- Toast / snackbar
- Pull to refresh
- Infinite scroll nếu phù hợp

## Roles

- Guest: xem sản phẩm, tìm kiếm, đăng ký, đăng nhập, chat nếu được phép.
- Customer: mua hàng, quản lý giỏ hàng, checkout, quản lý địa chỉ, xem đơn, tracking đơn, xác nhận đã nhận hàng.
- Shop Staff: xử lý đơn trước khi giao gồm confirm, pack, handover.
- Delivery Staff/Shipper: cập nhật trạng thái giao hàng.
- Admin: quản lý toàn bộ hệ thống, sản phẩm, user, staff, đơn hàng, giao hàng, chat, báo cáo.

## Order Status

- PENDING
- CONFIRMED
- PACKING
- SHIPPED
- COMPLETED
- CANCELLED

## Delivery Status

- WAITING_PICKUP
- PICKED_UP
- IN_TRANSIT
- OUT_FOR_DELIVERY
- DELIVERED
- FAILED
- RETURNED

## Luồng Nghiệp Vụ

1. Customer đặt hàng.
2. Shop Staff/Admin xác nhận đơn: PENDING -> CONFIRMED.
3. Shop Staff/Admin đóng gói: CONFIRMED -> PACKING.
4. Shop Staff/Admin bàn giao giao hàng: PACKING -> SHIPPED.
5. Delivery Staff cập nhật deliveryStatus.
6. Customer xem tracking gồm cả orderStatus và deliveryStatus.
7. Customer xác nhận đã nhận hàng khi deliveryStatus = DELIVERED.
8. Admin xem dashboard doanh thu theo ngày, tuần, tháng, quý, năm.
9. Admin quản lý staff, lịch làm việc, phân công, nghỉ phép, hiệu suất.

## Cách Stitch Xử Lý Trạng Thái

- Đã có: polish/cải thiện UI mobile.
- Đã có một phần: giữ ý tưởng hiện có và bổ sung phần còn thiếu.
- Cần chuyển từ web: chuyển layout web sang mobile app, không dùng sidebar/table desktop.
- Cần bổ sung: tạo thêm bottom sheet, modal, section hoặc state cần thiết.
- Cần tạo mới: thiết kế màn hình mobile mới hoàn chỉnh.

