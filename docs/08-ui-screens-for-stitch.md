# 08. Danh Sách Màn Hình UI Cho Stitch

File này dùng để gửi cho Stitch tạo hoặc bổ sung UI frontend cho dự án Sportswear E-Commerce Website.

Lưu ý cho Stitch:
- Đây là tài liệu yêu cầu UI dạng web app.
- Không thiết kế mobile app.
- Ưu tiên desktop trước, sau đó responsive cho tablet/mobile.
- Các màn hình đã có trong project thì polish/cải thiện.
- Các màn hình đã có một phần thì bổ sung phần còn thiếu.
- Các màn hình cần tạo mới thì thiết kế mới hoàn chỉnh.
- Text UI dùng tiếng Việt có dấu.

Trạng thái:
- Đã có: đã có route/page/component trong project.
- Đã có một phần: đã có một phần UI hoặc component, cần bổ sung thêm.
- Cần bổ sung: cần thêm modal, panel, section, state hoặc component.
- Cần tạo mới: chưa có page/component riêng trong project.

## 1. Route Hiện Có Trong Project

### Trang chủ
- Route: `/`
- Trạng thái: Đã có
- File hiện tại: `pages/home/HomePage.tsx`
- Gợi ý: polish hero, sản phẩm nổi bật, thương hiệu nổi bật, responsive.

### Đăng nhập
- Route: `/login`
- Trạng thái: Đã có
- File hiện tại: `pages/auth/LoginPage.tsx`
- Gợi ý: polish form, validation, loading, error state.

### Đăng ký
- Route: `/register`
- Trạng thái: Đã có
- File hiện tại: `pages/auth/RegisterPage.tsx`
- Gợi ý: polish form, rule mật khẩu, error state.

### Quên mật khẩu
- Route: `/forgot-password`
- Trạng thái: Đã có
- File hiện tại: `pages/auth/ForgotPasswordPage.tsx`
- Gợi ý: polish hướng dẫn và trạng thái gửi email.

### Đặt lại mật khẩu
- Route: `/reset-password`
- Trạng thái: Đã có
- File hiện tại: `pages/auth/ResetPasswordPage.tsx`
- Gợi ý: polish form mật khẩu mới và xác nhận mật khẩu.

### Danh sách sản phẩm
- Route: `/collections`
- Trạng thái: Đã có
- File hiện tại: `pages/products/ProductsPage.tsx`
- Gợi ý: polish product grid, filter, sort, pagination, empty state.

### Danh sách sản phẩm theo danh mục
- Route: `/collections/:category`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm heading/filter theo danh mục.

### Danh sách sản phẩm theo danh mục con
- Route: `/collections/:category/:subcategory`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm breadcrumb và filter theo cấp danh mục.

### Danh sách sản phẩm cấp 3
- Route: `/collections/:category/:subcategory/:subsubcategory`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm breadcrumb sâu và trạng thái empty.

### Chi tiết sản phẩm
- Route: `/product/:slug`
- Trạng thái: Đã có
- File hiện tại: `pages/product-detail/ProductDetailPage.tsx`
- Gợi ý: polish gallery, chọn size/color, số lượng, CTA thêm vào giỏ.

### Danh sách thương hiệu
- Route: `/brands`
- Trạng thái: Đã có
- File hiện tại: `pages/brands/BrandsPage.tsx`
- Gợi ý: polish brand grid, brand banner, empty state.

### Sản phẩm theo thương hiệu
- Route: `/brands/:brand`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm brand header và filter theo brand.

### Sản phẩm theo môn thể thao
- Route: `/sports`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm sport landing/filter.

### Sản phẩm theo môn thể thao chi tiết
- Route: `/sports/:sport`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm sport header.

### Kết quả tìm kiếm
- Route: `/search`
- Trạng thái: Đã có
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Gợi ý: thêm keyword state và no-result state.

### Checkout
- Route: `/checkout`
- Trạng thái: Đã có
- File hiện tại: `pages/checkout/CheckoutPage.tsx`
- Gợi ý: bổ sung address selector, payment method, order summary.

### Thanh toán
- Route: `/payment/:paymentId`
- Trạng thái: Đã có
- File hiện tại: `pages/payment/PaymentPage.tsx`
- Gợi ý: polish trạng thái success/failure/pending.

### Đơn hàng của tôi
- Route: `/account/orders`
- Trạng thái: Đã có
- File hiện tại: `pages/account/OrdersPage.tsx`
- Gợi ý: cập nhật tracking theo `orderStatus` và `deliveryStatus`.

### Hồ sơ cá nhân
- Route: `/account/profile`
- Trạng thái: Đã có
- File hiện tại: `pages/account/ProfilePage.tsx`
- Gợi ý: polish profile form và address management.

### Admin dashboard
- Route: `/admin`
- Trạng thái: Đã có
- File hiện tại: `pages/admin/AdminPage.tsx`
- Gợi ý: polish layout, sidebar, dashboard, role-based workspace.

### Not found
- Route: `*`
- Trạng thái: Cần bổ sung
- Hiện tại: đang inline trong `App.tsx`
- Gợi ý: tạo page 404 riêng.

## 2. Public / Guest Screens

### Trang chủ
- Trạng thái: Đã có
- Cần Stitch: cải thiện hero, thương hiệu nổi bật, sản phẩm gợi ý, responsive.

### Danh sách sản phẩm / Collections
- Trạng thái: Đã có
- Cần Stitch: cải thiện bộ lọc, sort, pagination, empty state.

### Kết quả tìm kiếm
- Trạng thái: Đã có
- Cần Stitch: thiết kế trạng thái có keyword, không có kết quả, loading.

### Chi tiết sản phẩm
- Trạng thái: Đã có
- Cần Stitch: cải thiện gallery, chọn size/color, số lượng, CTA thêm vào giỏ.

### Danh sách thương hiệu
- Trạng thái: Đã có
- Cần Stitch: cải thiện grid thương hiệu và banner.

### Sản phẩm theo thương hiệu
- Trạng thái: Đã có
- Cần Stitch: thêm brand header và filter rõ ràng.

### Đăng nhập
- Trạng thái: Đã có
- Cần Stitch: polish validation, loading, error.

### Đăng ký
- Trạng thái: Đã có
- Cần Stitch: polish form, password rules, error.

### Quên mật khẩu
- Trạng thái: Đã có
- Cần Stitch: polish trạng thái gửi email.

### Đặt lại mật khẩu
- Trạng thái: Đã có
- Cần Stitch: polish form xác nhận mật khẩu.

### Guest chat widget / Chat bubble
- Trạng thái: Đã có một phần
- File hiện tại: `components/common/ChatBubble.tsx`
- Cần Stitch: thiết kế chat bubble và cửa sổ chat cho guest nếu cho phép guest chat.

## 3. Customer Screens

### Customer storefront
- Trạng thái: Đã có
- File hiện tại: `HomePage`, `MainLayout`, `Header`, `Footer`
- Cần Stitch: polish tổng thể storefront.

### Product listing with filters
- Trạng thái: Đã có
- File hiện tại: `ProductListing`, `ProductFilters`, `ProductSort`
- Cần Stitch: polish filter sidebar, sort, pagination.

### Product detail with variant selection
- Trạng thái: Đã có
- File hiện tại: `ProductDetail`, `ProductGallery`, `ProductInfo`, `ProductTabs`
- Cần Stitch: polish chọn variant, gallery, related products.

### Cart sheet / Mini cart
- Trạng thái: Đã có
- File hiện tại: `CartSheet`
- Cần Stitch: polish empty/loading/error, subtotal, checkout CTA.

### Checkout page
- Trạng thái: Đã có
- File hiện tại: `CheckoutPage`
- Cần Stitch: bổ sung address selector, payment method, order summary.

### Address selection panel
- Trạng thái: Cần bổ sung
- Cần Stitch: panel chọn địa chỉ trong checkout.

### Add/Edit address modal
- Trạng thái: Cần bổ sung
- Cần Stitch: modal thêm/sửa địa chỉ, đặt mặc định.

### Payment method selection
- Trạng thái: Đã có một phần
- Cần Stitch: UI chọn COD hoặc online payment rõ ràng.

### Payment confirmation page
- Trạng thái: Đã có
- File hiện tại: `PaymentPage`
- Cần Stitch: polish success/failure/pending state.

### My orders page
- Trạng thái: Đã có
- File hiện tại: `OrdersPage`
- Cần Stitch: polish order cards/list.

### Order detail modal/page
- Trạng thái: Đã có một phần
- Cần Stitch: tách UI chi tiết đơn hàng rõ hơn.

### Order tracking page
- Trạng thái: Đã có một phần
- Cần Stitch: timeline mới gồm `orderStatus` và `deliveryStatus`.

### Order tracking timeline
- Trạng thái: Đã có một phần
- Cần Stitch: bổ sung status mới: `CONFIRMED`, `PACKING`, `SHIPPED` và delivery statuses.

### Profile page
- Trạng thái: Đã có
- File hiện tại: `ProfilePage`
- Cần Stitch: polish thông tin cá nhân.

### Address management page
- Trạng thái: Đã có một phần
- Cần Stitch: bổ sung list/form/edit/default address UX.

### Customer chat window
- Trạng thái: Đã có một phần
- File hiện tại: `pages/account/chat/CustomerChatPage.tsx`, `useCustomerChat`
- Cần Stitch: polish chat UI.

### Confirm received modal
- Trạng thái: Cần bổ sung
- Cần Stitch: modal xác nhận khi `deliveryStatus = DELIVERED`.

## 4. Shop Staff Screens

### Shop staff dashboard / Order workspace
- Trạng thái: Cần tạo mới hoặc tách từ admin
- Cần Stitch: workspace cho `SHOP_STAFF`, chỉ tập trung xử lý đơn trước khi giao.

### Orders to confirm list
- Trạng thái: Cần bổ sung
- Nền hiện có: `OrderManager`
- Cần Stitch: danh sách đơn `PENDING`.

### Order detail page
- Trạng thái: Đã có một phần trong admin
- Cần Stitch: UI chi tiết đơn cho staff.

### Confirm order screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action `PENDING -> CONFIRMED`.

### Packing order screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action `CONFIRMED -> PACKING`.

### Handover to delivery screen
- Trạng thái: Cần bổ sung
- Cần Stitch: action `PACKING -> SHIPPED`.

### Shop order status timeline
- Trạng thái: Cần bổ sung
- Cần Stitch: timeline riêng cho `orderStatus`.

### Customer/shipping info panel
- Trạng thái: Đã có một phần
- Cần Stitch: polish panel thông tin khách và địa chỉ giao hàng.

### Order items panel
- Trạng thái: Đã có một phần
- Cần Stitch: polish danh sách sản phẩm trong đơn.

## 5. Delivery Staff / Shipper Screens

### Delivery dashboard
- Trạng thái: Cần tạo mới
- Cần Stitch: dashboard riêng cho `DELIVERY_STAFF`.

### Assigned delivery orders list
- Trạng thái: Cần tạo mới
- Cần Stitch: danh sách đơn đã bàn giao cho shipper.

### Delivery order detail page
- Trạng thái: Cần tạo mới
- Cần Stitch: chi tiết địa chỉ, sản phẩm, khách hàng, delivery status.

### Delivery status update screen
- Trạng thái: Cần tạo mới
- Cần Stitch: update `WAITING_PICKUP -> PICKED_UP -> IN_TRANSIT -> OUT_FOR_DELIVERY -> DELIVERED`.

### Delivery timeline screen
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline cho `deliveryStatus`.

### Failed delivery form
- Trạng thái: Cần tạo mới
- Cần Stitch: form lý do giao thất bại, ghi chú, ảnh nếu cần.

### Returned order form
- Trạng thái: Cần tạo mới
- Cần Stitch: form lý do hoàn trả, ghi chú.

### Delivery staff profile/account menu
- Trạng thái: Cần bổ sung
- Cần Stitch: UI account menu riêng cho delivery staff.

## 6. Admin Screens

### Admin dashboard overview
- Trạng thái: Đã có
- File hiện tại: `AdminPage`, `DashboardOverview`, `AdminDashboardContent`
- Cần Stitch: polish dashboard tổng quan.

### Revenue dashboard
- Trạng thái: Đã có một phần
- File hiện tại: `ReportsPage`
- Cần Stitch: bổ sung filter ngày/tuần/tháng/quý/năm.

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

### Order management page
- Trạng thái: Đã có
- File hiện tại: `OrderManager`
- Cần Stitch: polish bảng đơn hàng và filter.

### Order detail page
- Trạng thái: Đã có một phần
- Cần Stitch: polish modal/detail.

### Order status management panel
- Trạng thái: Cần bổ sung
- Cần Stitch: action confirm, pack, handover.

### Delivery monitoring page
- Trạng thái: Cần tạo mới
- Cần Stitch: admin xem `deliveryStatus` của tất cả đơn.

### User management page
- Trạng thái: Đã có
- File hiện tại: `UserManager`
- Cần Stitch: polish bảng user, role, status.

### Staff management page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình quản lý tài khoản nhân viên shop và nhân viên giao hàng.
- Chức năng cần có:
  - Xem danh sách staff.
  - Tạo staff mới.
  - Sửa thông tin staff.
  - Gán role `SHOP_STAFF` hoặc `DELIVERY_STAFF`.
  - Bật/tắt trạng thái hoạt động.
  - Reset mật khẩu hoặc gửi link đặt mật khẩu.
  - Xem đơn đang phụ trách nếu có.

### Staff detail page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình xem chi tiết một staff.
- Chức năng cần có:
  - Thông tin cá nhân.
  - Role và trạng thái tài khoản.
  - Lần đăng nhập gần nhất.
  - Đơn đang phụ trách.
  - Lịch sử xử lý đơn.
  - Lịch làm việc trong tuần/tháng.
  - Ghi chú nội bộ.

### Staff schedule / shift planning page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình xem và xếp lịch làm việc cho staff.
- Chức năng cần có:
  - Calendar view theo ngày/tuần/tháng.
  - Danh sách ca làm việc.
  - Tạo ca làm việc mới.
  - Sửa ca làm việc.
  - Gán staff vào ca.
  - Đổi staff giữa các ca.
  - Hiển thị staff đang rảnh, đang bận, nghỉ phép.
  - Cảnh báo trùng ca hoặc quá tải lịch.
  - Bộ lọc theo role `SHOP_STAFF` và `DELIVERY_STAFF`.
  - Bộ lọc theo trạng thái ca: sắp tới, đang diễn ra, đã kết thúc.

### Staff assignment page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình phân công công việc hoặc đơn hàng cho staff.
- Chức năng cần có:
  - Gán đơn cần xử lý cho `SHOP_STAFF`.
  - Gán đơn đã `SHIPPED` cho `DELIVERY_STAFF`.
  - Xem số đơn mỗi staff đang phụ trách.
  - Cảnh báo staff quá tải.
  - Quick action chuyển đơn sang staff khác.
  - Ghi lý do thay đổi phân công nếu cần.

### Staff leave / availability page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình quản lý ngày nghỉ và tình trạng sẵn sàng của staff.
- Chức năng cần có:
  - Danh sách ngày nghỉ.
  - Tạo yêu cầu nghỉ cho staff.
  - Duyệt/từ chối nghỉ nếu có flow approval.
  - Đánh dấu staff unavailable.
  - Không cho gán ca hoặc đơn cho staff unavailable.

### Staff performance page
- Trạng thái: Cần tạo mới
- Role sử dụng: Admin
- Cần Stitch: màn hình theo dõi hiệu suất staff.
- Chức năng cần có:
  - Số đơn đã xử lý.
  - Số đơn đang xử lý.
  - Số đơn giao thành công.
  - Số đơn giao thất bại.
  - Thời gian xử lý trung bình.
  - Tỷ lệ hoàn thành.
  - Bộ lọc theo ngày/tuần/tháng.
  - So sánh hiệu suất giữa các staff nếu phù hợp.

### Role management page
- Trạng thái: Cần tạo mới
- Cần Stitch: quản lý roles `CUSTOMER`, `SHOP_STAFF`, `DELIVERY_STAFF`, `ADMIN`.

### Brand manager page
- Trạng thái: Đã có
- File hiện tại: `BrandManager`
- Cần Stitch: polish CRUD brand.

### Category manager page
- Trạng thái: Đã có
- File hiện tại: `CategoryManager`
- Cần Stitch: polish CRUD category.

### Sport manager page
- Trạng thái: Đã có
- File hiện tại: `SportManager`
- Cần Stitch: polish CRUD sport.

### Size manager page
- Trạng thái: Đã có
- File hiện tại: `SizeManager`
- Cần Stitch: polish CRUD size.

### Color manager page
- Trạng thái: Đã có
- File hiện tại: `ColorManager`
- Cần Stitch: polish CRUD color.

### Attribute manager page
- Trạng thái: Đã có
- File hiện tại: `AttributeManager`
- Cần Stitch: polish quản lý thuộc tính.

### Product manager page
- Trạng thái: Đã có
- File hiện tại: `ProductManager`
- Cần Stitch: polish product table.

### Product create page
- Trạng thái: Đã có một phần
- Cần Stitch: polish form tạo sản phẩm.

### Product edit page
- Trạng thái: Đã có một phần
- Cần Stitch: polish form sửa sản phẩm.

### Product variant manager
- Trạng thái: Đã có một phần
- Cần Stitch: polish variant editor.

### Product image manager
- Trạng thái: Đã có một phần
- Cần Stitch: polish image manager.

### Inventory / stock panel
- Trạng thái: Đã có một phần
- Cần Stitch: polish stock controls.

### Admin chat room list
- Trạng thái: Đã có
- File hiện tại: `ChatRoomList`
- Cần Stitch: polish room list, unread state.

### Admin chat window
- Trạng thái: Đã có
- File hiện tại: `ChatWindow`
- Cần Stitch: polish chat messages, image preview.

### Admin customer support page
- Trạng thái: Đã có một phần
- Cần Stitch: polish admin chat tab trong `AdminPage`.

### Admin settings/account menu
- Trạng thái: Cần bổ sung
- Cần Stitch: settings/account menu riêng.

## 7. Shared Components / Layouts

### Main customer layout
- Trạng thái: Đã có
- File hiện tại: `MainLayout`

### Customer header
- Trạng thái: Đã có
- File hiện tại: `Header`, `MainHeader`, `Navbar`

### Navigation menu
- Trạng thái: Đã có
- File hiện tại: `NavigationMenu`

### Search bar
- Trạng thái: Đã có
- File hiện tại: `SearchBar`

### Footer
- Trạng thái: Đã có
- File hiện tại: `Footer`

### Product card
- Trạng thái: Đã có
- File hiện tại: `ProductCard`

### Filter sidebar
- Trạng thái: Đã có
- File hiện tại: `ProductFilters`

### Sort control
- Trạng thái: Đã có
- File hiện tại: `ProductSort`

### Pagination
- Trạng thái: Đã có
- File hiện tại: `pagination.tsx`

### Empty state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable empty state.

### Loading state
- Trạng thái: Đã có một phần
- Cần Stitch: chuẩn hóa skeleton/spinner.

### Error state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable error state.

### Auth guard / unauthorized page
- Trạng thái: Cần bổ sung
- Cần Stitch: page unauthorized riêng.

### Not found page
- Trạng thái: Cần bổ sung
- Cần Stitch: page 404 riêng.

### Admin sidebar
- Trạng thái: Đã có
- File hiện tại: `AdminSidebar`

### Admin secondary sidebar
- Trạng thái: Đã có
- File hiện tại: `AdminSecondarySidebar`

### Admin header
- Trạng thái: Đã có
- File hiện tại: `AdminHeader`

### Status badge components
- Trạng thái: Đã có một phần
- Cần Stitch: badge cho `orderStatus` và `deliveryStatus` mới.

### Order timeline component
- Trạng thái: Đã có một phần
- Cần Stitch: update theo `orderStatus` mới.

### Delivery timeline component
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline riêng cho `deliveryStatus`.

## 8. Gợi Ý Chia Batch Cho Stitch

### Batch 1: Customer Storefront
- Trang chủ
- Danh sách sản phẩm
- Chi tiết sản phẩm
- Cart
- Checkout
- Theo dõi đơn hàng

### Batch 2: Auth
- Đăng nhập
- Đăng ký
- Quên mật khẩu
- Đặt lại mật khẩu
- Unauthorized page
- Not found page

### Batch 3: Admin Dashboard
- Dashboard tổng quan
- Doanh thu theo ngày/tuần/tháng/quý/năm
- Quản lý catalog
- Quản lý product
- Quản lý user
- Quản lý order

### Batch 4: Shop Staff Workflow
- Danh sách đơn cần xử lý
- Confirm
- Pack
- Handover to delivery

### Batch 5: Delivery Staff Workflow
- Danh sách đơn được giao
- Chi tiết giao hàng
- Cập nhật `deliveryStatus`
- Failed delivery form
- Returned order form

### Batch 6: Shared Components
- Header
- Sidebar
- Timeline
- Status badge
- Empty state
- Loading state
- Error state
- Modal
