# Sport Shop System - MVP Implementation Plan

Tài liệu này chia nhỏ topic Sport Shop thành các phase triển khai để giao việc cho nhóm. Mục tiêu là hoàn thiện một hệ thống thương mại điện tử bán đồ thể thao gồm customer storefront, admin dashboard, shipper workflow, order tracking, payment và chat support.

## Cấu trúc tài liệu

- [01-project-overview.md](./01-project-overview.md): Tổng quan topic, mục tiêu, role và phạm vi MVP.
- [02-phase-plan.md](./02-phase-plan.md): Chia phase triển khai theo thứ tự ưu tiên.
- [03-role-flows.md](./03-role-flows.md): Luồng chi tiết theo từng role: Guest, Customer, Admin, Shipper.
- [04-module-breakdown.md](./04-module-breakdown.md): Chia module frontend/backend và trách nhiệm từng phần.
- [05-task-board.md](./05-task-board.md): Task list có thể giao cho từng thành viên.
- [06-acceptance-checklist.md](./06-acceptance-checklist.md): Checklist nghiệm thu MVP.

## MVP bắt buộc

Customer:
- Đăng ký, đăng nhập, đăng xuất.
- Xem, tìm kiếm, lọc sản phẩm.
- Xem chi tiết sản phẩm.
- Thêm vào giỏ hàng.
- Checkout.
- Quản lý hồ sơ và địa chỉ giao hàng.
- Xem lịch sử và theo dõi trạng thái đơn hàng.

Admin:
- Đăng nhập dashboard.
- Quản lý sản phẩm, biến thể, brand, category, sport, màu, size.
- Quản lý đơn hàng.
- Quản lý người dùng.
- Xem báo cáo cơ bản.
- Chat với khách hàng.

Shipper:
- Đăng nhập.
- Xem đơn cần giao.
- Cập nhật trạng thái giao hàng.

Payment:
- COD là bắt buộc.
- Online payment/VNPAY là phần mở rộng tốt.

## Luồng nghiệp vụ tổng thể

1. Admin tạo brand, category, sport, size, color.
2. Admin tạo product và product variants.
3. Customer xem sản phẩm.
4. Customer thêm sản phẩm vào cart.
5. Customer checkout.
6. Hệ thống tạo order.
7. Admin xác nhận/xử lý order.
8. Shipper cập nhật giao hàng.
9. Customer theo dõi trạng thái đơn hàng.
10. Customer xác nhận đã nhận hàng.
11. Dashboard cập nhật số liệu.
