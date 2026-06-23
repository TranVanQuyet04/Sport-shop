# 03. Batch Admin Mobile

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: thiết kế mobile admin app bằng card list, tabs, filters, detail screens. Không dùng web sidebar hoặc bảng desktop rộng.

## Dashboard Và Report

### Admin dashboard home
- Web hiện có: `AdminPage`, `DashboardOverview`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: cards tổng quan, quick actions, recent activity.

### Revenue overview screen
- Web hiện có: `ReportsPage`
- Trạng thái: Đã có một phần
- Cần Stitch: doanh thu theo ngày/tuần/tháng/quý/năm bằng tabs hoặc segmented control.

### Recent orders screen
- Trạng thái: Đã có một phần
- Cần Stitch: order cards, status badge, filter.

## User Và Staff

### User management screen
- Web hiện có: `UserManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: user card list, search, filter role/status, detail.

### Staff management screen
- Trạng thái: Cần tạo mới
- Cần Stitch: danh sách staff, tạo/sửa staff, gán role SHOP_STAFF/DELIVERY_STAFF, active/inactive, reset password.

### Staff detail screen
- Trạng thái: Cần tạo mới
- Cần Stitch: thông tin cá nhân, role, trạng thái, đơn đang phụ trách, lịch sử xử lý, ghi chú.

### Staff schedule / shift planning screen
- Trạng thái: Cần tạo mới
- Cần Stitch: calendar mobile, danh sách ca, tạo/sửa ca, gán staff, cảnh báo trùng ca/quá tải.

### Staff assignment screen
- Trạng thái: Cần tạo mới
- Cần Stitch: gán đơn cho SHOP_STAFF hoặc DELIVERY_STAFF, cảnh báo quá tải, chuyển đơn.

### Staff leave / availability screen
- Trạng thái: Cần tạo mới
- Cần Stitch: ngày nghỉ, unavailable, duyệt/từ chối nếu có approval.

### Staff performance screen
- Trạng thái: Cần tạo mới
- Cần Stitch: số đơn xử lý, giao thành công/thất bại, thời gian trung bình, tỷ lệ hoàn thành.

### Role management screen
- Trạng thái: Cần tạo mới
- Cần Stitch: quản lý CUSTOMER, SHOP_STAFF, DELIVERY_STAFF, ADMIN.

## Catalog Và Product

### Brand management screen
- Web hiện có: `BrandManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: card list, add/edit bottom sheet.

### Category management screen
- Web hiện có: `CategoryManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: category list, parent/child, add/edit.

### Sport management screen
- Web hiện có: `SportManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: sport list, add/edit.

### Size/Color/Attribute management screen
- Web hiện có: `SizeManager`, `ColorManager`, `AttributeManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: tabs cho size/color/attribute, swatches, add/edit.

### Product management screen
- Web hiện có: `ProductManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: product card list, search/filter, action menu.

### Product create/edit screen
- Web hiện có: `ProductManager`
- Trạng thái: Đã có một phần
- Cần Stitch: multi-step mobile form.

### Product variant/image/stock screen
- Web hiện có: `ProductManager`
- Trạng thái: Đã có một phần
- Cần Stitch: variant editor, image manager, stock controls.

## Order Và Delivery

### Order management screen
- Web hiện có: `OrderManager`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: order cards, filter by orderStatus, search.

### Order detail screen
- Trạng thái: Đã có một phần
- Cần Stitch: items, customer, address, payment, timeline, actions.

### Delivery monitoring screen
- Trạng thái: Cần tạo mới
- Cần Stitch: xem deliveryStatus của các đơn, filter by status/staff.

## Chat Và Settings

### Admin chat room list
- Web hiện có: `ChatRoomList`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: room list mobile, unread badge.

### Admin chat screen
- Web hiện có: `ChatWindow`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: messages, input, image preview.

### Admin settings/account screen
- Trạng thái: Cần bổ sung
- Cần Stitch: profile, password, logout.

