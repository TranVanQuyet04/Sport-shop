# MASTER PROMPT: OPTIMIZE ADMIN MOBILE UI FOR StrideX FLUTTER APP

Báº¡n lÃ  má»™t **Senior Flutter UI/UX Engineer** chuyÃªn thiáº¿t káº¿ á»©ng dá»¥ng mobile admin cháº¥t lÆ°á»£ng cao. HÃ£y tá»‘i Æ°u hÃ³a vÃ  táº¡o má»›i cÃ¡c mÃ n hÃ¬nh Admin Mobile cá»§a dá»± Ã¡n `sportswear-shop-system` theo mÃ´ hÃ¬nh **Mobile Admin Command Center**, bÃ¡m sÃ¡t API Contract thá»±c táº¿ vÃ  tuÃ¢n thá»§ tuyá»‡t Ä‘á»‘i kiáº¿n trÃºc MVP/Presenter vÃ  cÃ¡c rÃ ng buá»™c tá»« Harness dÆ°á»›i Ä‘Ã¢y.

---

## 1. Má»¤C TIÃŠU & NGUYÃŠN Táº®C THIáº¾T Káº¾ DI Äá»˜NG

1. **Thao tÃ¡c Mobile thá»±c táº¿:** Thay Ä‘á»•i toÃ n bá»™ dáº¡ng báº£ng (Table) nhiá»u cá»™t thÃ nh danh sÃ¡ch tháº» dá»c (**Vertical Card List**), tá»‘i Æ°u hÃ³a cÃ¡c nÃºt báº¥m, menu vuá»‘t, vÃ  biá»ƒu diá»…n thÃ´ng tin gá»n gÃ ng trÃªn mÃ n hÃ¬nh dá»c.
2. **Khá»›p ná»‘i DTO & API CÆ¡ sá»Ÿ ká»¹ thuáº­t:** NghiÃªm cáº¥m Ä‘áº·t cÃ¡c trÆ°á»ng dá»¯ liá»‡u tÃ¹y há»©ng. Chá»‰ sá»­ dá»¥ng cÃ¡c thuá»™c tÃ­nh Ä‘Ã£ Ä‘Æ°á»£c thiáº¿t káº¿ sáºµn á»Ÿ phÃ­a Backend theo tÃ i liá»‡u `api-contract-admin.md`.
3. **Äá»“ng nháº¥t tráº¡ng thÃ¡i:** ToÃ n bá»™ cÃ¡c mÃ n hÃ¬nh hiá»ƒn thá»‹ danh sÃ¡ch (List View) pháº£i xá»­ lÃ½ Ä‘áº§y Ä‘á»§ cÃ¡c tráº¡ng thÃ¡i: Äang táº£i (`AppLoadingState`), Lá»—i (`AppErrorState`), Rá»—ng (`PremiumEmptyState`) vÃ  Danh sÃ¡ch dá»¯ liá»‡u (`ListView`).
4. **MÃ´ thá»©c CRUD Ä‘á»“ng bá»™:** 
   - Danh sÃ¡ch âž” Chi tiáº¿t dáº¡ng trang riÃªng cho thÃ´ng tin phá»©c táº¡p.
   - ThÃªm / Sá»­a nhanh âž” Sá»­ dá»¥ng **Bottom Sheet** (`showModalBottomSheet`) thay vÃ¬ Dialog cá»©ng nháº¯c.
   - XÃ³a dá»¯ liá»‡u âž” LuÃ´n yÃªu cáº§u xÃ¡c nháº­n qua há»™p thoáº¡i cáº£nh bÃ¡o `_DeleteConfirmationDialog`.

---

## 2. KIáº¾N TRÃšC MÃƒ NGUá»’N Báº®T BUá»˜C (AGENTS.md)

1. **PhÃ¢n tÃ¡ch View vÃ  Logic:** Lá»›p giao diá»‡n (View - StatefulWidget) chá»‰ Ä‘Æ°á»£c render UI, láº¯ng nghe thÃ´ng tin thay Ä‘á»•i tá»« Presenter. KhÃ´ng Ä‘Æ°á»£c phÃ©p gá»i API client hoáº·c biáº¿n Ä‘á»•i dá»¯ liá»‡u trá»±c tiáº¿p trong View.
2. **Khai bÃ¡o Presenter chuáº©n:**
   ```dart
   late final AdminXPresenter _presenter;

   @override
   void initState() {
     super.initState();
     _presenter = AdminXPresenter(
       repository: AppDependencies.instance.xRepository,
     );
     _presenter.addListener(_onControllerChanged);
     _presenter.loadData();
   }

   @override
   void dispose() {
     _presenter.removeListener(_onControllerChanged);
     _presenter.dispose();
     super.dispose();
   }

   void _onControllerChanged() {
     if (mounted) setState(() {});
   }
   ```
3. **Cáº¥u trÃºc File:** Giá»›i háº¡n file dÆ°á»›i 600 dÃ²ng. Sá»­ dá»¥ng tá»« khÃ³a `part` vÃ  `part of` Ä‘á»ƒ module hÃ³a cÃ¡c sub-widgets nhá» náº±m trong cÃ¹ng thÆ° má»¥c (cÃ¡c widget phá»¥ dáº¡ng private báº¯t Ä‘áº§u vá»›i dáº¥u gáº¡ch dÆ°á»›i `_`).

---

## 3. DESIGN SYSTEM TOKENS

```dart
Primary Color: #2563EB     // Sá»­ dá»¥ng cho cÃ¡c hÃ nh Ä‘á»™ng chÃ­nh (ThÃªm, LÆ°u, XÃ¡c nháº­n)
Success Color: #16A34A     // Tráº¡ng thÃ¡i thÃ nh cÃ´ng, ÄÃ£ phÃª duyá»‡t, Giao thÃ nh cÃ´ng
Danger Color:  #DC2626     // NÃºt tá»« chá»‘i, Há»§y Ä‘Æ¡n, XÃ³a hoáº·c ÄÄƒng xuáº¥t
Warning Color: #F97316     // Tráº¡ng thÃ¡i chá» duyá»‡t, Cáº£nh bÃ¡o tá»“n kho tháº¥p
Background:    #F8FAFC     // Ná»n mÃ n hÃ¬nh ná»n sÃ¡ng
Surface:       #FFFFFF     // Ná»n cÃ¡c tháº» Card
TextPrimary:   #0F172A     // MÃ u chá»¯ tiÃªu Ä‘á» chÃ­nh
TextSecondary: #64748B     // MÃ u chá»¯ phá»¥ táº£
Border:        #E2E8F0     // MÃ u Ä‘Æ°á»ng káº» viá»n phÃ¢n tÃ¡ch
```

---

## 4. DANH SÃCH 20 MÃ€N HÃŒNH & KHá»šP Ná»I API CHI TIáº¾T

### PHÃ‚N Há»† 1: DASHBOARD & REVENUE
#### MÃ n hÃ¬nh 01: Admin Dashboard (`/admin/dashboard`)
*   **API:** `GET /api/admin/reports/dashboard`
*   **DTO Tráº£ vá»:** `DashboardReportResponse` (`totalRevenue`, `totalOrders`, `newUsers`, `pendingOrders`).
*   **UI Layout:** 4 tháº» KPI Ã´ vuÃ´ng bo gÃ³c tinh táº¿, thÃªm section cÃ¡c phÃ­m hÃ nh Ä‘á»™ng nhanh (Quick Actions shortcut).

#### MÃ n hÃ¬nh 02: Doanh thu chi tiáº¿t (`/admin/revenue`)
*   **API:** `GET /api/admin/reports/dashboard?startDate=...&endDate=...`
*   **UI Layout:** Bá»™ lá»c lá»‹ch thá»i gian (Date Picker), 4 tháº» KPI chá»‰ sá»‘ tÃ i chÃ­nh cÆ¡ báº£n.

### PHÃ‚N Há»† 2: Sáº¢N PHáº¨M & Tá»’N KHO (PRODUCTS)
#### MÃ n hÃ¬nh 03: Danh sÃ¡ch sáº£n pháº©m (`/admin/products`)
*   **API:** `GET /api/admin/products`
*   **DTO Tráº£ vá»:** `List<ProductSummaryResponse>` (`id`, `productName`, `categoryName`, `brandName`, `sportName`, `price`, `image_url`).
*   **UI Layout:** Tháº» Card sáº£n pháº©m dá»c kÃ¨m hÃ¬nh áº£nh Ä‘áº¡i diá»‡n, tÃ­ch há»£p bá»™ lá»c nhanh category/brand/sport.

#### MÃ n hÃ¬nh 04: Chi tiáº¿t sáº£n pháº©m (`/admin/products/:id`)
*   **API:** `GET /api/admin/products/{id}`
*   **DTO Tráº£ vá»:** `ProductDetailResponse` (`id`, `productName`, `description`, `categoryName`, `brandName`, `sportName`, máº£ng `variants`).
*   **UI Layout:** TrÃ¬nh chiáº¿u áº£nh sáº£n pháº©m (Slider), thÃ´ng sá»‘ thuá»™c tÃ­nh, tab danh sÃ¡ch cÃ¡c biáº¿n thá»ƒ Size/Color chi tiáº¿t.

#### MÃ n hÃ¬nh 05: Táº¡o má»›i sáº£n pháº©m (`/admin/products/new`)
*   **API:** `POST /api/admin/products`, `POST /api/admin/products/ai-suggest`, `POST /api/admin/products/admin-confirm`
*   **UI Layout:** Dáº¡ng Stepper tá»«ng bÆ°á»›c nháº­p thÃ´ng tin. NÃºt báº¥m "Gá»£i Ã½ phÃ¢n loáº¡i AI" Ä‘á»ƒ tá»± Ä‘iá»n nhanh cÃ¡c danh má»¥c tÆ°Æ¡ng á»©ng.

#### MÃ n hÃ¬nh 06: Quáº£n lÃ½ biáº¿n thá»ƒ & tá»“n kho (`/admin/products/:id/variants`)
*   **API:** CRUD `/api/admin/products/variants` & `PATCH /variants/{vId}/stock?quantity=...`
*   **DTO Tráº£ vá»:** `VariantResponse` (`id`, `sku`, `size`, `color`, `price`, `stockQuantity`, `imageUrls`).
*   **UI Layout:** Danh sÃ¡ch tháº» SKU chi tiáº¿t, cÃ³ nÃºt báº¥m sá»­a nhanh sá»‘ lÆ°á»£ng tá»“n kho (nháº­p hÃ ng nhanh qua Bottom Sheet).

### PHÃ‚N Há»† 3: DANH Má»¤C THÃ™NG Lá»šN (CATALOGS)
#### MÃ n hÃ¬nh 07: ThÆ°Æ¡ng hiá»‡u (`/admin/brands`)
*   **API:** CRUD `/api/brands`
*   **DTO Tráº£ vá»:** `BrandResponse` (`id`, `brandName`, `brandBanner`, `logo`, `description`, `isActive`).
*   **UI Layout:** Danh sÃ¡ch tháº» ngang chá»©a Logo, banner nhá» vÃ  toggle kÃ­ch hoáº¡t active. Add/Edit dÃ¹ng Bottom Sheet.

#### MÃ n hÃ¬nh 08: PhÃ¢n má»¥c sáº£n pháº©m (`/admin/categories`)
*   **API:** CRUD `/api/admin/categories`
*   **DTO Tráº£ vá»:** `CategoryResponse` (`id`, `categoryName`, `description`, `parentId`).
*   **UI Layout:** Dáº¡ng cÃ¢y phÃ¢n táº§ng ExpansionTree lá»“ng nhau. Form chá»n danh má»¥c cha (Parent Category) dáº¡ng Dropdown.

#### MÃ n hÃ¬nh 09: Bá»™ mÃ´n thá»ƒ thao (`/admin/sports`)
*   **API:** CRUD `/api/admin/sports`
*   **DTO Tráº£ vá»:** `SportResponse` (`id`, `sportName`, `description`).
*   **UI Layout:** Tháº» Icon thÃ´ng minh dá»±a theo tÃªn bá»™ mÃ´n (vÃ­ dá»¥: BÃ³ng Ä‘Ã¡ âž” icon bÃ³ng Ä‘Ã¡).

#### MÃ n hÃ¬nh 10: Bá»™ sÆ°u táº­p thiáº¿t káº¿ (`/admin/collections`)
*   **API:** CRUD `/api/collections/admin`
*   **DTO Tráº£ vá»:** `CollectionResponse` (`id`, `name`, `slug`, `description`, `imageUrl`, `type`, `isActive`, `variants`).
*   **UI Layout:** Danh sÃ¡ch bá»™ sÆ°u táº­p dáº¡ng áº£nh rá»™ng, cÃ³ nÃºt Ä‘a lá»±a chá»n SKU liÃªn káº¿t trong Bottom Sheet form.

### PHÃ‚N Há»† 4: Váº¬N ÄÆ N & GIAO HÃ€NG (ORDERS & DELIVERIES)
#### MÃ n hÃ¬nh 11: Danh sÃ¡ch Ä‘Æ¡n hÃ ng (`/admin/orders`)
*   **API:** `GET /api/orders/admin` & `PATCH /api/orders/{id}/status`
*   **DTO Tráº£ vá»:** `OrderResponse` (`id`, `orderDate`, `status`, `deliveryStatus`, `totalAmount`, `paymentMethod`, `recipientName`, `phoneNumber`, `shippingAddress`).
*   **UI Layout:** Order Card hiá»ƒn thá»‹ rÃµ ID Ä‘Æ¡n, tráº¡ng thÃ¡i mÃ u, tÃªn khÃ¡ch hÃ ng vÃ  tá»•ng tiá»n.

#### MÃ n hÃ¬nh 12: Äiá»u há»£p Shipper (`/admin/deliveries`)
*   **API:** CRUD `/api/admin/order-assignments`
*   **DTO Tráº£ vá»:** `OrderAssignmentResponse` (`id`, `orderId`, `staffName`, `assignedAt`, `note`).
*   **UI Layout:** Báº£ng lá»‡nh bÃ n giao, cho phÃ©p click nÃºt chá»n thay Ä‘á»•i ngÆ°á»i phá»¥ trÃ¡ch giao hÃ ng.

#### MÃ n hÃ¬nh 13: BÃ¡o cÃ¡o sá»± cá»‘ váº­n chuyá»ƒn tá»« Shipper (`/admin/delivery-reports`)
*   **API:** `/api/admin/delivery-reports`
*   **DTO Tráº£ vá»:** `DeliveryReportResponse` (`id`, `orderId`, `reportedByName`, `status`, `reason`, `evidenceImageUrl`).
*   **UI Layout:** Xem áº£nh báº±ng chá»©ng sá»± cá»‘ rá»™ng, mÃ´ táº£ bÃ¡o cÃ¡o (KhÃ¡ch khÃ´ng báº¯t mÃ¡y, hoÃ n hÃ ng,...).

### PHÃ‚N Há»† 5: NHÃ‚N SÃ‚N & Lá»ŠCH TRá»°C (HR & OPERATION)
#### MÃ n hÃ¬nh 14: Há»“ sÆ¡ nhÃ¢n viÃªn (`/admin/staff`)
*   **API:** `GET /api/admin/users`
*   **DTO Tráº£ vá»:** `UserSummaryResponse` (`id`, `fullName`, `email`, `role`, `status`, `lastLoginDate`).
*   **UI Layout:** Tháº» Card nhÃ¢n sá»± thÃ´ng tin, cÃ³ nhÃ£n tráº¡ng thÃ¡i vÃ  phÃ¢n quyá»n.

#### MÃ n hÃ¬nh 15: Chi tiáº¿t & KhÃ³a tÃ i khoáº£n nhÃ¢n viÃªn (`/admin/staff/:id`)
*   **API:** `GET/PUT/DELETE` má»¥c `/api/admin/users/{id}`
*   **DTO Tráº£ vá»:** `UserDetailResponse` (+ `lastPasswordChangeDate`, `failedLoginAttempts`, `lockTime`).
*   **UI Layout:** NÃºt hÃ nh Ä‘á»™ng nhanh "KhÃ³a tÃ i khoáº£n" thay vÃ¬ nhÃ£n XÃ³a vÄ©nh viá»…n (do backend sá»­ dá»¥ng cÆ¡ cháº¿ soft delete gÃ¡n status = false).

#### MÃ n hÃ¬nh 16: Ca lÃ m viá»‡c (`/admin/work-shifts`)
*   **API:** CRUD `/api/admin/work-shifts`
*   **DTO Tráº£ vá»:** `WorkShiftResponse` (`id`, `userId`, `fullName`, `shiftDate`, `shiftCode`, `note`).
*   **UI Layout:** Xem Lá»‹ch biá»ƒu phÃ¢n trá»±c tuáº§n. ThÃªm lá»‹ch báº±ng picker ngÃ y vÃ  chá»n CA_SANG/CA_CHIEU.

#### MÃ n hÃ¬nh 17: PhÃª duyá»‡t nghá»‰ phÃ©p (`/api/admin/leave-requests`)
*   **API:** `/api/admin/leave-requests` & `/leave-requests/{id}/decision`
*   **DTO Tráº£ vá»:** `LeaveRequestResponse` (`id`, `fullName`, `startDate`, `days`, `reason`, `status`).
*   **UI Layout:** Tháº» Ä‘Æ¡n phÃ©p xáº¿p chá». NÃºt dáº¡ng mÃ u: Xanh lÃ¡ (Äá»“ng Ã½), Äá» (Tá»« chá»‘i).

### PHÃ‚N Há»† 6: DIá»„N ÄÃ€N TÆ¯ Váº¤N & THAM Sá» (SUPPORT & SYSTEM)
#### MÃ n hÃ¬nh 18: Danh sÃ¡ch chat tÆ° váº¥n (`/admin/chats`)
*   **API:** `GET /api/chat/rooms/admin/me`
*   **DTO Tráº£ vá»:** `ChatRoom` (`id`, `customerName`, `lastMessageAt`, `hasUnread`).
*   **UI Layout:** TrÃ¬nh bÃ y giao diá»‡n danh thoáº¡i chÃ¡t sáº¡ch sáº½, hiá»ƒn thá»‹ bÃ³ng badge nhá» náº¿u cÃ³ tin nháº¯n má»›i chÆ°a Ä‘á»c.

#### MÃ n hÃ¬nh 19: Khung chat chi tiáº¿t (`/admin/chats/:id`)
*   **API:** `/api/chat/rooms/{roomId}/messages`
*   **UI Layout:** Tin nháº¯n xáº¿p xen káº½ TrÃ¡i-Customer vÃ  Pháº£i-Admin, nÃºt Ä‘Ã­nh kÃ¨m gá»­i áº£nh Ä‘áº§y Ä‘á»§.

#### MÃ n hÃ¬nh 20: CÃ i Ä‘áº·t tham sá»‘ há»‡ thá»‘ng (`/admin/settings`)
*   **API:** CRUD `/api/admin/settings`
*   **DTO Tráº£ vá»:** `SystemSettingResponse` (`key`, `value`, `description`).
*   **UI Layout:** Danh sÃ¡ch tham sá»‘ cáº¥u hÃ¬nh tÄ©nh (vÃ­ dá»¥: thá»i gian tá»‘i Ä‘a há»§y Ä‘Æ¡n). GiÃ¡ trá»‹ key dáº¡ng Readonly khi thá»±c hiá»‡n sá»­a Ä‘á»•i giÃ¡ trá»‹ value.

---

## 5. HÆ¯á»šNG DáºªN KIá»‚M TRA CHáº¤T LÆ¯á»¢NG MÃƒ NGUá»’N Cá»¦A HARNESS
Sau khi viáº¿t mÃ£, Code Generator báº¯t buá»™c pháº£i tá»± cháº¡y:
1. Äá»‹nh dáº¡ng mÃ£ nguá»“n chuáº©n: `dart format lib test`
2. Cháº¡y kiá»ƒm tra tÄ©nh vÃ  test suite Ä‘á»ƒ Ä‘áº£m báº£o khÃ´ng lá»—i biÃªn dá»‹ch: `./init.ps1 -Analyze` vÃ  `./init.ps1 -Test`
3. Tuyá»‡t Ä‘á»‘i khÃ´ng Ä‘á»ƒ xáº£y ra hiá»‡n tráº¡ng lá»—i trÃ n khung giao diá»‡n (`RenderFlex overflow`) trÃªn UI Ä‘iá»‡n thoáº¡i.
