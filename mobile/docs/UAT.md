# UAT - User Acceptance Test Plan  
## Sportswear Shop System – Mobile Application

**Version:** 1.0  
**Date:** 2026-07-04  
**References:** BRD.md, FRD.md, SRS.md, domain-rules.md

---

## 1. Introduction

This document defines the **User Acceptance Testing (UAT)** plan for the Sportswear Shop Mobile Application. UAT validates that all delivered features meet the business requirements specified in BRD.md and functional requirements in FRD.md before the system is accepted for production deployment.

### 1.1 Test Objectives
- Confirm all customer-facing flows work end-to-end on Android devices.
- Validate admin catalog/inventory/reporting operations are accurate.
- Verify shipper delivery status update flows.
- Confirm cross-cutting behaviors: auth guards, error handling, and session management.

### 1.2 Entry Criteria
- [ ] Backend API is deployed and accessible at test base URL
- [ ] Test user accounts seeded (1× GUEST, 1× MEMBER, 1× SHIPPER, 1× ADMIN)
- [ ] At least 5 products with variants seeded in the catalog
- [ ] Flutter app built and installed on Android test device or emulator

### 1.3 Exit Criteria
- [ ] All Critical (P0) test cases pass
- [ ] All High (P1) test cases pass
- [ ] No regression in previously passing features
- [ ] Sign-off from Project Owner

---

## 2. Test Environment

| Parameter | Value |
|-----------|-------|
| Device | Android phone (API 24+) or Android Studio Emulator |
| Backend | Spring Boot API at `http://10.0.2.2:8080/api` (emulator) |
| Flutter build | Debug or profile build |
| Test users | Seeded via `init.ps1` or manual DB seed |

---

## 3. Test Cases

### 3.1 Authentication

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-AUTH-01 | Valid login as MEMBER | Enter valid email + password → tap Login | Navigates to Customer Home screen | P0 |
| TC-AUTH-02 | Invalid login | Enter wrong password → tap Login | Shows Vietnamese error message; stays on login screen | P0 |
| TC-AUTH-03 | Login as ADMIN | Enter admin credentials | Navigates to Admin Dashboard | P0 |
| TC-AUTH-04 | Login as SHIPPER | Enter shipper credentials | Navigates to Shipper Order List | P0 |
| TC-AUTH-05 | Register new account | Fill all required fields → tap Register | Navigates to Login; success message displayed | P1 |
| TC-AUTH-06 | Register with mismatched passwords | Enter different password/confirm | Inline validation error shown | P1 |
| TC-AUTH-07 | Forgot password flow | Enter email → receive reset link → reset password | Password reset success message shown | P1 |
| TC-AUTH-08 | Logout | Tap Logout from profile/settings | Tokens cleared; navigates to Login | P0 |
| TC-AUTH-09 | GUEST access cart | Tap "Add to Cart" without login | Redirected to Login screen | P0 |
| TC-AUTH-10 | MEMBER access Admin route | Manually navigate to /admin URL | Redirected to Customer Home | P0 |

---

### 3.2 Product Catalog

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-CAT-01 | View product list | Open app as GUEST | Product cards loaded with image, name, price range | P0 |
| TC-CAT-02 | Filter by Sport | Tap "Chạy bộ" chip | Only running products displayed | P1 |
| TC-CAT-03 | Filter by Brand | Tap "Adidas" brand chip | Only Adidas products displayed | P1 |
| TC-CAT-04 | Search by keyword | Type "giày" in search bar | Relevant products appear in real-time | P1 |
| TC-CAT-05 | Empty search results | Type a nonsense keyword | Empty-state shown with helpful message | P1 |
| TC-CAT-06 | View product detail | Tap any product card | Detail screen with gallery, description, variants | P0 |
| TC-CAT-07 | Select OOS variant | Tap a greyed-out variant | No action; variant stays unselected | P0 |
| TC-CAT-08 | Select valid variant | Tap size + color combo | Price and stock count update; "Add to Cart" activates | P0 |

---

### 3.3 Cart

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-CART-01 | Add item to cart | Select variant → tap "Thêm vào giỏ" | Item appears in cart; cart badge increments | P0 |
| TC-CART-02 | Add same variant again | Add same variant a second time | Cart item quantity increases; no duplicate row | P1 |
| TC-CART-03 | Update quantity | Tap + / – in cart | Quantity updates; total price recalculates | P0 |
| TC-CART-04 | Exceed stock limit | Try to set quantity > stockQuantity | Input capped at max stock; warning shown | P1 |
| TC-CART-05 | Remove single item | Swipe/delete one cart item | Item removed; total recalculates | P0 |
| TC-CART-06 | Clear cart | Tap "Xóa tất cả" → confirm | All items removed; empty-state shown | P1 |

---

### 3.4 Checkout & Payment

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-CHK-01 | Checkout with COD | Select saved address + COD → tap "Đặt hàng" | Order created; navigates to success screen | P0 |
| TC-CHK-02 | Checkout with VNPay | Select address + VNPay → tap "Đặt hàng" | VNPay WebView opens | P0 |
| TC-CHK-03 | Complete VNPay payment | Complete payment in WebView | Success screen shown; order in CONFIRMED state | P0 |
| TC-CHK-04 | Cancel VNPay | Open VNPay WebView → go back | Notification shown; order remains PENDING | P1 |
| TC-CHK-05 | Checkout with empty cart | Navigate to checkout with 0 items | "Đặt hàng" button disabled / error shown | P0 |
| TC-CHK-06 | Checkout without address | No address saved → attempt checkout | Prompt to add address; checkout blocked | P0 |

---

### 3.5 Order History & Management

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-ORD-01 | View order list | Navigate to "Đơn hàng của tôi" | List of orders with status badges | P0 |
| TC-ORD-02 | View order detail | Tap an order | Order items, address, timeline shown | P1 |
| TC-ORD-03 | Cancel PENDING order | Tap "Hủy đơn" on PENDING order → confirm | Order status changes to CANCELLED | P0 |
| TC-ORD-04 | Cancel CONFIRMED order | Tap order in CONFIRMED state | "Hủy đơn" button NOT visible | P0 |

---

### 3.6 Chat & Support

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-CHAT-01 | AI Chatbot as GUEST | Open chat → type "giày chạy nào tốt?" | AI responds with product recommendation | P1 |
| TC-CHAT-02 | AI Chatbot shows loading | Send message | Typing indicator visible during response | P2 |
| TC-CHAT-03 | Create live chat room | As MEMBER → tap "Chat với nhân viên" → confirm | Chat room created; input field available | P1 |
| TC-CHAT-04 | Admin responds in chat | As ADMIN → view chat rooms → reply to customer | Customer sees admin reply | P1 |

---

### 3.7 Admin Operations

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-ADM-01 | View all products | Admin → Products tab | Full product list with filter chips | P0 |
| TC-ADM-02 | Create product manually | Tap + → fill form with 1 variant → save | Product appears in list | P0 |
| TC-ADM-03 | Edit product | Tap edit on product → change name → save | Updated name reflected | P1 |
| TC-ADM-04 | Delete product | Tap delete → confirm | Product removed from list | P1 |
| TC-ADM-05 | Update stock | Tap variant → update stock to 0 | Variant shows OOS to customers | P0 |
| TC-ADM-06 | AI product suggestion | Input product description → request AI | Suggestions appear; admin can confirm | P1 |
| TC-ADM-07 | View financial report | Select date range → view dashboard | Revenue, order count, breakdown shown | P1 |
| TC-ADM-08 | Create staff account | User Management → add SHIPPER | New shipper can login successfully | P1 |
| TC-ADM-09 | Block user account | Toggle block on a user | Blocked user cannot login | P2 |

---

### 3.8 Shipper Operations

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-SHP-01 | View assigned orders | Login as SHIPPER | Only eligible orders visible | P0 |
| TC-SHP-02 | Start delivery | Tap "Bắt đầu giao" → confirm | Status updates to SHIPPING | P0 |
| TC-SHP-03 | Complete delivery | Tap "Giao thành công" → confirm | Status updates to DELIVERED | P0 |
| TC-SHP-04 | Failed delivery | Tap "Giao thất bại" → confirm | Status updates to CANCELLED | P0 |
| TC-SHP-05 | Filter orders by status | Select "Đang giao" filter | Only SHIPPING orders shown | P1 |

---

### 3.9 Session & Error Handling

| TC ID | Test Case | Steps | Expected Result | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-SYS-01 | Expired access token | Wait for token to expire → make any request | Silent refresh occurs; request succeeds | P0 |
| TC-SYS-02 | Server unreachable | Turn off backend → open app | Error banner shown; no crash | P0 |
| TC-SYS-03 | Server 500 error | Trigger a known 500 scenario | Vietnamese error message shown | P1 |

---

## 4. Defect Classification

| Severity | Definition | Response Time |
|----------|-----------|---------------|
| **P0 - Critical** | App crashes, data loss, security breach, core flow broken | Fix before release |
| **P1 - High** | Feature not working as specified, significant UX impact | Fix in current sprint |
| **P2 - Medium** | Non-critical feature issue, minor visual defect | Fix in next sprint |
| **P3 - Low** | Cosmetic issue, typo, enhancement request | Backlog |

---

## 5. UAT Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Owner | | | |
| Lead Developer | | | |
| QA Lead | | | |
