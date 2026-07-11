# DOMAIN-RULES.md - Quy tắc nghiệp vụ (Domain & Business Rules)

Tài liệu này tổng hợp các quy tắc nghiệp vụ cốt lõi (Business Rules) được áp dụng xuyên suốt trong hệ thống **sportswear-shop-system (mobile)**, giúp định hình hành vi và tính đúng đắn của ứng dụng.

---

## 1. Phân quyền và Vai trò (User Roles & Guards)

Hệ thống hỗ trợ 4 nhóm vai trò người dùng chính với các quyền hạn truy cập được quy định nghiêm ngặt:

1. **Khách vãng lai (GUEST):**
   * Được phép: Xem danh mục sản phẩm, tìm kiếm sản phẩm, xem chi tiết sản phẩm, trò chuyện trực tiếp với AI Chatbot hỗ trợ tự động.
   * Bị chặn: Không được phép thêm sản phẩm vào giỏ hàng, thanh toán, xem thông tin cá nhân, quản lý địa chỉ hay tham gia các phòng chat với nhân viên hỗ trợ. Khi thực hiện các hành động này, ứng dụng sẽ tự động chuyển hướng về trang Đăng nhập (`/login`).
2. **Khách hàng thành viên (MEMBER):**
   * Được phép: Quản lý giỏ hàng cá nhân, thêm/sửa/xóa địa chỉ giao hàng, tiến hành đặt hàng (Checkout), theo dõi trạng thái đơn hàng cá nhân, thanh toán trực tuyến qua cổng VNPay, tạo phòng chat hỗ trợ trực tuyến với nhân viên cửa hàng.
   * Bị chặn: Không được phép truy cập bất kỳ tài nguyên hoặc chức năng nào thuộc phân hệ Admin hoặc Shipper.
3. **Nhân viên giao hàng (SHIPPER / DELIVERY STAFF):**
   * Được phép: Xem danh sách các đơn hàng được bàn giao (lọc tự động theo thuật toán phân phối), cập nhật trạng thái đơn hàng đang giao (`SHIPPING` -> `DELIVERED` hoặc `CANCELLED`).
   * Bị chặn: Không có quyền cấu hình hệ thống, quản lý sản phẩm hoặc xem báo cáo doanh thu của Admin.
4. **Quản trị viên (ADMIN):**
   * Có toàn quyền hạn tối cao trên hệ thống: Quản lý sản phẩm, biến thể, tồn kho, thương hiệu, danh mục, quản lý người dùng & nhân viên, xem báo cáo thống kê tài chính, tham gia phản hồi các phòng chat hỗ trợ khách hàng.

---

## 2. Vòng đời Xác thực & Phiên làm việc (Auth Lifecycle)

1. **Quản lý Token:**
   * Sau khi đăng nhập thành công, `accessToken`, `refreshToken`, `role`, và `email` được lưu trữ an toàn trong `TokenStorage` (sử dụng Secure Storage).
   * Mọi yêu cầu HTTP gửi lên backend sẽ tự động đính kèm header: `Authorization: Bearer <accessToken>`.
2. **Tự động làm mới phiên (Silent Token Refresh):**
   * Khi Access Token hết hạn (máy chủ trả về mã lỗi `401 Unauthorized`), ứng dụng sẽ thực hiện gọi API `/auth/refresh` bằng Refresh Token hiện có dưới nền để lấy cặp token mới.
   * Nếu Refresh thành công, các yêu cầu bị lỗi trước đó sẽ được thử lại với token mới.
   * Nếu Refresh thất bại hoặc Refresh Token cũng hết hạn/không tồn tại, phiên làm việc sẽ bị hủy bỏ, thông tin lưu trữ bị xóa sạch, ứng dụng lập tức chuyển hướng người dùng về màn hình đăng nhập.

---

## 3. Quy tắc Đơn hàng & Giao hàng (Order & Delivery Rules)

### 3.1 Quy trình chuyển đổi trạng thái đơn hàng (Order Status Flow)
Trạng thái của đơn hàng chỉ được phép chuyển dịch theo luồng nghiệp vụ chuẩn sau:

```
[ PENDING ] ──(Xác nhận / Đã thanh toán)──> [ CONFIRMED ]
     │                                            │
     │ (Hủy trước giao)                           │ (Bàn giao cho shipper)
     ▼                                            ▼
[ CANCELLED ]                                [ SHIPPING ]
                                                  │
                            ┌─────────────────────┴─────────────────────┐
                            ▼ (Giao thành công)                         ▼ (Giao thất bại)
                      [ COMPLETED ]                                [ CANCELLED ]
```

* **Quy tắc hủy đơn:**
  * Khách hàng (Member) chỉ được phép tự hủy đơn hàng khi đơn hàng đang ở trạng thái `PENDING`.
  * Khi đơn hàng đã chuyển sang trạng thái `CONFIRMED` hoặc `SHIPPING`, khách hàng không thể tự hủy trên giao diện ứng dụng mà phải thông báo với Admin hoặc Shipper để xử lý.

### 3.2 Quy tắc phân bổ và xử lý đơn của Shipper
* **Điều kiện đơn hàng hiển thị với Shipper:**
  * Đơn hàng có phương thức thanh toán là **COD** (Thanh toán khi nhận hàng) và trạng thái đơn hàng là **PENDING**.
  * Hoặc đơn hàng có phương thức thanh toán trực tuyến (VNPAY) và đã thanh toán thành công (Trạng thái đơn hàng là **PAID** / **CONFIRMED**).
* **Quy trình giao hàng:**
  1. Shipper ấn bắt đầu giao hàng: Trạng thái đơn hàng chuyển sang `SHIPPING` (Đang giao hàng).
  2. Shipper giao hàng thành công: Trạng thái đơn hàng chuyển sang `DELIVERED` / `COMPLETED`. Thu tiền COD nếu đơn hàng áp dụng phương thức COD.
  3. Shipper giao hàng thất bại (khách không nhận, không liên lạc được): Trạng thái đơn hàng chuyển sang `CANCELLED` (Đã hủy).

---

## 4. Giỏ hàng & Tồn kho (Cart & Inventory Rules)

1. **Ràng buộc theo biến thể sản phẩm (Variant Bindings):**
   * Khách hàng không mua một "Sản phẩm" chung chung, họ mua một "Biến thể sản phẩm" cụ thể (kết hợp cụ thể giữa kích cỡ Size, màu sắc Color). Do đó, mọi Item trong giỏ hàng bắt buộc phải gắn với một `variantId` hợp lệ.
2. **Kiểm tra tồn kho (Stock Validation):**
   * Số lượng sản phẩm khách hàng thêm vào giỏ hàng hoặc chọn khi đặt hàng không được phép vượt quá số lượng tồn kho khả dụng (`stockQuantity`) của biến thể đó.
   * Khi Admin cập nhật tồn kho biến thể xuống mức thấp, hệ thống phải cập nhật trực quan trên trang chi tiết sản phẩm và ngăn khách đặt hàng nếu hết hàng (`stockQuantity == 0`).
3. **Tính toán giá trị đơn hàng:**
   * Tổng giá trị giỏ hàng được tính bằng tổng tích số giữa giá bán của biến thể sản phẩm và số lượng tương ứng của từng item trong giỏ.
   * Không cho phép checkout giỏ hàng trống (`quantity == 0` hoặc không có item nào).
