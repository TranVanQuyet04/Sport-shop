# API-CONTRACT.md - Tài liệu Đặc tả Hợp đồng API (API Contract)

Tài liệu này đặc tả toàn bộ các HTTP API endpoint mà ứng dụng Flutter (mobile client) sử dụng để giao tiếp với máy chủ backend.

---

## 1. Cấu hình Cơ sở (Base URL)

* **Android Emulator:** `http://10.0.2.2:8080/api`
* **Web / Localhost / Thiết bị thật:** `http://localhost:8080/api` (hoặc IP máy chủ nội bộ)
* **Mặc định Headers:**
  * `Content-Type: application/json`
  * `Authorization: Bearer <Access_Token>` (dành cho các endpoint yêu cầu xác thực)

---

## 2. Danh sách API Endpoints

### 2.1 Nhóm Xác thực & Tài khoản (Authentication)

#### 1. Đăng nhập (Login)
* **Method:** `POST`
* **Endpoint:** `/auth/login`
* **Xác thực:** Public (Không yêu cầu)
* **Request Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
* **Response (Success - 200 OK):**
  ```json
  {
    "accessToken": "eyJhbGciOi...",
    "refreshToken": "eyJhbGciOi...",
    "role": "MEMBER",
    "email": "user@example.com"
  }
  ```

#### 2. Đăng ký (Register)
* **Method:** `POST`
* **Endpoint:** `/auth/register`
* **Xác thực:** Public
* **Request Body:**
  ```json
  {
    "fullName": "Nguyen Van A",
    "email": "user@example.com",
    "phoneNumber": "0987654321",
    "password": "password123",
    "confirmPassword": "password123"
  }
  ```
* **Response (Success - 200 OK / 201 Created):** Không chứa body hoặc chứa thông báo thành công.

#### 3. Làm mới Token (Refresh Token)
* **Method:** `POST`
* **Endpoint:** `/auth/refresh`
* **Xác thực:** Public (Gửi kèm Refresh Token)
* **Request Body:**
  ```json
  {
    "refreshToken": "eyJhbGciOi..."
  }
  ```
* **Response (Success - 200 OK):** Trả về bộ Access/Refresh Token mới.

#### 4. Quên mật khẩu (Forgot Password)
* **Method:** `POST`
* **Endpoint:** `/auth/forgot-password`
* **Xác thực:** Public
* **Request Body:**
  ```json
  {
    "email": "user@example.com"
  }
  ```

#### 5. Đặt lại mật khẩu (Reset Password)
* **Method:** `POST`
* **Endpoint:** `/auth/reset-password`
* **Xác thực:** Public (Gửi kèm token xác minh gửi từ email)
* **Request Body:**
  ```json
  {
    "token": "verification-token-from-email",
    "newPassword": "newSecurePassword123",
    "confirmPassword": "newSecurePassword123"
  }
  ```

#### 6. Đổi mật khẩu (Change Password)
* **Method:** `PUT`
* **Endpoint:** `/auth/change-pass`
* **Xác thực:** Đăng nhập (Bearer Token)
* **Request Body:**
  ```json
  {
    "oldPassword": "oldPassword123",
    "newPassword": "newPassword123",
    "confirmPassword": "newPassword123"
  }
  ```

#### 7. Đăng xuất (Logout)
* **Method:** `POST`
* **Endpoint:** `/auth/logout`
* **Xác thực:** Đăng nhập (Bearer Token)

---

### 2.2 Nhóm Sản phẩm & Cửa hàng (Public & Customer)

#### 1. Lấy danh sách sản phẩm gợi ý (Get Recommended Products)
* **Method:** `GET`
* **Endpoint:** `/products`
* **Xác thực:** Public
* **Query Parameters (Tùy chọn):**
  * `categoryId`: Lọc theo ID danh mục (số)
  * `brandId`: Lọc theo ID thương hiệu (số)
  * `sportId`: Lọc theo ID môn thể thao (số)
* **Response (Success - 200 OK):**
  ```json
  {
    "result": [
      {
        "id": 1,
        "productName": "Giày chạy bộ Adidas UltraBoost",
        "description": "Giày thể thao cao cấp...",
        "imageUrl": "http://...",
        "minPrice": 3500000.0,
        "maxPrice": 3800000.0,
        "categoryName": "Giày chạy bộ",
        "brandName": "Adidas",
        "sportName": "Chạy bộ"
      }
    ]
  }
  ```

#### 2. Chi tiết sản phẩm (Product Detail)
* **Method:** `GET`
* **Endpoint:** `/products/{productId}`
* **Xác thực:** Public
* **Response (Success - 200 OK):**
  ```json
  {
    "result": {
      "id": 1,
      "productName": "Giày chạy bộ Adidas UltraBoost",
      "description": "Mô tả sản phẩm...",
      "categoryName": "Giày chạy bộ",
      "brandName": "Adidas",
      "sportName": "Chạy bộ",
      "variants": [
        {
          "id": "101",
          "size": "42",
          "color": "Black",
          "price": 3500000.0,
          "stockQuantity": 15,
          "imageUrl": "http://..."
        }
      ]
    }
  }
  ```

#### 3. Thương hiệu công khai (Public Brands)
* **Method:** `GET`
* **Endpoint:** `/products/brands`
* **Xác thực:** Public

---

### 2.3 Nhóm Giỏ hàng (Cart)

#### 1. Lấy giỏ hàng cá nhân (Get Cart)
* **Method:** `GET`
* **Endpoint:** `/cart`
* **Xác thực:** Đăng nhập (Bearer Token)
* **Response (200 OK):** Giỏ hàng cùng danh sách sản phẩm đã thêm.

#### 2. Thêm vào giỏ hàng (Add to Cart)
* **Method:** `POST`
* **Endpoint:** `/cart/add`
* **Request Body:**
  ```json
  {
    "variantId": 101,
    "quantity": 2
  }
  ```

#### 3. Cập nhật số lượng item (Update Quantity)
* **Method:** `PUT`
* **Endpoint:** `/cart/items/{itemId}`
* **Query Parameters:** `quantity=3`

#### 4. Xóa một item khỏi giỏ hàng
* **Method:** `DELETE`
* **Endpoint:** `/cart/items/{itemId}`

#### 5. Xóa sạch giỏ hàng
* **Method:** `DELETE`
* **Endpoint:** `/cart/clear`

---

### 2.4 Địa chỉ (Addresses)

* **GET** `/user/addresses`: Lấy danh sách địa chỉ nhận hàng.
* **POST** `/user/addresses`: Thêm địa chỉ mới.
  * Request: `{ recipientName, phoneNumber, city, district, ward, street, isDefault }`
* **PUT** `/user/addresses/{id}`: Cập nhật địa chỉ nhận hàng.
* **DELETE** `/user/addresses/{id}`: Xóa địa chỉ.
* **PATCH** `/user/addresses/{id}/default`: Đặt làm địa chỉ mặc định.

---

### 2.5 Đơn hàng & Thanh toán (Orders & Payments)

#### 1. Đặt hàng (Checkout)
* **Method:** `POST`
* **Endpoint:** `/orders/checkout`
* **Xác thực:** Đăng nhập (MEMBER)
* **Request Body:**
  ```json
  {
    "addressId": 5,
    "paymentMethod": "COD", 
    "note": "Giao giờ hành chính"
  }
  ```
  *(Các phương thức thanh toán hỗ trợ: `COD`, `VNPAY`)*

#### 2. Danh sách đơn hàng cá nhân
* **Method:** `GET`
* **Endpoint:** `/orders` (Lấy đơn hàng cá nhân)

#### 3. Cập nhật trạng thái đơn hàng (Khách hàng hủy)
* **Method:** `PATCH`
* **Endpoint:** `/orders/{orderId}/orderStatus`
* **Query Parameters:** `status=CANCELLED`

#### 4. Tạo URL thanh toán VNPay
* **Method:** `GET`
* **Endpoint:** `/payment/create_payment/{orderId}`
* **Response (Success - 200 OK):**
  ```json
  {
    "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?..."
  }
  ```

---

### 2.6 Nhóm Quản trị viên (Admin Catalog & Reports)

* **GET** `/admin/products`: Lấy toàn bộ sản phẩm của hệ thống.
* **POST** `/admin/products`: Tạo mới sản phẩm (kèm các biến thể).
* **PUT** `/admin/products/{id}`: Sửa đổi thông tin sản phẩm.
* **DELETE** `/admin/products/{id}`: Xóa sản phẩm.
* **POST** `/admin/products/{productId}/variants`: Thêm biến thể cho sản phẩm.
* **PATCH** `/admin/products/variants/{variantId}/stock?quantity=X`: Cập nhật tồn kho biến thể.
* **POST** `/admin/products/ai-suggest`: Nhận gợi ý phân loại và đặc tính sản phẩm từ AI.
* **POST** `/admin/products/admin-confirm`: Xác nhận và lưu trữ sản phẩm được gợi ý từ AI.
* **GET** `/admin/reports/dashboard?startDate=X&endDate=Y`: Báo cáo doanh số và đơn hàng trong khoảng thời gian xác định.

---

### 2.7 Nhóm Giao hàng (Shipper / Delivery Staff)

* **GET** `/orders/admin`: Lấy toàn bộ đơn hàng hệ thống (Shipper gọi để lọc đơn được giao).
* **PATCH** `/orders/{orderId}/status?status=X`: Cập nhật trạng thái đơn hàng (as Admin/Shipper).
  * Các trạng thái cập nhật: `SHIPPING` (bắt đầu giao), `DELIVERED` (giao thành công), `CANCELLED` (giao thất bại/hủy).

---

### 2.8 Nhóm Chatbot & Hỗ trợ (Chat API)

* **POST** `/chat/send`: Nhận tin nhắn và lịch sử trò chuyện để phản hồi tự động qua AI Bot.
  * Request: `{ "message": "Giày chạy bộ nào tốt?", "history": [...] }`
* **POST** `/chat/rooms`: Tạo phòng chat hỗ trợ trực tuyến (`{ "customerName": "..." }`).
* **GET** `/chat/rooms/me?customerName=X`: Lấy phòng chat cá nhân của khách hàng.
* **GET** `/chat/rooms/admin/me`: Quản trị viên lấy danh sách phòng chat đang hoạt động.
* **POST** `/chat/rooms/{roomId}/messages`: Gửi tin nhắn vào phòng chat trực tiếp (`{ "content": "...", "sender": "..." }`).

---

## 3. Bản đồ Mã Trạng thái (HTTP Status Codes)

| Status Code | Ý nghĩa | Ngữ cảnh xảy ra trên Mobile |
| :--- | :--- | :--- |
| **200 OK** | Thành công | Lấy dữ liệu danh sách, thông tin chi tiết thành công. |
| **201 Created** | Tạo mới thành công | Tạo địa chỉ mới, đặt hàng thành công. |
| **400 Bad Request** | Yêu cầu không hợp lệ | Thiếu trường bắt buộc, dữ liệu nhập sai định dạng hoặc xác thực biểu mẫu thất bại ở server. |
| **401 Unauthorized** | Chưa xác thực | Access Token bị hết hạn hoặc không hợp lệ. Mobile sẽ kích hoạt luồng Refresh Token hoặc bắt đăng nhập lại. |
| **403 Forbidden** | Không có quyền | Người dùng vai trò `MEMBER` cố tình truy cập vào các đường dẫn `/admin/...`. |
| **404 Not Found** | Không tìm thấy | Tìm kiếm chi tiết đơn hàng hoặc sản phẩm không tồn tại trong hệ thống. |
| **500 Server Error** | Lỗi máy chủ backend | Máy chủ gặp sự cố xử lý database hoặc logic nội bộ. Hiển thị thông báo "Không thể kết nối máy chủ". |
