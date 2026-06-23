# 01. Batch Customer Mobile

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: thiết kế mobile app cho customer storefront, flow mua hàng, checkout, tracking và account.

## Screens Cần Thiết Kế

### Splash screen
- Trạng thái: Cần tạo mới
- Cần Stitch: màn hình mở app với logo SPORTSHOP.

### Onboarding screen
- Trạng thái: Cần tạo mới
- Cần Stitch: 2-3 màn hình giới thiệu mua đồ thể thao, tracking đơn, hỗ trợ chat.

### Home screen
- Web hiện có: `pages/home/HomePage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: mobile home gồm search, banner, category shortcut, brand nổi bật, sản phẩm gợi ý.

### Search screen
- Web hiện có: `/search`, dùng `ProductsPage`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: search input, recent searches, result list, empty state.

### Product listing screen
- Web hiện có: `pages/products/ProductsPage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: product grid/list mobile, filter button, sort button, infinite scroll.

### Filter bottom sheet
- Web hiện có: `ProductFilters`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: filter theo brand, category, sport, price, color.

### Sort bottom sheet
- Web hiện có: `ProductSort`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: sort theo giá, mới nhất, phổ biến.

### Product detail screen
- Web hiện có: `ProductDetailPage`, `ProductDetail`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: gallery, info, size/color, quantity, add to cart sticky button.

### Product image gallery screen
- Web hiện có: `ProductGallery`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: fullscreen gallery, swipe images.

### Cart screen
- Web hiện có: `CartSheet`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: cart list, quantity controls, subtotal, checkout CTA.

### Checkout screen
- Web hiện có: `CheckoutPage`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: address, payment method, order summary, note.

### Address selection screen
- Trạng thái: Cần bổ sung
- Cần Stitch: chọn địa chỉ giao hàng, set default.

### Add/Edit address screen
- Trạng thái: Cần bổ sung
- Cần Stitch: form thêm/sửa địa chỉ.

### Payment method screen
- Trạng thái: Đã có một phần
- Cần Stitch: chọn COD hoặc online payment.

### Payment result screen
- Web hiện có: `PaymentPage`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: trạng thái success/failure/pending.

### My orders screen
- Web hiện có: `OrdersPage`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: order cards, filter by status, pull to refresh.

### Order detail screen
- Web hiện có: `OrdersPage`
- Trạng thái: Đã có một phần
- Cần Stitch: items, address, payment, orderStatus, deliveryStatus.

### Order tracking screen
- Trạng thái: Đã có một phần
- Cần Stitch: timeline gồm orderStatus và deliveryStatus.

### Confirm received bottom sheet
- Trạng thái: Cần bổ sung
- Cần Stitch: xác nhận khi deliveryStatus = DELIVERED.

### Profile screen
- Web hiện có: `ProfilePage`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: thông tin cá nhân, account actions, logout.

### Address management screen
- Web hiện có: `ProfilePage`
- Trạng thái: Đã có một phần
- Cần Stitch: danh sách địa chỉ, add/edit/delete/default.

### Customer chat screen
- Web hiện có: `CustomerChatPage`, `ChatBubble`
- Trạng thái: Đã có một phần
- Cần Stitch: chat messages, input, image preview, empty state.

## Bottom Navigation Đề Xuất

- Home
- Search
- Cart
- Orders
- Profile

