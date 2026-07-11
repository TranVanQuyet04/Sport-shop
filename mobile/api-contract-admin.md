# Há»£p Ä‘á»“ng API Quáº£n trá»‹ & Váº­n hÃ nh (Admin & Staff API Contract)

TÃ i liá»‡u nÃ y Ä‘áº·c táº£ chi tiáº¿t toÃ n bá»™ cÃ¡c HTTP API endpoint dÃ nh riÃªng cho vai trÃ² **Quáº£n trá»‹ viÃªn (ADMIN)**, **NhÃ¢n viÃªn cá»­a hÃ ng (SHOP_STAFF)** vÃ  **Giao hÃ ng (SHIPPER)** sá»­ dá»¥ng Ä‘á»ƒ phÃ¡t triá»ƒn á»©ng dá»¥ng di Ä‘á»™ng phÃ­a quáº£n trá»‹.

---

## 1. Cáº¥u hÃ¬nh CÆ¡ sá»Ÿ (Base Config)

*   **Base URL:** `http://localhost:8080/api` (hoáº·c `http://10.0.2.2:8080/api` trÃªn Android Emulator)
*   **Headers báº¯t buá»™c:**
    *   `Content-Type: application/json`
    *   `Authorization: Bearer <Access_Token>`
*   **Quyá»n phÃ¢n vai há»‡ thá»‘ng:**
    *   `ADMIN`: CÃ³ toÃ n bá»™ quyá»n trÃªn má»i Endpoint vÃ  thao tÃ¡c CRUD.
    *   `SHOP_STAFF`: NhÃ¢n viÃªn bÃ¡n hÃ ng. Bá»‹ háº¡n cháº¿ cáº­p nháº­t tráº¡ng thÃ¡i Ä‘Æ¡n (chá»‰ Ä‘Æ°á»£c gÃ¡n tá»›i tráº¡ng thÃ¡i `SHIPPED` - Äang giao) vÃ  cÃ¡c cáº¥u hÃ¬nh há»‡ thá»‘ng cá»‘t lÃµi.
    *   `SHIPPER`: Giao hÃ ng. Chá»‰ cÃ³ quyá»n cáº­p nháº­t tráº¡ng thÃ¡i Ä‘Æ¡n tá»« `SHIPPED` sang `COMPLETED`/`CANCELLED` vÃ  táº¡o bÃ¡o cÃ¡o sá»± cá»‘ váº­n chuyá»ƒn.

---

## 2. Äáº·c táº£ Chi tiáº¿t cÃ¡c API CRUD & Nghiá»‡p vá»¥

### 2.1 Quáº£n lÃ½ Sáº£n pháº©m (Product CRUD)
*   **Tiá»n tá»‘ Ä‘Æ°á»ng dáº«n:** `/api/admin/products`

#### A. TÃ¬m kiáº¿m & Xem danh sÃ¡ch
*   **Method & Endpoint:** `GET` `/api/admin/products`
*   **PhÃ¢n quyá»n tá»‘i thiá»ƒu:** `ADMIN` | `SHOP_STAFF`
*   **Request:** KhÃ´ng cÃ³ Body.
*   **Response (200 OK - `List<ProductSummaryResponse>`):**
    ```json
    [
      {
        "id": 1,
        "productName": "GiÃ y Cháº¡y Bá»™ Nike Air Zoom Pegasus 40",
        "categoryName": "GiÃ y cháº¡y bá»™",
        "brandName": "Nike",
        "sportName": "Cháº¡y bá»™",
        "price": 3100000.0,
        "image_url": "http://localhost:8080/images/nike_pegasus_40.png"
      }
    ]
    ```
    *   *Nghiá»‡p vá»¥ ngáº§m:* Backend tá»± Ä‘á»™ng dÃ² tÃ¬m biáº¿n thá»ƒ (`ProductVariant`) Ä‘áº§u tiÃªn vÃ  tráº£ vá» giÃ¡ tiá»n cÃ¹ng áº£nh Ä‘áº¡i diá»‡n cá»§a biáº¿n thá»ƒ Ä‘Ã³ Ä‘á»ƒ lÃ m thÃ´ng tin hiá»ƒn thá»‹ tÃ³m táº¯t cho giao diá»‡n dáº¡ng lÆ°á»›i.

#### B. Xem chi tiáº¿t thÃ´ng sá»‘ vÃ  cÃ¡c biáº¿n thá»ƒ
*   **Method & Endpoint:** `GET` `/api/admin/products/{id}`
*   **Response (200 OK - `ProductDetailResponse`):**
    ```json
    {
      "id": 1,
      "productName": "GiÃ y Cháº¡y Bá»™ Nike Air Zoom Pegasus 40",
      "description": "GiÃ y thá»ƒ thao Pegasus 40 bá»n bá»‰, Ãªm Ã¡i.",
      "categoryName": "GiÃ y cháº¡y bá»™",
      "brandName": "Nike",
      "sportName": "Cháº¡y bá»™",
      "variants": [
        {
          "id": 101,
          "sku": "NIKE-PEGA-40-BLU-42",
          "size": "42",
          "color": "Blue",
          "price": 3100000.0,
          "stockQuantity": 20,
          "imageUrls": [
            "http://localhost:8080/images/nike_pegasus_40_blue_1.png"
          ]
        }
      ]
    }
    ```

#### C. ThÃªm má»›i sáº£n pháº©m thá»§ cÃ´ng
*   **Method & Endpoint:** `POST` `/api/admin/products`
*   **Request Body (`ProductRequest`):**
    ```json
    {
      "productName": "GiÃ y Nike Vaporfly 3",
      "description": "GiÃ y cháº¡y Ä‘ua cao cáº¥p.",
      "categoryName": "GiÃ y cháº¡y",
      "brandName": "Nike",
      "sportName": "Cháº¡y bá»™",
      "variants": [
        {
          "size": "41",
          "color": "Pink",
          "price": 6500000.0,
          "stockQuantity": 10,
          "imageUrls": ["https://.../vaporfly_pink.png"]
        }
      ]
    }
    ```
    *   *RÃ ng buá»™c nghiá»‡p vá»¥:* `categoryName`, `brandName` vÃ  `sportName` pháº£i tá»“n táº¡i trong cÆ¡ sá»Ÿ dá»¯ liá»‡u. Náº¿u khÃ´ng, nÃ©m lá»—i há»‡ thá»‘ng `NoSuchElementException` (VÃ­ dá»¥: *"KhÃ´ng tÃ¬m tháº¥y Brand vá»›i ID: ..."*). Náº¿u gá»­i khuyáº¿t `sku`, backend sáº½ tá»± sinh qua module `SkuGenerator` ghÃ©p chá»¯ hoa khÃ´ng dáº¥u cá»§a tÃªn sáº£n pháº©m, size vÃ  mÃ u sáº¯c.
*   **Response (200 OK):** Tráº£ vá» Ä‘á»‘i tÆ°á»£ng sáº£n pháº©m má»›i Ä‘á»‹nh dáº¡ng `ProductDetailResponse`.

#### D. Chá»‰nh sá»­a sáº£n pháº©m
*   **Method & Endpoint:** `PUT` `/api/admin/products/{id}`
*   **Request:** Cáº¥u trÃºc JSON tÆ°Æ¡ng Ä‘Æ°Æ¡ng `ProductRequest`.
*   **Response (200 OK):** Tráº£ vá» cáº¥u trÃºc `ProductSummaryResponse`.

#### E. XÃ³a sáº£n pháº©m
*   **Method & Endpoint:** `DELETE` `/api/admin/products/{id}`
*   **Response:** `204 No Content` (XÃ³a thÃ nh cÃ´ng, tá»± Ä‘á»™ng xÃ³a cÃ¡c biáº¿n thá»ƒ vÃ  liÃªn káº¿t áº£nh Ä‘Ã­nh kÃ¨m).

---

### 2.2 Quáº£n lÃ½ Biáº¿n thá»ƒ & Sá»‘ lÆ°á»£ng tá»“n kho (Variant & Stock Control)

#### A. ThÃªm biáº¿n thá»ƒ cho sáº£n pháº©m sáºµn cÃ³
*   **Method & Endpoint:** `POST` `/api/admin/products/{productId}/variants`
*   **Request Body (`VariantRequest`):**
    ```json
    {
      "size": "42.5",
      "color": "Green",
      "price": 6500000.0,
      "stockQuantity": 15,
      "imageUrls": ["https://.../green_var.png"]
    }
    ```
*   **Response (200 OK - `VariantResponse`):**
    ```json
    {
      "id": 102,
      "sku": "NIKE-VAPORFLY-GREEN-425",
      "size": "42.5",
      "color": "Green",
      "price": 6500000.0,
      "stockQuantity": 15,
      "imageUrls": ["https://.../green_var.png"]
    }
    ```

#### B. Sá»­a biáº¿n thá»ƒ
*   **Method & Endpoint:** `PUT` `/api/admin/products/variants/{variantId}`
*   **Request:** Cáº¥u trÃºc JSON tÆ°Æ¡ng Ä‘Æ°Æ¡ng `VariantRequest`.
*   **Response:** Tráº£ vá» Ä‘á»‘i tÆ°á»£ng `VariantResponse` Ä‘Ã£ sá»­a.

#### C. Cáº­p nháº­t sá»‘ lÆ°á»£ng tá»“n kho (Nháº­p hÃ ng nhanh)
*   **Method & Endpoint:** `PATCH` `/api/admin/products/variants/{variantId}/stock`
*   **Query Parameters:** `quantity` (Integer - lÆ°á»£ng tá»“n má»›i thay tháº¿).
*   **Response:** `204 No Content`.

#### D. XÃ³a biáº¿n thá»ƒ
*   **Method & Endpoint:** `DELETE` `/api/admin/products/variants/{variantId}`
*   **Response:** `204 No Content`.

---

### 2.3 PhÃ¢n há»‡ TrÃ­ tuá»‡ NhÃ¢n táº¡o AI (AI suggestions)

#### A. Gá»£i Ã½ phÃ¢n loáº¡i tá»± Ä‘á»™ng tá»« vÄƒn báº£n
*   **Method & Endpoint:** `POST` `/api/admin/products/ai-suggest`
*   **Request Body:**
    ```json
    {
      "productName": "GiÃ y Ä‘Ã¡ bÃ³ng Adidas Predator Elite FG",
      "description": "GiÃ y Ä‘Ã¡ banh chuyÃªn dÃ nh cho sÃ¢n cá» tá»± nhiÃªn, kiá»ƒm soÃ¡t bÃ³ng tá»‘i Æ°u."
    }
    ```
*   **Response (200 OK - `AIClassificationResult`):**
    ```json
    {
      "category": "GiÃ y Ä‘Ã¡ bÃ³ng",
      "brand": "Adidas",
      "sport": "BÃ³ng Ä‘Ã¡"
    }
    ```

#### B. XÃ¡c nháº­n lÆ°u sáº£n pháº©m gá»£i Ã½
*   **Method & Endpoint:** `POST` `/api/admin/products/admin-confirm`
*   **Request Body:** Tráº£ lÃªn cáº¥u trÃºc hoÃ n chá»‰nh `ProductRequest` (CÃ³ thá»ƒ láº¥y tá»« gá»£i Ã½ cá»§a AI á»Ÿ BÆ°á»›c A lÃ m giÃ¡ trá»‹ máº·c Ä‘á»‹nh cho form chá»‰nh sá»­a).
*   **Response (200 OK):** Tráº£ vá» Ä‘á»‘i tÆ°á»£ng lÆ°u thÃ nh cÃ´ng dáº¡ng `ProductDetailResponse`.

---

### 2.4 Quáº£n lÃ½ Bá»™ sÆ°u táº­p (Collections CRUD)
*   **Tiá»n tá»‘ Ä‘Æ°á»ng dáº«n:** `/api/collections/admin`

#### A. Táº¡o bá»™ sÆ°u táº­p
*   **Method & Endpoint:** `POST` `/api/collections/admin`
*   **Request Body (`CollectionRequest`):**
    ```json
    {
      "name": "Bá»™ sÆ°u táº­p HÃ¨ SÃ´i Äá»™ng",
      "slug": "bo-suu-tap-he-soi-dong",
      "description": "CÃ¡c sáº£n pháº©m chá»‘ng tháº¥m má»“ hÃ´i cho mÃ¹a hÃ¨ nÄƒng Ä‘á»™ng.",
      "imageUrl": "http://.../summer_campaign.jpg",
      "type": "SEASONAL",
      "isActive": true,
      "startDate": "2026-06-01",
      "endDate": "2026-08-31",
      "variantIds": [101, 102]
    }
    ```
    *   *Logic nghiá»‡p vá»¥:* Service sáº½ tÃ¬m cÃ¡c biáº¿n thá»ƒ theo danh má»¥c truyá»n lÃªn. Náº¿u cÃ³ mÃ£ Variant ID khÃ´ng tá»“n táº¡i âž” BÃ¡o lá»—i `Variant not found`.
*   **Response (200 OK - `CollectionResponse`):**
    ```json
    {
      "id": 1,
      "name": "Bá»™ sÆ°u táº­p HÃ¨ SÃ´i Äá»™ng",
      "slug": "bo-suu-tap-he-soi-dong",
      "description": "CÃ¡c sáº£n pháº©m chá»‘ng tháº¥m má»“ hÃ´i cho mÃ¹a hÃ¨ nÄƒng Ä‘á»™ng.",
      "imageUrl": "http://.../summer_campaign.jpg",
      "type": "SEASONAL",
      "isActive": true,
      "startDate": "2026-06-01",
      "endDate": "2026-08-31",
      "variants": [
        {
          "id": 101,
          "sku": "NIKE-PEGA-40-BLU-42",
          "size": "42",
          "color": "Blue",
          "price": 3100000.0,
          "stockQuantity": 20,
          "imageUrls": ["..."]
        }
      ]
    }
    ```

#### B. Cáº­p nháº­t bá»™ sÆ°u táº­p
*   **Method & Endpoint:** `PUT` `/api/collections/admin/{id}`
*   **Request:** Cáº¥u trÃºc tÆ°Æ¡ng tá»± `CollectionRequest`.
*   **Response:** Tráº£ vá» Ä‘á»‘i tÆ°á»£ng `CollectionResponse` má»›i cáº­p nháº­t.

#### C. XÃ³a bá»™ sÆ°u táº­p
*   **Method & Endpoint:** `DELETE` `/api/collections/admin/{id}`
*   **Response:** `204 No Content`.

---

### 2.5 Danh má»¥c Quáº£n lÃ½ há»‡ thá»‘ng (Brands, Categories, Sports)

#### A. THÆ¯Æ NG HIá»†U (BRANDS)
*   **Xem táº¥t cáº£ hÃ£ng:** `GET` `/api/brands`
    *   *Response (200 OK):*
        ```json
        {
          "data": {
            "brands": [
              {
                "id": 1,
                "brandName": "Nike",
                "brandBanner": "http://...",
                "logo": "http://...",
                "description": "Just do it",
                "slug": "nike",
                "isActive": true
              }
            ],
            "count": 1
          }
        }
        ```
*   **Táº¡o thÆ°Æ¡ng hiá»‡u:** `POST` `/api/brands`
    *   *Request:* `{ "brandName": "Puma", "brandBanner": "...", "logo": "...", "description": "Fast cats" }`
    *   *Response:* `{ "data": BrandResponse }`
*   **Sá»­a thÆ°Æ¡ng hiá»‡u:** `PUT` `/api/brands/{id}` | *Response:* `{ "data": BrandResponse }`
*   **XÃ³a thÆ°Æ¡ng hiá»‡u:** `DELETE` `/api/brands/{id}` | *Response:* `{ "message": "XÃ³a thÃ nh cÃ´ng" }`

#### B. THá»‚ LOáº I / DANH Má»¤C (CATEGORIES)
*   **Xem toÃ n bá»™ danh má»¥c:** `GET` `/api/admin/categories`
    *   *Response (200 OK - `List<CategoryResponse>`):*
        ```json
        [
          {
            "id": 2,
            "categoryName": "Trang phá»¥c tennis",
            "description": "VÃ¡y, nÃ³n, Ã¡o thun polo tennis",
            "parentId": 1
          }
        ]
        ```
*   **Táº¡o danh má»¥c má»›i:** `POST` `/api/admin/categories`
    *   *Request:* `{ "categoryName": "Dá»¥ng cá»¥ báº£o há»™", "description": "Äá»‡m gá»‘i, bÄƒng cá»• tay", "parentId": null }`
    *   *Response:* `CategoryResponse`
*   **Sá»­a danh má»¥c:** `PUT` `/api/admin/categories/{id}` | *Response:* `CategoryResponse`
*   **XÃ³a danh má»¥c:** `DELETE` `/api/admin/categories/{id}` | *Response:* `204 No Content`

#### C. Bá»˜ MÃ”N THá»‚ THAO (SPORTS)
*   **Xem cÃ¡c bá»™ mÃ´n:** `GET` `/api/admin/sports`
    *   *Response (`List<SportResponse>`):*
        ```json
        [
          {
            "id": 1,
            "sportName": "Cháº¡y bá»™",
            "description": "CÃ¡c sáº£n pháº©m phá»¥c vá»¥ Ä‘i bá»™, cháº¡y viá»‡t dÃ£ vÃ  cháº¡y Ä‘ua."
          }
        ]
        ```
*   **Táº¡o bá»™ mÃ´n má»›i:** `POST` `/api/admin/sports` | *Request:* `{ "sportName": "BÃ³ng rá»•", "description": "..." }`
*   **Sá»­a bá»™ mÃ´n:** `PUT` `/api/admin/sports/{id}`
*   **XÃ³a bá»™ mÃ´n:** `DELETE` `/api/admin/sports/{id}`

---

### 2.6 Quáº£n lÃ½ TÃ i khoáº£n & Quyá»n háº¡n (Employees & Roles CRUD)
*   **Tiá»n tá»‘ Ä‘Æ°á»ng dáº«n:** `/api/admin/users`

#### A. Táº¡o tÃ i khoáº£n nhÃ¢n sá»±
*   **Method & Endpoint:** `POST` `/api/admin/users`
*   **Request Body (`UserRequest`):**
    ```json
    {
      "email": "shipper_pro@StrideX.com",
      "fullName": "LÃª VÄƒn Giao HÃ ng",
      "phoneNumber": "0911222333",
      "password": "SecurePassword@123",
      "roleCode": "SHIPPER"
    }
    ```
    *   *Quy chuáº©n Role:* Gá»­i lÃªn dáº¡ng `CUSTOMER` / `STAFF` / `DELIVERY_STAFF`. Backend tá»± Ä‘á»™ng quy Ä‘á»•i thÃ nh `MEMBER` / `SHOP_STAFF` / `SHIPPER`.
*   **Response (201 Created - `UserResponse`):**
    ```json
    {
      "id": 4,
      "email": "shipper_pro@StrideX.com",
      "fullName": "LÃª VÄƒn Giao HÃ ng",
      "phoneNumber": "0911222333",
      "status": true,
      "role": "SHIPPER",
      "roleName": "ROLE_SHIPPER",
      "roleDisplayName": "ROLE_SHIPPER"
    }
    ```

#### B. Xem danh sÃ¡ch nhÃ¢n viÃªn
*   **Method & Endpoint:** `GET` `/api/admin/users`
*   **Response (`List<UserSummaryResponse>`):**
    ```json
    [
      {
        "id": 4,
        "fullName": "LÃª VÄƒn Giao HÃ ng",
        "email": "shipper_pro@StrideX.com",
        "phoneNumber": "0911222333",
        "role": "SHIPPER",
        "roleName": "ROLE_SHIPPER",
        "roleDisplayName": "ROLE_SHIPPER",
        "status": true,
        "lastLoginDate": "2026-07-05T10:00:00"
      }
    ]
    ```

#### C. Xem chi tiáº¿t thÃ´ng sá»‘ báº£o máº­t cá»§a nhÃ¢n viÃªn
*   **Method & Endpoint:** `GET` `/api/admin/users/{id}`
*   **Response (`UserDetailResponse`):** Tráº£ vá» Ä‘áº§y Ä‘á»§ thÃ´ng tin cá»§a `UserSummaryResponse` cá»™ng thÃªm thÃ´ng tin láº§n cuá»‘i Ä‘á»•i máº­t kháº©u `lastPasswordChangeDate` vÃ  sá»‘ láº§n Ä‘Äƒng nháº­p lá»—i liÃªn tá»¥c `failedLoginAttempts`.

#### D. Thay Ä‘á»•i thÃ´ng tin & KhÃ³a tÃ i khoáº£n
*   **Method & Endpoint:** `PUT` `/api/admin/users/{id}`
*   **Request Body (`UserUpdateRequest`):**
    ```json
    {
      "fullName": "LÃª VÄƒn Giao HÃ ng Sá»­a",
      "phoneNumber": "0911222334",
      "roleCode": "SHOP_STAFF",
      "status": false
    }
    ```
    *   *Nghiá»‡p vá»¥ thá»±c thi:* Admin gá»­i `status = false` Ä‘á»ƒ khÃ³a tÃ i khoáº£n nhÃ¢n viÃªn. 
*   **Response:** Tráº£ vá» Ä‘á»‘i tÆ°á»£ng `UserDetailResponse`.

#### E. KhÃ³a tÃ i khoáº£n vÄ©nh viá»…n (XÃ³a má»m)
*   **Method & Endpoint:** `DELETE` `/api/admin/users/{id}`
    *   *Logic nghiá»‡p vá»¥ sÃ¢u:* Set giÃ¡ trá»‹ cá»™t tráº¡ng thÃ¡i cá»§a nhÃ¢n viÃªn thÃ nh `status = false` vÃ  thu há»“i láº­p tá»©c táº¥t cáº£ phiÃªn lÃ m viá»‡c Refresh Token nháº±m cÆ°á»¡ng bá»©c thiáº¿t bá»‹ cá»§a nhÃ¢n viÃªn Ä‘Ã³ pháº£i Ä‘Äƒng xuáº¥t ngay láº­p tá»©c.
*   **Response:** `204 No Content`.

---

### 2.7 Äiá»u phá»‘i giao hÃ ng & Giao váº­n (Order Assignments & Issue Reports)

#### A. PhÃ¢n phá»‘i Ä‘Æ¡n hÃ ng cho Shipper
*   **Method & Endpoint:** `POST` `/api/admin/order-assignments`
*   **Request Body (`OrderAssignmentRequest`):**
    ```json
    {
      "orderId": 5,
      "staffId": 4,
      "note": "KhÃ¡ch hÃ ng yÃªu cáº§u giao trÆ°á»›c 11h"
    }
    ```
*   **Response (200 OK - `OrderAssignmentResponse`):**
    ```json
    {
      "id": 1,
      "orderId": 5,
      "staffId": 4,
      "staffName": "LÃª VÄƒn Giao HÃ ng",
      "staffRole": "SHIPPER",
      "assignedById": 1,
      "assignedAt": "2026-07-05T10:15:00",
      "note": "KhÃ¡ch hÃ ng yÃªu cáº§u giao trÆ°á»›c 11h"
    }
    ```

#### B. Thay Ä‘á»•i phÃ¢n cÃ´ng (Chá»n Shipper dá»± phÃ²ng)
*   **Method & Endpoint:** `PUT` `/api/admin/order-assignments/orders/{orderId}`
*   **Request:** Cáº¥u trÃºc JSON tÆ°Æ¡ng Ä‘Æ°Æ¡ng `OrderAssignmentRequest`.
*   **Response:** Äá»‘i tÆ°á»£ng `OrderAssignmentResponse` Ä‘Ã£ cáº­p nháº­t.

#### C. Xem danh sÃ¡ch bÃ¡o cÃ¡o sá»± cá»‘ váº­n chuyá»ƒn
*   **Method & Endpoint:** `GET` `/api/admin/delivery-reports`
*   **Response (200 OK - `List<DeliveryReportResponse>`):**
    ```json
    [
      {
        "id": 10,
        "orderId": 5,
        "reportedById": 4,
        "reportedByName": "LÃª VÄƒn Giao HÃ ng",
        "status": "FAILED",
        "reason": "KhÃ¡ch hÃ ng khÃ´ng nháº­n Ä‘iá»‡n thoáº¡i quÃ¡ 3 láº§n",
        "note": "Gá»i Ä‘iá»‡n cÃ¡c khung giá»: 9h, 9h30, 10h",
        "evidenceImageUrl": "http://.../evidence_call_failed.png",
        "createdAt": "2026-07-05T10:30:00"
      }
    ]
    ```
    *   *Hiá»‡u á»©ng phá»¥:* Khi shipper táº¡o bÃ¡o cÃ¡o sá»± cá»‘ loáº¡i `FAILED` hoáº·c `RETURNED`, há»‡ thá»‘ng sáº½ tá»± Ä‘á»™ng cáº­p nháº­t tráº¡ng thÃ¡i Ä‘Æ¡n hÃ ng tÆ°Æ¡ng á»©ng sang **`CANCELLED` (ÄÃ£ há»§y)**.

---

### 2.8 PhÃ¢n ca lÃ m viá»‡c vÃ  Nghá»‰ phÃ©p (Scheduling & HR Leave Requests)

#### A. PhÃ¢n ca trá»±c cho nhÃ¢n viÃªn
*   **Method & Endpoint:** `POST` `/api/admin/work-shifts`
*   **Request Body (`WorkShiftRequest`):**
    ```json
    {
      "userId": 3,
      "shiftDate": "2026-07-06",
      "shiftCode": "CA_CHIEU",
      "note": "LÃ m quáº§y tÃ­nh tiá»n chÃ­nh"
    }
    ```
*   **Response (200 OK - `WorkShiftResponse`):**
    ```json
    {
      "id": 8,
      "userId": 3,
      "fullName": "Nguyá»…n VÄƒn Staff",
      "roleName": "SHOP_STAFF",
      "shiftDate": "2026-07-06",
      "shiftCode": "CA_CHIEU",
      "note": "LÃ m quáº§y tÃ­nh tiá»n chÃ­nh",
      "createdAt": "2026-07-05T10:35:00"
    }
    ```

#### B. Sá»­a / XÃ³a ca trá»±c
*   `PUT` `/api/admin/work-shifts/{id}` âž” Sá»­a thÃ´ng sá»‘ ca trá»±c.
*   `DELETE` `/api/admin/work-shifts/{id}` âž” XÃ³a buá»•i trá»±c âž” `204 No Content`.

#### C. Duyá»‡t Ä‘Æ¡n xin nghá»‰ phÃ©p cá»§a nhÃ¢n sá»±
*   **PhÃª duyá»‡t thÃ´ng qua mÃ£ tráº¡ng thÃ¡i:**
    *   `PATCH` `/api/admin/leave-requests/{id}/decision`
    *   *Request Body (`LeaveDecisionRequest`):* `{ "status": "APPROVED" }` hoáº·c `{ "status": "REJECTED" }`
    *   *Response (200 OK - `LeaveRequestResponse`):* Tráº£ vá» chi tiáº¿t Ä‘Æ¡n nghá»‰ phÃ©p kÃ¨m theo tráº¡ng thÃ¡i xÃ©t duyá»‡t cáº­p nháº­t má»›i nháº¥t.

---

### 2.9 CÃ i Ä‘áº·t tham sá»‘ vÃ  Cáº¥u hÃ¬nh Há»‡ thá»‘ng (System Settings Keys)
*   **Tiá»n tá»‘ Ä‘Æ°á»ng dáº«n:** `/api/admin/settings`

#### A. ThÃªm cáº¥u hÃ¬nh tham sá»‘ má»›i
*   **Method & Endpoint:** `POST` `/api/admin/settings`
*   **Query Parameters:** `key=MAPPING_KEY`
*   **Request Body (`SystemSettingRequest`):**
    ```json
    {
      "value": "10",
      "description": "Thá»i gian tá»‘i Ä‘a tÃ­nh báº±ng phÃºt Ä‘á»ƒ khÃ¡ch há»§y Ä‘Æ¡n ká»ƒ tá»« khi Ä‘áº·t"
    }
    ```
*   **Response (200 OK - `SystemSettingResponse`):**
    ```json
    {
      "key": "MAPPING_KEY",
      "value": "10",
      "description": "Thá»i gian tá»‘i Ä‘a tÃ­nh báº±ng phÃºt Ä‘á»ƒ khÃ¡ch há»§y Ä‘Æ¡n ká»ƒ tá»« khi Ä‘áº·t"
    }
    ```

#### B. Thay Ä‘á»•i giÃ¡ trá»‹ cáº¥u hÃ¬nh (Upsert)
*   **Method & Endpoint:** `PUT` `/api/admin/settings/{key}`
*   **Request Body:** Cáº¥u trÃºc tÆ°Æ¡ng tá»± `SystemSettingRequest`.
*   **Response:** Sinh hoáº·c cáº­p nháº­t vÃ  tráº£ vá» `SystemSettingResponse`.

#### C. XÃ³a cáº¥u hÃ¬nh
*   **Method & Endpoint:** `DELETE` `/api/admin/settings/{key}`
*   **Response:** `204 No Content`.
