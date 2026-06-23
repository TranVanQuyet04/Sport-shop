# 02. Batch Auth Và Public Mobile

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: thiết kế auth screens và các public utility screens cho mobile app.

## Screens

### Login screen
- Web hiện có: `pages/auth/LoginPage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: email/password, show password, loading, error, CTA register/forgot password.

### Register screen
- Web hiện có: `pages/auth/RegisterPage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: full name, email, phone, password, confirm password, validation.

### Forgot password screen
- Web hiện có: `pages/auth/ForgotPasswordPage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: email input, success state, back to login.

### Reset password screen
- Web hiện có: `pages/auth/ResetPasswordPage.tsx`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: new password, confirm password, success/error state.

### Guest chat screen
- Web hiện có: `ChatBubble`
- Trạng thái: Đã có một phần
- Cần Stitch: mobile chat entry, bottom sheet hoặc full screen chat.

### Unauthorized screen
- Trạng thái: Cần tạo mới
- Cần Stitch: thông báo không có quyền, CTA quay về trang phù hợp.

### Not found screen
- Trạng thái: Cần tạo mới
- Cần Stitch: 404 mobile, CTA về Home.

