# 01. Batch Customer Storefront Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: polish và bổ sung UI cho customer storefront, flow mua hàng, cart, checkout, tracking.

## Màn Hình Đã Có Cần Polish

### Trang chủ
- Route: `/`
- File hiện tại: `pages/home/HomePage.tsx`
- Trạng thái: Đã có
- Cần Stitch: cải thiện hero, thương hiệu nổi bật, sản phẩm gợi ý, responsive.

### Danh sách sản phẩm
- Route: `/collections`
- File hiện tại: `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish product grid, filter, sort, pagination, empty state.

### Danh sách sản phẩm theo danh mục
- Route: `/collections/:category`
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: thêm heading, breadcrumb, filter theo danh mục.

### Danh sách sản phẩm theo danh mục con
- Route: `/collections/:category/:subcategory`
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: thêm breadcrumb sâu và trạng thái empty.

### Kết quả tìm kiếm
- Route: `/search`
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: thêm keyword state, no-result state, loading state.

### Chi tiết sản phẩm
- Route: `/product/:slug`
- File hiện tại: `pages/product-detail/ProductDetailPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish gallery, chọn size/color, số lượng, CTA thêm vào giỏ, related products.

### Danh sách thương hiệu
- Route: `/brands`
- File hiện tại: `pages/brands/BrandsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish brand grid, brand banner, empty state.

### Sản phẩm theo thương hiệu
- Route: `/brands/:brand`
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: thêm brand header và filter theo brand.

### Sản phẩm theo môn thể thao
- Route: `/sports`, `/sports/:sport`
- File hiện tại: dùng chung `pages/products/ProductsPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: thêm sport header, sport filter, responsive state.

### Cart sheet / Mini cart
- Component hiện tại: `components/layout/header/CartSheet.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish empty/loading/error, subtotal, checkout CTA, item quantity controls.

### Checkout
- Route: `/checkout`
- File hiện tại: `pages/checkout/CheckoutPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: bổ sung address selector, payment method, order summary, validation state.

### Thanh toán
- Route: `/payment/:paymentId`
- File hiện tại: `pages/payment/PaymentPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish trạng thái success/failure/pending.

### Đơn hàng của tôi
- Route: `/account/orders`
- File hiện tại: `pages/account/OrdersPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish order list/cards, tracking timeline, order detail.

### Hồ sơ cá nhân
- Route: `/account/profile`
- File hiện tại: `pages/account/ProfilePage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish profile form, address management.

## Màn Hình / Component Cần Bổ Sung

### Address selection panel
- Trạng thái: Cần bổ sung
- Cần Stitch: panel chọn địa chỉ trong checkout.

### Add/Edit address modal
- Trạng thái: Cần bổ sung
- Cần Stitch: modal thêm/sửa địa chỉ, đặt địa chỉ mặc định.

### Payment method selection
- Trạng thái: Đã có một phần
- Cần Stitch: UI chọn COD hoặc online payment rõ ràng.

### Order detail modal/page
- Trạng thái: Đã có một phần
- Cần Stitch: UI chi tiết đơn gồm items, địa chỉ, tổng tiền, trạng thái.

### Order tracking timeline
- Trạng thái: Đã có một phần
- Cần Stitch: timeline mới gồm orderStatus và deliveryStatus.

### Confirm received modal
- Trạng thái: Cần bổ sung
- Cần Stitch: modal xác nhận khi deliveryStatus = DELIVERED.

### Customer chat window
- File hiện tại: `pages/account/chat/CustomerChatPage.tsx`, `useCustomerChat`
- Trạng thái: Đã có một phần
- Cần Stitch: polish chat UI, message state, image preview nếu cần.
