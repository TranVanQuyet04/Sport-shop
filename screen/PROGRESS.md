# Tiến Độ Mobile App Sportshop

File này dùng để theo dõi tiến độ code Flutter dựa trên bộ màn hình trong folder `screen`.

Cập nhật gần nhất: 13/06/2026.

## Hướng Làm Hiện Tại

Ưu tiên hiện tại: **hoàn thiện UI Flutter trước**.

Backend/API đã có thể nối sau khi UI ổn định. Vì vậy các màn hình cần ưu tiên:
- Hiển thị đúng layout mobile.
- Điều hướng được giữa các role.
- Có dữ liệu mẫu hoặc trạng thái rỗng/loading/error rõ ràng.
- Không bị phụ thuộc hoàn toàn vào backend trong lúc demo UI.

## Quy Ước

- `[x]` Đã hoàn thành UI/code cơ bản.
- `[~]` Đã có một phần, cần polish hoặc bổ sung state.
- `[ ]` Chưa làm.

## Tổng Quan

| Nhóm màn hình | Trạng thái UI | Ghi chú |
|---|---|---|
| Auth / Public | [x] Đã có | Login, Register, Forgot Password, Reset Password, Guest Chat, Unauthorized, Not Found |
| Customer | [x] Đã có | Home, Search, Product, Cart, Checkout, Order, Tracking, Profile, Chat |
| Admin | [x] Đã có | Dashboard, Revenue, Orders, Products, Staff, Roles, Delivery, Chat, Settings |
| Shop Staff | [x] Đã có | Home, Confirm, Packing, Handover, Timeline |
| Delivery Staff | [x] Đã có | Home, Assigned Orders, Status Update, Failed Report, Account |
| Shared Components | [x] Đã có | Theme, Button, Card, Text Field, Badge, Bottom Sheet, State widgets |

## Đã Hoàn Thành Chung

- [x] Tạo project Flutter mobile.
- [x] Tổ chức code theo MVC, có thêm `service` và `repository`.
- [x] Có các thư mục chính: `model`, `view`, `controller`, `service`, `repository`, `core`.
- [x] Có router trung tâm `sportshop_router.dart`.
- [x] Có theme, màu sắc, typography, spacing.
- [x] Có shared widgets: button, card, text field, bottom sheet, loading/empty/error/success state, status badge.
- [x] Nối route cho Auth/Public, Customer, Admin, Shop Staff, Delivery Staff.
- [x] Thêm lối vào xem nhanh UI theo role ngay tại màn Đăng nhập.
- [x] Thêm dữ liệu demo/fallback cho Customer Flow để demo UI không phụ thuộc backend.
- [x] Polish màn Search: thêm kết quả gợi ý, danh mục phổ biến và bottom sheet bộ lọc dùng shared component.
- [x] Polish màn Support: thêm card hỗ trợ nhanh, chủ đề hỗ trợ và FAQ.
- [x] Thêm profile mẫu khi backend chưa chạy.
- [x] Polish Profile: thêm thông tin hội viên, chỉ số đơn hàng/điểm thưởng và banner demo.
- [x] Polish Customer Chat: thêm header hỗ trợ viên online và phản hồi demo khi backend chat chưa chạy.
- [x] Polish Checkout: thêm step header và đồng bộ ghi chú bằng `AppTextField`.
- [x] Polish Order Success: dùng mã đơn demo khớp dữ liệu mẫu để bấm tracking mở được ngay.
- [x] Polish Tracking: thêm banner demo và nối nút liên hệ hỗ trợ sang Customer Chat.
- [x] Polish Admin Dashboard: thêm dữ liệu demo, banner demo, snapshot vận hành và quick actions rõ hơn.
- [x] Polish Admin Orders: thêm dữ liệu đơn hàng mẫu, banner demo, cập nhật trạng thái local khi backend chưa chạy.
- [x] Admin Orders có tab lọc trạng thái bấm được: Tất cả, Chờ xác nhận, Đã xác nhận, Đang đóng gói, Đang giao, Hoàn thành.
- [x] Polish Admin Products: thêm dữ liệu sản phẩm mẫu, banner demo và search field dùng shared component.
- [x] Dọn UI Admin Products: bỏ cụm filter giả bị trùng với nút Danh mục/Thương hiệu.
- [x] Polish Admin Revenue: thêm banner dữ liệu demo và insight cards.
- [x] Polish Admin Staff: thêm dữ liệu nhân viên mẫu, banner demo và search field dùng shared component.
- [x] Admin Staff Detail có fallback dữ liệu mẫu khi mở trực tiếp bằng URL hoặc backend chưa chạy.
- [x] Admin Staff Detail có tab bấm được cho Thông tin và Lịch làm việc.
- [x] Polish Admin Delivery Monitoring: thêm banner demo và search field dùng shared component.
- [x] Polish Admin Shift Planning: thêm banner demo khi dùng dữ liệu mẫu/local state.
- [x] Polish Admin Leave Management: thêm banner demo cho luồng duyệt nghỉ phép local.
- [x] Polish Admin Staff Performance: thêm ghi chú demo về cách tính KPI hiện tại.
- [x] Polish Admin Role Management: thêm banner demo và search field dùng shared component.
- [x] Polish Admin Chat: thêm phòng chat mẫu và gửi tin nhắn demo khi backend chat chưa chạy.
- [x] Sửa lỗi back/close ở màn thêm sản phẩm khi mở trực tiếp bằng URL.
- [x] Sửa warning runtime `ListTile background color or ink splashes may be invisible` bằng cách bọc các tile có nền bằng `Material`.

## 01. Auth / Public

- [x] `login` - Đã có UI đăng nhập.
- [x] `register` - Đã có UI đăng ký.
- [x] `forgot_password` - Đã có UI quên mật khẩu.
- [x] `reset_password` - Đã có UI đặt lại mật khẩu.
- [x] `guest_chat` - Đã có UI chat khách vãng lai.
- [x] `unauthorized_403` - Đã có UI không có quyền truy cập.
- [x] `not_found_404` - Đã có UI 404.
- [x] `login` có chip xem nhanh Customer/Admin/Shop Staff/Delivery Staff để demo UI không cần đăng nhập.

Việc còn lại:
- [x] Polish validation form cho register/reset password.
- [x] Chuẩn hóa form Auth và Add Address sang shared `AppTextField`.

## 02. Customer

- [x] Splash.
- [x] Onboarding.
- [x] Home.
- [x] Search.
- [x] Filter bottom sheet.
- [x] Product listing.
- [x] Product detail.
- [x] Product gallery.
- [x] Cart.
- [x] Checkout.
- [x] Address book.
- [x] Add address.
- [x] Order success.
- [x] My orders.
- [x] Order detail.
- [x] Tracking.
- [x] Confirm received.
- [x] Profile.
- [x] Support.
- [x] Customer chat.

Việc còn lại:
- [x] Polish dữ liệu mẫu để các màn vẫn đẹp khi chưa bật backend.
- [x] Polish spacing/component các màn Customer chính: Search, Support, Profile, Customer Chat, Checkout, Order Success, Tracking.
- [ ] Kiểm tra lại spacing trên màn Android thật.
- [ ] Bổ sung state rỗng/loading/error đồng nhất ở các màn còn thiếu.

## 03. Admin

- [x] Admin dashboard.
- [x] Revenue report.
- [x] Order management.
- [x] Product management.
- [x] Add product.
- [x] Inventory variants.
- [x] Category management.
- [x] Brand management.
- [x] User management.
- [x] Role management.
- [x] Staff management.
- [x] Staff detail.
- [x] Staff performance.
- [x] Shift planning.
- [x] Leave management.
- [x] Order assignment.
- [x] Delivery monitoring.
- [x] Admin chat rooms.
- [x] Admin chat detail.
- [x] System settings.

Việc còn lại:
- [x] Polish dashboard để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish order management để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Sửa tab trạng thái Admin Orders để chọn được và lọc đúng đơn hàng theo status.
- [x] Polish product management để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Bỏ các option/filter trùng lặp trên màn Product Management.
- [x] Polish revenue report để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish staff management để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Sửa Staff Detail để mở trực tiếp `/admin/staff/{id}` vẫn hiển thị dữ liệu mẫu.
- [x] Bổ sung nội dung lịch làm việc mẫu trong Staff Detail.
- [x] Polish delivery monitoring để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish shift planning để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish leave management để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish staff performance để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Polish role management để dữ liệu mẫu rõ hơn khi không có backend.
- [x] Sửa lỗi controller notify sau dispose khi chuyển màn nhanh.
- [x] Thêm dữ liệu mẫu cho Admin Category/Brand khi backend chưa chạy.
- [x] Sửa lỗi `There is nothing to pop` ở màn Add Product khi bấm back/close từ URL trực tiếp.
- [x] Sửa back ở Staff Detail để mở trực tiếp bằng URL vẫn quay về danh sách staff an toàn.
- [x] Sửa nhóm card/tile quản trị và nhân viên để tránh warning `ListTile` bị che hiệu ứng splash.
- [x] Sửa Admin Chat Rooms để không rơi vào error khi API chat timeout.
- [x] Sửa back ở Admin Chat Detail để mở trực tiếp bằng URL vẫn quay về danh sách chat an toàn.
- [ ] Chuẩn hóa các card quản trị theo cùng spacing và badge.
- [ ] Kiểm tra các màn dài trên thiết bị nhỏ để tránh tràn layout.

## 04. Shop Staff

- [x] Shop Staff home.
- [x] Orders to confirm.
- [x] Packing order.
- [x] Handover delivery.
- [x] Internal order timeline.

Việc còn lại:
- [x] Bổ sung dữ liệu mẫu cho confirm/packing khi chưa có backend.
- [x] Confirm orders có banner demo và search field dùng shared component.
- [x] Polish handover: chọn shipper, chọn/bỏ chọn đơn, ghi chú bằng shared input và CTA bàn giao demo.

## 05. Delivery Staff

- [x] Delivery home.
- [x] Assigned orders.
- [x] Delivery status update.
- [x] Failed delivery report.
- [x] Shipper account.

Việc còn lại:
- [x] Bổ sung dữ liệu mẫu cho assigned orders/status update khi chưa có backend.
- [x] Assigned orders có banner demo và search field dùng shared component.
- [x] Delivery status update có ghi chú nhanh dùng shared component.
- [x] Polish form báo giao thất bại: chọn lý do, ảnh minh chứng demo, ghi chú bằng shared input, CTA FAILED/RETURNED.

## 06. Shared Components

- [x] `SportshopLogo`.
- [x] `AppColors`.
- [x] `AppTextStyles`.
- [x] `AppSpacing`.
- [x] `AppTheme`.
- [x] `AppButton`.
- [x] `AppCard`.
- [x] `AppTextField`.
- [x] `AppBottomSheet`.
- [x] `AppLoadingState`.
- [x] `AppEmptyState`.
- [x] `AppErrorState`.
- [x] `AppSuccessState`.
- [x] `StatusBadge`.
- [x] `OrderStatusBadge`.
- [x] `DeliveryStatusBadge`.

Việc còn lại:
- [x] Thay các form Auth/Add Address còn dùng `TextField` thủ công bằng `AppTextField`.
- [ ] Thay các bottom sheet thủ công bằng `AppBottomSheet`.
- [ ] Tạo thêm component chip filter/role/priority nếu cần.

## Bước Vừa Hoàn Thành

1. Chuyển hướng tiến độ sang **UI Flutter trước, backend sau**.
2. Thêm khu vực **Xem nhanh UI theo vai trò** ở màn Đăng nhập:
   - Customer
   - Admin
   - Shop Staff
   - Delivery
3. Thêm `CustomerDemoData` để Home, Cart, Checkout, Orders và Order Detail vẫn có dữ liệu khi backend chưa chạy.
4. Cho giỏ hàng có thể tăng/giảm/xóa local trong chế độ demo.
5. Cho Product Detail và Checkout đi tiếp luồng demo khi backend chưa sẵn sàng.
6. Polish Search với dữ liệu gợi ý, danh mục phổ biến và bộ lọc dạng bottom sheet.
7. Polish Support với card chat nhanh, chủ đề hỗ trợ và FAQ.
8. Thêm profile mẫu khi backend chưa chạy.
9. Polish Profile với membership card, metric và banner demo.
10. Polish Customer Chat với trạng thái hỗ trợ viên online và phản hồi tự động ở chế độ demo.
11. Polish Checkout với step header và `AppTextField`.
12. Polish Order Success để theo dõi đúng mã đơn demo.
13. Polish Tracking với banner demo và nút liên hệ hỗ trợ.
14. Polish Admin Dashboard/Revenue/Orders/Products/Staff/Delivery/Shift/Leave/Performance/Role với dữ liệu demo và banner UI-first.
15. Polish Shop Staff Confirm Orders với đơn mẫu, banner demo và search field dùng shared component.
16. Polish Delivery Assigned Orders và Delivery Status Update với dữ liệu demo, banner và shared input.
17. Polish Shop Staff Handover với chọn shipper, chọn đơn và bàn giao demo.
18. Polish Delivery Failed Report với chọn lý do, ảnh minh chứng demo và CTA FAILED/RETURNED.
19. Sửa lỗi `used after being disposed` khi chuyển màn admin nhanh.
20. Thêm fallback demo cho Admin Category/Brand.
21. Sửa lỗi `There is nothing to pop` ở màn Add Product khi mở trực tiếp `/admin/products/new`.
22. Sửa tab trạng thái Admin Orders để bấm chọn và lọc theo status.
23. Sửa Staff Detail để có fallback demo và back an toàn khi mở trực tiếp URL.
24. Sửa tab Staff Detail để bấm được, hiển thị thông tin và lịch làm việc mẫu.
25. Bỏ tab Hiệu suất khỏi Staff Detail, chỉ giữ Thông tin và Lịch làm việc.
26. Sửa warning runtime ListTile/Material ở các tile chính.
27. Dọn UI Admin Products, bỏ cụm option/filter trùng.
28. Thêm fallback demo cho Admin Chat Rooms và Admin Chat Detail.
29. Chạy `flutter analyze`: không có lỗi.

## Bước Tiếp Theo Nên Làm

1. Test full role flow trên Android: Customer, Admin, Shop Staff, Delivery Staff.
2. Nếu còn thời gian, polish User Management, Category/Brand và Inventory Variants.
3. Cuối cùng mới quay lại nối backend/API thật.

## Ghi Chú Backend Để Làm Sau

- Backend hiện chưa có `GET /api/orders/{id}`.
- Backend hiện chưa có `deliveryStatus` riêng.
- Backend cần đồng bộ role `DELIVERY_STAFF` hoặc `SHIPPER`.
- Backend chưa có endpoint lưu phân công đơn hàng, ca làm việc và nghỉ phép.
- Backend chat chưa có endpoint lấy lịch sử tin nhắn theo room.
