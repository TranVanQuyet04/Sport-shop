# AGENTS.md - Quy tắc và Hướng dẫn làm việc dành cho AI Agent

Tài liệu này định nghĩa các quy tắc, tiêu chuẩn lập trình và quy trình làm việc bắt buộc đối với tất cả các AI Agent khi tham gia phát triển dự án Flutter **sportswear-shop-system (mobile)**.

---

## 1. Nguyên tắc cốt lõi (Core Principles)

1. **Tuân thủ Kiến trúc (Architectural Compliance):**
   * Dự án tuân theo mô hình phân lớp kiến trúc rõ ràng (Presentation/View, Presenter, Domain/Model, Repository, Service, Core).
   * Tuyệt đối không viết logic nghiệp vụ (business logic) hoặc gọi API trực tiếp trong lớp giao diện (View).
   * Không bao giờ import các thư viện UI (như `flutter/material.dart`, `flutter/cupertino.dart`) vào các file thuộc lớp Model, Service hoặc Repository.

2. **Quản lý trạng thái (State Management):**
   * Sử dụng `ChangeNotifier` làm Presenter để quản lý trạng thái của View.
   * View (`StatefulWidget`) lắng nghe Presenter thông qua `addListener` và gọi `setState()` hoặc cập nhật giao diện một cách tối ưu.
   * Khi cập nhật Presenter, luôn gọi `notifyListeners()` đúng thời điểm để kích hoạt render lại giao diện.

3. **Cơ chế Tiêm phụ thuộc (Dependency Injection):**
   * Sử dụng registry tập trung `AppDependencies` (`lib/core/di/app_dependencies.dart`) làm Service Locator để lấy các thực thể Service/Repository.
   * Truyền dependencies qua hàm dựng (Constructor Injection) của Presenter thay vì gọi trực tiếp singleton bên trong thân hàm.

4. **An toàn kiểu và Dữ liệu (Null Safety & Type Safety):**
   * Kích hoạt chế độ kiểm tra kiểu nghiêm ngặt. Tránh sử dụng kiểu `dynamic` trừ khi thực sự cần thiết (ví dụ: khi parse JSON thô).
   * Luôn xử lý các trường hợp null từ API trả về một cách an toàn bằng các toán tử như `??`, `?.` hoặc cung cấp giá trị mặc định.

---

## 2. Tiêu chuẩn viết Code (Coding Standards)

### 2.1 Định dạng Code (Formatting)
* Luôn chạy lệnh định dạng code trước khi hoàn thành công việc:
  ```powershell
  dart format lib test
  ```
* Tuân thủ quy tắc linter được định nghĩa trong `analysis_options.yaml`. Không tắt cảnh báo linter bằng các comment `// ignore:...` trừ trường hợp được chỉ định rõ ràng.

### 2.2 Đặt tên (Naming Conventions)
* **Tên file:** Sử dụng kiểu `snake_case` (ví dụ: `login_Presenter.dart`, `product_detail_page.dart`).
* **Tên class:** Sử dụng kiểu `PascalCase` (ví dụ: `LoginPresenter`, `ProductDetailPage`).
* **Hàm và Biến:** Sử dụng kiểu `camelCase` (ví dụ: `loadOrders()`, `isLoading`).
* **Hằng số:** Sử dụng kiểu `camelCase` hoặc `UPPER_CASE` tùy theo ngữ cảnh sử dụng (đối với API Endpoints ưu tiên `camelCase`).

### 2.3 Cấu trúc file
* Giới hạn kích thước file không quá 600 dòng. Nếu file vượt quá kích thước này, hãy chia tách các Widget nhỏ hoặc module hóa mã nguồn.
* Các widget UI phức tạp nên được chia tách thành các sub-widgets nằm trong cùng một file (bắt đầu bằng dấu gạch dưới `_WidgetName` để chỉ dùng nội bộ) hoặc chuyển ra thư mục `widgets/` dùng chung nếu có tính tái sử dụng.

---

## 3. Xử lý Lỗi và Ghi log (Error Handling & Logging)

1. **API Client Exception:**
   * Lớp `ApiClient` (`lib/core/network/api_client.dart`) sẽ tự động bắt các lỗi `DioException` và chuyển đổi thành `ApiException` với thông điệp tiếng Việt thân thiện với người dùng.
2. **Presenter Layer:**
   * Tất cả các hàm gọi API trong Presenter phải được bao bọc trong khối `try-catch`.
   * Bắt lỗi và gán thông điệp lỗi vào thuộc tính `errorMessage` của Presenter, sau đó gọi `notifyListeners()`.
3. **UI Layer:**
   * Hiển thị thông điệp lỗi trực quan trên UI (sử dụng các banner cảnh báo hoặc Toast) thay vì để ứng dụng crash hoặc hiển thị màn hình trắng.
   * Không sử dụng hàm `print()` cho môi trường production. Hãy sử dụng hàm `debugPrint()` hoặc các thư viện ghi log chuyên dụng để tránh rò rỉ thông tin trên thiết bị khách hàng.

---

## 4. Quá trình Commit và Phát triển (Development Workflow)

1. **Kiểm tra trước khi commit:**
   * Đảm bảo ứng dụng được build thành công không lỗi cú pháp.
   * Đảm bảo toàn bộ các bài test trong thư mục `test/` đều vượt qua (`flutter test`).
2. **Quản lý cấu hình môi trường:**
   * Không được hardcode URL môi trường trực tiếp trong code gọi API. Hãy định nghĩa trong `ApiEndpoints` (`lib/core/network/api_endpoints.dart`).
3. **Tương thích đa nền tảng:**
   * Chú ý xử lý khác biệt về URL giữa Android Emulator (`10.0.2.2`) và Web/Localhost (`localhost`) thông qua kiểm tra biến `kIsWeb`.
