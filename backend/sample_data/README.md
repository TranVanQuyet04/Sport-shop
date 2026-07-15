# 🗄️ Dữ Liệu Mẫu Cho 4 Database - Sport Swear Shop Management (Team 6)

Bộ dữ liệu mẫu (`Sample Data`) được thiết kế hoàn chỉnh, đồng bộ và chân thực cho toàn bộ kiến trúc 4 microservices và cơ sở dữ liệu PostgreSQL trong hệ thống **Sport Swear Shop Management**.

---

## 📁 Cấu Trúc File Dữ Liệu

| File SQL | Database Mục Tiêu | Service Tương Ứng | Mô Tả Dữ Liệu |
| :--- | :--- | :--- | :--- |
| **`01_auth_db.sql`** | `auth_db` | `auth-service` | `roles`, `users`, `user_addresses`, `system_settings`, `valid_refresh_tokens`, `password_reset_token` |
| **`02_product_catalog_db.sql`** | `product_catalog_db` | `product-catalog-service` | `brands`, `categories`, `sports`, `products`, `product_variants`, `product_images`, `collections`, `collection_products` |
| **`03_order_fulfillment_db.sql`** | `order_fulfillment_db` | `order-fulfillment-service` | `carts`, `cart_items`, `orders`, `order_items`, `work_shifts`, `order_assignments`, `leave_requests`, `delivery_reports` |
| **`04_support_chat_db.sql`** | `support_chat_db` | `support-chat-service` | `chat_rooms`, `chat_messages` và bảng đồng bộ tham chiếu sản phẩm |
| **`master_sample_data.sql`** | `Tất cả 4 DBs` | `Toàn bộ hệ thống` | Script tổng hợp chạy liên tiếp 4 file trên (`\connect` tự động) |

---

## 👥 Danh Sách Tài Khoản Mẫu (`auth_db`)

Mật khẩu mặc định cho tất cả tài khoản mẫu là: **`123456`** *(Hash BCrypt đã được chuẩn hóa trong cơ sở dữ liệu)*.

| ID | Họ và Tên | Email | Số Điện Thoại | Vai Trò (Role) | Mô Tả |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **1** | Nguyễn Văn Quản Trị | `admin@sportshop.vn` | `0901234567` | **ADMIN** | Quản trị viên toàn hệ thống |
| **2** | Trần Thị Quản Lý | `manager@sportshop.vn` | `0902345678` | **MANAGER** | Quản lý cửa hàng, phân công công việc |
| **3** | Lê Hoàng Nhân Viên | `staff1@sportshop.vn` | `0903456789` | **STAFF** | Nhân viên kho và chăm sóc đơn hàng |
| **4** | Phạm Minh Giao Hàng | `staff2@sportshop.vn` | `0904567890` | **STAFF** | Nhân viên giao nhận đơn hàng |
| **5** | Đặng Quang Khách | `customer1@sportshop.vn` | `0911223344` | **CUSTOMER** | Khách hàng mua sắm VIP |
| **6** | Hoàng Mai Thảo | `customer2@sportshop.vn` | `0912334455` | **CUSTOMER** | Khách hàng mua sắm thường xuyên |
| **7** | Vũ Đức Anh | `customer3@sportshop.vn` | `0913445566` | **CUSTOMER** | Khách hàng mới đăng ký |

---

## 🚀 Hướng Dẫn Chạy & Nhập Dữ Liệu Mẫu

Bạn có thể nhập dữ liệu vào database theo các cách tự động hoặc thủ công bên dưới:

### Cách 1: Sử Dụng Script Tự Động (Khuyên Dùng)

#### Trên Windows (PowerShell):
Chạy script tự động nạp dữ liệu vào container Docker `sport-swear-shop-postgres`:
```powershell
.\scripts\seed_sample_data.ps1
```
*Hoặc nếu chạy PostgreSQL trực tiếp trên máy host (Local):*
```powershell
.\scripts\seed_sample_data.ps1 -LocalPostgres -Username "postgres" -Password "mật_khẩu_của_bạn"
```

#### Trên Linux / macOS (Bash):
```bash
chmod +x scripts/seed_sample_data.sh
./scripts/seed_sample_data.sh
```

---

### Cách 2: Nhập Thủ Công Qua Docker CLI
Nếu bạn đang chạy hệ thống bằng Docker Compose, mở terminal tại thư mục gốc của project và chạy lần lượt lệnh sau:

```bash
# Nhập dữ liệu cho auth_db
cat backend/sample_data/01_auth_db.sql | docker exec -i sport-swear-shop-postgres psql -U postgres -d auth_db

# Nhập dữ liệu cho product_catalog_db
cat backend/sample_data/02_product_catalog_db.sql | docker exec -i sport-swear-shop-postgres psql -U postgres -d product_catalog_db

# Nhập dữ liệu cho order_fulfillment_db
cat backend/sample_data/03_order_fulfillment_db.sql | docker exec -i sport-swear-shop-postgres psql -U postgres -d order_fulfillment_db

# Nhập dữ liệu cho support_chat_db
cat backend/sample_data/04_support_chat_db.sql | docker exec -i sport-swear-shop-postgres psql -U postgres -d support_chat_db
```

---

### Cách 3: Nhập Thủ Công Qua Công Cụ Quản Lý DB (pgAdmin / DBeaver / Navicat)
1. Kết nối vào máy chủ PostgreSQL (Port mặc định: `5432`).
2. Mở query window tại từng database tương ứng (`auth_db`, `product_catalog_db`, `order_fulfillment_db`, `support_chat_db`).
3. Mở file SQL tương ứng và chạy (`Execute/Run Script`).
4. Tất cả script đều được thiết kế an toàn với từ khóa `CREATE TABLE IF NOT EXISTS`, `ON CONFLICT` và cập nhật lại Sequence ID tự động (`setval`) để đảm bảo không bị lỗi trùng lặp khóa chính khi thêm dữ liệu mới sau này!

---

## 🌟 Đặc Điểm Nổi Bật Của Bộ Dữ Liệu
- **Khớp 100% Entity Models**: Toàn bộ tên bảng, cột, khóa ngoại (`Foreign Key`), Enum (`OrderStatus`, `PaymentMethod`, `ChatRoomType`) khớp chính xác với mã nguồn Java Spring Boot trong từng microservice.
- **Dữ liệu chân thực cho E-commerce Thể Thao**: Bao gồm 6 thương hiệu lớn (*Nike, Adidas, Puma, Under Armour, Yonex, Li-Ning*), các môn thể thao (*Chạy bộ, Bóng đá, Cầu lông, Gym, Bóng rổ*), 12+ sản phẩm chi tiết kèm các biến thể (Màu sắc, Size, Giá, Tồn kho), hình ảnh Unsplash chất lượng cao và bộ sưu tập (`Collections`).
- **Đồng bộ xuyên suốt 4 Database**: Các ID người dùng trong đơn hàng (`orders`), giỏ hàng (`carts`), ca làm việc (`work_shifts`), và phòng chat (`chat_rooms`) đều liên kết logic với ID người dùng thật trong `auth_db` và ID sản phẩm trong `product_catalog_db`.
