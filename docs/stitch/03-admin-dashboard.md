# 03. Batch Admin Dashboard Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: polish admin dashboard và bổ sung các màn hình quản trị còn thiếu.

## Layout Admin Đã Có

### Admin dashboard
- Route: `/admin`
- File hiện tại: `pages/admin/AdminPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish dashboard/workspace, layout 3 cột nếu phù hợp, responsive.

### Admin sidebar
- File hiện tại: `features/admin/layout/AdminSidebar.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish icon menu, active state, logout.

### Admin secondary sidebar
- File hiện tại: `features/admin/layout/AdminSecondarySidebar.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish context menu theo module.

### Admin header
- File hiện tại: `features/admin/layout/AdminHeader.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish title, action buttons, account menu.

## Dashboard Và Report

### Dashboard overview
- File hiện tại: `features/admin/dashboard/DashboardOverview.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish cards tổng quan.

### Revenue dashboard
- File hiện tại: `features/admin/reports/ReportsPage.tsx`
- Trạng thái: Đã có một phần
- Cần Stitch: bổ sung filter doanh thu theo ngày/tuần/tháng/quý/năm.

### Revenue by day
- Trạng thái: Cần bổ sung
- Cần Stitch: tab/filter doanh thu theo ngày.

### Revenue by week
- Trạng thái: Cần bổ sung
- Cần Stitch: tab/filter doanh thu theo tuần.

### Revenue by month
- Trạng thái: Cần bổ sung
- Cần Stitch: tab/filter doanh thu theo tháng.

### Revenue by quarter
- Trạng thái: Cần bổ sung
- Cần Stitch: tab/filter doanh thu theo quý.

### Revenue by year
- Trạng thái: Cần bổ sung
- Cần Stitch: tab/filter doanh thu theo năm.

### Recent orders report
- Trạng thái: Đã có một phần
- Cần Stitch: polish recent orders table.

## Admin Managers Đã Có

### User management
- File hiện tại: `features/admin/users/UserManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish table user, role badge, status, filter/search.

### Staff management
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: quản lý tài khoản nhân viên shop và nhân viên giao hàng.
- Cần Stitch:
  - Danh sách staff.
  - Tạo staff mới.
  - Sửa thông tin staff.
  - Gán role `SHOP_STAFF` hoặc `DELIVERY_STAFF`.
  - Bật/tắt trạng thái hoạt động.
  - Reset mật khẩu hoặc gửi link đặt mật khẩu.
  - Xem đơn đang phụ trách nếu có.

### Staff detail
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: xem toàn bộ thông tin và hoạt động của một staff.
- Cần Stitch:
  - Thông tin cá nhân: họ tên, email, số điện thoại, role, trạng thái.
  - Lần đăng nhập gần nhất.
  - Đơn đang phụ trách.
  - Lịch sử xử lý đơn.
  - Lịch làm việc trong tuần/tháng.
  - Ghi chú nội bộ của admin nếu cần.

### Staff schedule / shift planning
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: xem và xếp lịch làm việc cho staff.
- Cần Stitch:
  - Calendar view theo ngày/tuần/tháng.
  - Danh sách ca làm việc.
  - Tạo ca làm việc mới.
  - Sửa ca làm việc.
  - Gán staff vào ca.
  - Đổi staff giữa các ca.
  - Hiển thị staff đang rảnh, đang bận, nghỉ phép.
  - Cảnh báo trùng ca hoặc quá tải lịch.
  - Bộ lọc theo role: `SHOP_STAFF`, `DELIVERY_STAFF`.
  - Bộ lọc theo trạng thái ca: sắp tới, đang diễn ra, đã kết thúc.

### Staff assignment
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: phân công công việc hoặc đơn hàng cho staff.
- Cần Stitch:
  - Gán đơn cần xử lý cho `SHOP_STAFF`.
  - Gán đơn đã `SHIPPED` cho `DELIVERY_STAFF`.
  - Xem số đơn mỗi staff đang phụ trách.
  - Cảnh báo staff quá tải.
  - Quick action chuyển đơn sang staff khác.
  - Lý do thay đổi phân công nếu cần.

### Staff leave / availability
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: quản lý ngày nghỉ và tình trạng sẵn sàng của staff.
- Cần Stitch:
  - Danh sách ngày nghỉ.
  - Tạo yêu cầu nghỉ cho staff.
  - Duyệt/từ chối nghỉ nếu có flow approval.
  - Đánh dấu staff unavailable.
  - Không cho gán ca hoặc đơn cho staff unavailable.

### Staff performance
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Mục tiêu: theo dõi hiệu suất làm việc của staff.
- Cần Stitch:
  - Số đơn đã xử lý.
  - Số đơn đang xử lý.
  - Số đơn giao thành công.
  - Số đơn giao thất bại.
  - Thời gian xử lý trung bình.
  - Tỷ lệ hoàn thành.
  - Bộ lọc theo ngày/tuần/tháng.
  - So sánh hiệu suất giữa các staff nếu phù hợp.

### Brand manager
- File hiện tại: `features/admin/brands/BrandManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish CRUD brand.

### Category manager
- File hiện tại: `features/admin/categories/CategoryManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish CRUD category.

### Sport manager
- File hiện tại: `features/admin/sports/SportManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish CRUD sport.

### Size manager
- File hiện tại: `features/admin/sizes/SizeManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish CRUD size.

### Color manager
- File hiện tại: `features/admin/colors/ColorManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish swatch/color CRUD.

### Attribute manager
- File hiện tại: `features/admin/attributes/AttributeManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish quản lý thuộc tính.

### Product manager
- File hiện tại: `features/admin/products/ProductManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish product table, search, filter, action menu.

### Product create/edit/variant/image/stock
- File hiện tại: nằm trong `ProductManager`
- Trạng thái: Đã có một phần
- Cần Stitch: polish form tạo/sửa sản phẩm, variant editor, image manager, stock controls.

### Order management
- File hiện tại: `features/admin/orders/OrderManager.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish order table, filters, status badge.

### Order detail
- Trạng thái: Đã có một phần
- Cần Stitch: polish modal/detail với items, shipping info, payment info.

### Order status management panel
- Trạng thái: Cần bổ sung
- Cần Stitch: action confirm, pack, handover.

## Admin Screens Cần Tạo Mới

### Delivery monitoring page
- Trạng thái: Cần tạo mới
- Cần Stitch: admin xem deliveryStatus của tất cả đơn.

### Role management page
- Trạng thái: Cần tạo mới
- Cần Stitch: quản lý roles CUSTOMER, SHOP_STAFF, DELIVERY_STAFF, ADMIN.

### Admin settings/account menu
- Trạng thái: Cần bổ sung
- Cần Stitch: settings/account menu riêng.

## Admin Chat

### Admin chat room list
- File hiện tại: `features/admin/chat/components/ChatRoomList.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish room list, unread state.

### Admin chat window
- File hiện tại: `features/admin/chat/components/ChatWindow.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish chat messages, image preview.

### Admin customer support page
- Trạng thái: Đã có một phần
- Cần Stitch: polish admin chat tab trong AdminPage.
