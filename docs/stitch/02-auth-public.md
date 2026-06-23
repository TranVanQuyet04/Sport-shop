# 02. Batch Auth Và Public Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: polish auth pages, guest chat, unauthorized page, not found page.

## Auth Pages Đã Có

### Đăng nhập
- Route: `/login`
- File hiện tại: `pages/auth/LoginPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish form, validation, loading, error state, remember/account CTA nếu phù hợp.

### Đăng ký
- Route: `/register`
- File hiện tại: `pages/auth/RegisterPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish form, password rules, confirm password, error state.

### Quên mật khẩu
- Route: `/forgot-password`
- File hiện tại: `pages/auth/ForgotPasswordPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish hướng dẫn, trạng thái gửi email, back-to-login CTA.

### Đặt lại mật khẩu
- Route: `/reset-password`
- File hiện tại: `pages/auth/ResetPasswordPage.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish form mật khẩu mới, xác nhận mật khẩu, success state.

## Public Components Cần Bổ Sung

### Guest chat widget / Chat bubble
- File hiện tại: `components/common/ChatBubble.tsx`
- Trạng thái: Đã có một phần
- Cần Stitch: thiết kế bubble, cửa sổ chat, empty/loading/message states.

### Unauthorized page
- Trạng thái: Cần bổ sung
- Cần Stitch: page riêng khi user không có quyền truy cập.

### Not found page
- Route: `*`
- Hiện tại: inline `Page not found` trong `App.tsx`
- Trạng thái: Cần bổ sung
- Cần Stitch: page 404 riêng, có CTA quay về trang chủ.
