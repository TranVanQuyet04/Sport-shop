# 02. Phase Plan

## Phase 0 - Project Setup

Mục tiêu: đảm bảo team có môi trường chạy thống nhất.

Việc cần làm:
- Setup repo frontend/backend.
- Cấu hình `.env`.
- Chạy database bằng Docker nếu có.
- Chạy backend Spring Boot.
- Chạy frontend Vite.
- Thống nhất branch workflow.
- Thống nhất format commit.

Deliverables:
- Frontend chạy được.
- Backend chạy được.
- Database kết nối được.
- README có hướng dẫn run project.

Người phù hợp:
- 1 backend member.
- 1 frontend member.
- 1 người phụ trách integration.

## Phase 1 - Authentication & Role-Based Access

Mục tiêu: hoàn thiện đăng ký, đăng nhập và phân quyền.

Customer:
- Register.
- Login.
- Logout.
- Forgot password.
- Reset password.

Admin/Shipper:
- Login.
- Kiểm tra role khi vào `/admin`.
- Admin thấy dashboard đầy đủ.
- Shipper chỉ thấy module đơn hàng.

Backend:
- Auth APIs.
- JWT access token/refresh token.
- Role-based security.
- Current user API.

Frontend:
- Login page.
- Register page.
- Forgot password page.
- Reset password page.
- Auth store.
- Protected route behavior.
- Header user menu theo role.

Acceptance:
- User đăng ký và đăng nhập được.
- User sai role không vào được admin.
- Logout xóa session.
- Header hiển thị đúng trạng thái login.

## Phase 2 - Catalog Foundation

Mục tiêu: tạo dữ liệu nền cho sản phẩm.

Module cần làm:
- Brand management.
- Category management.
- Sport management.
- Color management.
- Size management.

Backend:
- CRUD API cho brand/category/sport/color/size.
- Validation dữ liệu trùng tên.
- Không xóa dữ liệu đang được product dùng, hoặc soft delete.

Frontend Admin:
- Danh sách.
- Tạo mới.
- Cập nhật.
- Xóa/ẩn.
- Loading/error state.

Acceptance:
- Admin tạo được dữ liệu nền.
- Storefront có thể dùng brand/category/sport để navigation và filter.

## Phase 3 - Product Management

Mục tiêu: admin quản lý được sản phẩm bán trên shop.

Product gồm:
- Name.
- Slug.
- Description.
- Base price.
- Brand.
- Category.
- Sport.
- Images.
- Variants.

Variant gồm:
- Color.
- Size.
- SKU.
- Stock quantity.
- Price.
- Variant image.

Backend:
- Product CRUD.
- Product detail API.
- Product variant CRUD.
- SKU generation.
- Upload image hoặc image URL.
- Public product listing API.

Frontend Admin:
- Product table.
- Product create/edit form.
- Variant editor.
- Image management.
- Stock display.

Frontend Customer:
- Product card.
- Product listing.
- Product detail.

Acceptance:
- Admin tạo sản phẩm có variants.
- Customer xem được danh sách và chi tiết sản phẩm.
- Product không có stock phải được hiển thị hợp lý.

## Phase 4 - Storefront Product Discovery

Mục tiêu: khách tìm được sản phẩm nhanh và rõ.

Frontend:
- Home page.
- Navigation menu theo category/brand/sport.
- Collections page.
- Search by name.
- Filter by brand.
- Filter by category.
- Filter by sport.
- Filter by price.
- Filter by color.
- Sort product.
- Pagination.

Backend:
- Public product list API hỗ trợ query params.
- Search/filter/sort/pagination.

Acceptance:
- Filter nhiều điều kiện vẫn hoạt động.
- Pagination không mất filter.
- Product card hiển thị ảnh, tên, brand, giá, màu.

## Phase 5 - Cart

Mục tiêu: customer thêm và quản lý giỏ hàng.

Frontend:
- Add to cart từ product detail.
- Cart sheet.
- Hiển thị số lượng item trên icon cart.
- Tăng/giảm số lượng.
- Xóa item.
- Tạm tính.
- CTA checkout.

Backend:
- Add item.
- Get current cart.
- Update quantity.
- Remove item.
- Clear cart sau checkout.

Acceptance:
- Cart đúng theo user đăng nhập.
- Không thêm quá stock.
- Quantity update đúng total.
- Cart vẫn đúng sau reload.

## Phase 6 - Checkout & Payment

Mục tiêu: customer tạo được order từ cart.

Frontend:
- Checkout page.
- Chọn địa chỉ giao hàng.
- Thêm địa chỉ mới.
- Ghi chú đơn hàng.
- Chọn COD hoặc online payment.
- Payment confirmation page.

Backend:
- Create order from cart.
- Snapshot thông tin giao hàng.
- Snapshot price tại thời điểm mua.
- Tạo order items.
- Payment method.
- Payment status.
- Clear cart khi tạo order thành công.

Acceptance:
- Checkout cần login.
- Không checkout cart rỗng.
- Order lưu đúng items, price, address, note.
- COD chuyển về trang orders.
- Online payment chuyển về payment page hoặc gateway.

## Phase 7 - Customer Order Tracking

Mục tiêu: customer theo dõi trạng thái đơn hàng của mình.

Frontend:
- Orders page.
- Order card.
- Order detail modal.
- Timeline trạng thái.
- Badge trạng thái tiếng Việt.
- Nút xác nhận đã nhận hàng khi status là DELIVERED.
- Nút báo chưa nhận hàng nếu cần.

Backend:
- Get my orders.
- Get order detail.
- User chỉ xem order của chính mình.
- User update status DELIVERED -> COMPLETED hoặc CANCELLED theo rule.

Order status flow:
- COD: PENDING -> SHIPPING -> DELIVERED -> COMPLETED.
- Online: PENDING -> PAID -> SHIPPING -> DELIVERED -> COMPLETED.
- Cancel: PENDING/SHIPPING/DELIVERED -> CANCELLED tùy rule.

Acceptance:
- Customer chỉ thấy đơn của mình.
- Timeline hiển thị đúng theo status.
- Customer xác nhận nhận hàng được.
- Sau khi update status, UI refetch và cập nhật ngay.

## Phase 8 - Admin Order Management

Mục tiêu: admin xử lý vòng đời đơn hàng.

Frontend Admin:
- Order list.
- Order detail.
- Filter by status.
- Search by order id/customer.
- Update status.
- Xem payment method.
- Xem shipping info.

Backend:
- Admin get all orders.
- Admin update order status.
- Validate transition status.

Status transition đề xuất:
- PENDING -> SHIPPING đối với COD.
- PENDING -> PAID đối với online payment success.
- PAID -> SHIPPING.
- SHIPPING -> DELIVERED.
- SHIPPING -> CANCELLED.

Acceptance:
- Admin cập nhật trạng thái hợp lệ.
- Không cho cập nhật trạng thái sai flow.
- Customer order tracking phản ánh status admin vừa cập nhật.

## Phase 9 - Shipper Workflow

Mục tiêu: shipper xử lý đơn giao hàng.

Frontend:
- Shipper chỉ thấy order module.
- Danh sách đơn SHIPPING.
- Chi tiết đơn.
- Cập nhật DELIVERED hoặc CANCELLED.

Backend:
- Role shipper.
- API shipper update status.
- Có thể assign order cho shipper nếu kịp.

Acceptance:
- Shipper không quản lý product/user.
- Shipper cập nhật giao thành công/thất bại.
- Customer nhìn thấy trạng thái mới.

## Phase 10 - Profile & Address

Mục tiêu: customer tự quản lý thông tin giao hàng.

Frontend:
- Profile page.
- Update full name.
- Address list.
- Add/edit/delete address.
- Set default address.

Backend:
- Get current profile.
- Update profile.
- Address CRUD.
- Default address.

Acceptance:
- Checkout lấy được address.
- Không xóa default address nếu rule không cho phép.
- Address hiển thị đúng trong order snapshot.

## Phase 11 - Chat Support

Mục tiêu: customer và admin trao đổi tư vấn.

Frontend Customer:
- Chat bubble.
- Send message.
- Receive reply.

Frontend Admin:
- Chat room list.
- Chat window.
- Unread indicator.
- Image preview nếu có.

Backend:
- Chat room.
- Chat message.
- WebSocket realtime.
- REST fallback nếu cần.

Acceptance:
- Customer gửi tin được.
- Admin nhận và trả lời được.
- Tin nhắn lưu lịch sử.

## Phase 12 - Report Dashboard

Mục tiêu: admin xem tình hình kinh doanh cơ bản.

Metrics:
- Total revenue.
- Total orders.
- Pending orders.
- Completed orders.
- Total customers.
- Total products.
- Recent orders.

Frontend:
- Dashboard overview cards.
- Recent orders table.
- Simple chart nếu kịp.

Backend:
- Report API.
- Date range nếu kịp.

Acceptance:
- Dashboard không crash khi không có data.
- Số liệu phản ánh data trong database.

## Phase 13 - Polish, Testing & Demo Preparation

Mục tiêu: hoàn thiện trải nghiệm và chuẩn bị bảo vệ.

Việc cần làm:
- Fix lỗi UI tiếng Việt.
- Responsive desktop/mobile.
- Loading/empty/error states.
- Seed data đẹp.
- Test full flow customer.
- Test full flow admin.
- Test full flow shipper.
- Chuẩn bị tài khoản demo.
- Chuẩn bị script demo.

Acceptance:
- Build frontend pass.
- Backend start pass.
- Demo flow không bị block.
- Có dữ liệu sản phẩm đủ đẹp để trình bày.
