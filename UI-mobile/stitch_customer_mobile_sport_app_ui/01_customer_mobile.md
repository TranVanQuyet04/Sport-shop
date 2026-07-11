# 01. Batch Customer Mobile

Upload file nÃ y cÃ¹ng `00-mobile-master-prompt.md`.

Má»¥c tiÃªu: thiáº¿t káº¿ mobile app cho customer storefront, flow mua hÃ ng, checkout, tracking vÃ  account.

## Screens Cáº§n Thiáº¿t Káº¿

### Splash screen
- Tráº¡ng thÃ¡i: Cáº§n táº¡o má»›i
- Cáº§n Stitch: mÃ n hÃ¬nh má»Ÿ app vá»›i logo StrideX.

### Onboarding screen
- Tráº¡ng thÃ¡i: Cáº§n táº¡o má»›i
- Cáº§n Stitch: 2-3 mÃ n hÃ¬nh giá»›i thiá»‡u mua Ä‘á»“ thá»ƒ thao, tracking Ä‘Æ¡n, há»— trá»£ chat.

### Home screen
- Web hiá»‡n cÃ³: `pages/home/HomePage.tsx`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: mobile home gá»“m search, banner, category shortcut, brand ná»•i báº­t, sáº£n pháº©m gá»£i Ã½.

### Search screen
- Web hiá»‡n cÃ³: `/search`, dÃ¹ng `ProductsPage`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: search input, recent searches, result list, empty state.

### Product listing screen
- Web hiá»‡n cÃ³: `pages/products/ProductsPage.tsx`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: product grid/list mobile, filter button, sort button, infinite scroll.

### Filter bottom sheet
- Web hiá»‡n cÃ³: `ProductFilters`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: filter theo brand, category, sport, price, color.

### Sort bottom sheet
- Web hiá»‡n cÃ³: `ProductSort`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: sort theo giÃ¡, má»›i nháº¥t, phá»• biáº¿n.

### Product detail screen
- Web hiá»‡n cÃ³: `ProductDetailPage`, `ProductDetail`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: gallery, info, size/color, quantity, add to cart sticky button.

### Product image gallery screen
- Web hiá»‡n cÃ³: `ProductGallery`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: fullscreen gallery, swipe images.

### Cart screen
- Web hiá»‡n cÃ³: `CartSheet`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: cart list, quantity controls, subtotal, checkout CTA.

### Checkout screen
- Web hiá»‡n cÃ³: `CheckoutPage`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: address, payment method, order summary, note.

### Address selection screen
- Tráº¡ng thÃ¡i: Cáº§n bá»• sung
- Cáº§n Stitch: chá»n Ä‘á»‹a chá»‰ giao hÃ ng, set default.

### Add/Edit address screen
- Tráº¡ng thÃ¡i: Cáº§n bá»• sung
- Cáº§n Stitch: form thÃªm/sá»­a Ä‘á»‹a chá»‰.

### Payment method screen
- Tráº¡ng thÃ¡i: ÄÃ£ cÃ³ má»™t pháº§n
- Cáº§n Stitch: chá»n COD hoáº·c online payment.

### Payment result screen
- Web hiá»‡n cÃ³: `PaymentPage`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: tráº¡ng thÃ¡i success/failure/pending.

### My orders screen
- Web hiá»‡n cÃ³: `OrdersPage`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: order cards, filter by status, pull to refresh.

### Order detail screen
- Web hiá»‡n cÃ³: `OrdersPage`
- Tráº¡ng thÃ¡i: ÄÃ£ cÃ³ má»™t pháº§n
- Cáº§n Stitch: items, address, payment, orderStatus, deliveryStatus.

### Order tracking screen
- Tráº¡ng thÃ¡i: ÄÃ£ cÃ³ má»™t pháº§n
- Cáº§n Stitch: timeline gá»“m orderStatus vÃ  deliveryStatus.

### Confirm received bottom sheet
- Tráº¡ng thÃ¡i: Cáº§n bá»• sung
- Cáº§n Stitch: xÃ¡c nháº­n khi deliveryStatus = DELIVERED.

### Profile screen
- Web hiá»‡n cÃ³: `ProfilePage`
- Tráº¡ng thÃ¡i: Cáº§n chuyá»ƒn tá»« web
- Cáº§n Stitch: thÃ´ng tin cÃ¡ nhÃ¢n, account actions, logout.

### Address management screen
- Web hiá»‡n cÃ³: `ProfilePage`
- Tráº¡ng thÃ¡i: ÄÃ£ cÃ³ má»™t pháº§n
- Cáº§n Stitch: danh sÃ¡ch Ä‘á»‹a chá»‰, add/edit/delete/default.

### Customer chat screen
- Web hiá»‡n cÃ³: `CustomerChatPage`, `ChatBubble`
- Tráº¡ng thÃ¡i: ÄÃ£ cÃ³ má»™t pháº§n
- Cáº§n Stitch: chat messages, input, image preview, empty state.

## Bottom Navigation Äá» Xuáº¥t

- Home
- Search
- Cart
- Orders
- Profile

