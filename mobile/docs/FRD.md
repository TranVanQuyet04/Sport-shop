# FRD - Functional Requirements Document  
## Sportswear Shop System – Mobile Application

**Version:** 1.0  
**Date:** 2026-07-04  
**Prepared by:** Project Team  
**Reference:** BRD v1.0, api-contract.md, feature_list.json, domain-rules.md  

---

## 1. Overview

This document describes the **Functional Requirements** for each feature module of the Sportswear Shop mobile app. Requirements are linked to the Business Requirements (BR-XX) defined in `BRD.md` and mapped to implementation features (F-XX) from `feature_list.json`.

---

## 2. Authentication Module (F01)

**Linked BR:** BR-09

### 2.1 Login
| ID | Requirement |
|----|-------------|
| FR-AUTH-01 | The system SHALL provide an email + password login form with real-time validation. |
| FR-AUTH-02 | On success, the system SHALL store `accessToken`, `refreshToken`, `role`, and `email` in FlutterSecureStorage. |
| FR-AUTH-03 | The system SHALL redirect users to their role-specific home screen after login (MEMBER → Customer Home, ADMIN → Admin Dashboard, SHIPPER → Shipper Order List). |
| FR-AUTH-04 | On invalid credentials, the system SHALL display a user-friendly Vietnamese error message. |

### 2.2 Registration
| ID | Requirement |
|----|-------------|
| FR-AUTH-05 | The registration form SHALL collect: `fullName`, `email`, `phoneNumber`, `password`, `confirmPassword`. |
| FR-AUTH-06 | The system SHALL validate that `password` and `confirmPassword` match before submission. |
| FR-AUTH-07 | On successful registration, the system SHALL navigate the user to the Login screen. |

### 2.3 Forgot / Reset Password
| ID | Requirement |
|----|-------------|
| FR-AUTH-08 | The system SHALL accept an email and call `POST /auth/forgot-password` to trigger a reset email. |
| FR-AUTH-09 | The Reset Password screen SHALL accept a verification `token` (from the emailed link), `newPassword`, and `confirmPassword`. |

### 2.4 Change Password (Authenticated)
| ID | Requirement |
|----|-------------|
| FR-AUTH-10 | Authenticated users SHALL be able to change their password by providing `oldPassword`, `newPassword`, and `confirmPassword`. |

### 2.5 Silent Token Refresh & Logout
| ID | Requirement |
|----|-------------|
| FR-AUTH-11 | When the API returns 401, the system SHALL automatically call `POST /auth/refresh` with the stored `refreshToken`. |
| FR-AUTH-12 | If refresh succeeds, the original request SHALL be retried with the new token. |
| FR-AUTH-13 | If refresh fails, the system SHALL clear all stored tokens and redirect to the Login screen. |
| FR-AUTH-14 | The logout action SHALL call `POST /auth/logout` and clear local token storage. |

---

## 3. Product Catalog Module (F02, F03, F04)

**Linked BR:** BR-01, BR-02

### 3.1 Product List / Recommendations
| ID | Requirement |
|----|-------------|
| FR-CAT-01 | The home/catalog screen SHALL display a list of recommended products fetched from `GET /products`. |
| FR-CAT-02 | Each product card SHALL show: product image, name, brand, category/sport tags, and price range (min–max). |
| FR-CAT-03 | The system SHALL support filter chips for `categoryId`, `brandId`, and `sportId` as query parameters. |
| FR-CAT-04 | Products with `stockQuantity == 0` across all variants SHALL be visually marked as out-of-stock. |

### 3.2 Product Search
| ID | Requirement |
|----|-------------|
| FR-CAT-05 | A search bar SHALL be accessible from the catalog screen and filter products in real-time. |
| FR-CAT-06 | Search SHALL match against product name, brand, category, and sport fields. |
| FR-CAT-07 | If no results are found, the system SHALL display an empty-state illustration with a helpful message. |

### 3.3 Product Detail & Variant Selection
| ID | Requirement |
|----|-------------|
| FR-CAT-08 | The product detail screen SHALL display: image gallery (swipeable), full description, all variants grouped by size and color. |
| FR-CAT-09 | The user SHALL select both a Size and Color before the "Add to Cart" button becomes active. |
| FR-CAT-10 | Variant combinations with `stockQuantity == 0` SHALL be shown as disabled (greyed out, unclickable). |
| FR-CAT-11 | The selected variant's price and stock count SHALL be dynamically updated when a variant is chosen. |

---

## 4. Cart Module (F05)

**Linked BR:** BR-03

| ID | Requirement |
|----|-------------|
| FR-CART-01 | The system SHALL call `POST /cart/add` with `{ variantId, quantity }` when a user adds an item. |
| FR-CART-02 | Adding an already-present variant SHALL update its quantity in the cart (not create a duplicate row). |
| FR-CART-03 | The cart screen SHALL display each item with: variant image, name, size/color, unit price, and quantity selector. |
| FR-CART-04 | Quantity updates SHALL call `PUT /cart/items/{itemId}?quantity=X` and allow values from 1 to the variant's `stockQuantity`. |
| FR-CART-05 | Individual items SHALL be removable via `DELETE /cart/items/{itemId}`. |
| FR-CART-06 | The entire cart SHALL be clearable via `DELETE /cart/clear`. |
| FR-CART-07 | The cart total (sum of variant price × quantity) SHALL be displayed and updated in real-time. |
| FR-CART-08 | GUEST users who attempt to add to cart SHALL be redirected to the Login screen with a contextual message. |

---

## 5. Address Book Module (F06)

**Linked BR:** BR-04

| ID | Requirement |
|----|-------------|
| FR-ADDR-01 | Users SHALL be able to view, add, edit, and delete shipping addresses. |
| FR-ADDR-02 | Each address SHALL include: `recipientName`, `phoneNumber`, `city`, `district`, `ward`, `street`. |
| FR-ADDR-03 | Users SHALL be able to set any address as the default via `PATCH /user/addresses/{id}/default`. |
| FR-ADDR-04 | The default address SHALL be pre-selected automatically on the Checkout screen. |

---

## 6. Checkout & Payment Module (F07, F08)

**Linked BR:** BR-04

| ID | Requirement |
|----|-------------|
| FR-CHK-01 | The checkout screen SHALL display the selected address, cart summary, and payment method selector. |
| FR-CHK-02 | The system SHALL prevent checkout if the cart is empty. |
| FR-CHK-03 | Supported payment methods: `COD` and `VNPAY`. |
| FR-CHK-04 | For COD orders, the system SHALL call `POST /orders/checkout` with `{ addressId, paymentMethod: "COD", note }`. |
| FR-CHK-05 | For VNPay orders, the system SHALL first place the order (status `PENDING`), then call `GET /payment/create_payment/{orderId}` to obtain the payment URL. |
| FR-CHK-06 | The VNPay URL SHALL be opened in an in-app WebView. |
| FR-CHK-07 | Upon successful VNPay payment (callback detected), the system SHALL display a success confirmation screen and refresh the order list. |
| FR-CHK-08 | If VNPay payment is cancelled or times out, the order SHALL remain in `PENDING` state and the user SHALL be notified. |
| FR-CHK-09 | An optional `note` field SHALL be provided for delivery instructions. |

---

## 7. Order History & Tracking Module (F09)

**Linked BR:** BR-05

| ID | Requirement |
|----|-------------|
| FR-ORD-01 | The My Orders screen SHALL list all customer orders fetched from `GET /orders`. |
| FR-ORD-02 | Each order card SHALL show: order ID, date, total amount, payment method, and current status badge. |
| FR-ORD-03 | Order statuses SHALL be displayed with color-coded badges: PENDING (orange), CONFIRMED (blue), SHIPPING (purple), DELIVERED (green), CANCELLED (red). |
| FR-ORD-04 | Customer SHALL be able to tap an order to view its full detail (items, address, timeline). |
| FR-ORD-05 | A "Cancel Order" action SHALL be shown only for orders in `PENDING` status; it calls `PATCH /orders/{orderId}/orderStatus?status=CANCELLED`. |
| FR-ORD-06 | The cancel action SHALL require a confirmation dialog before proceeding. |

---

## 8. AI Chatbot & Live Chat Module (F10, F11)

**Linked BR:** BR-06

### 8.1 AI Chatbot
| ID | Requirement |
|----|-------------|
| FR-CHAT-01 | All users (including GUESTs) SHALL be able to access the AI Chatbot. |
| FR-CHAT-02 | The chatbot SHALL send `{ message, history[] }` to `POST /chat/send` and render the response as a new bubble. |
| FR-CHAT-03 | Chat history SHALL be preserved in the current session (in-memory list passed as context). |
| FR-CHAT-04 | A typing/loading indicator SHALL be shown while the AI is processing. |

### 8.2 Live Chat (MEMBER only)
| ID | Requirement |
|----|-------------|
| FR-CHAT-05 | MEMBER users SHALL be able to create a live chat room via `POST /chat/rooms`. |
| FR-CHAT-06 | Chat room messages SHALL be sent via `POST /chat/rooms/{roomId}/messages`. |
| FR-CHAT-07 | The customer SHALL be able to retrieve their chat room via `GET /chat/rooms/me?customerName=X`. |
| FR-CHAT-08 | ADMIN users SHALL see a list of active chat rooms via `GET /chat/rooms/admin/me` and reply to customers. |

---

## 9. Admin: Catalog & Inventory Management (F12, F13, F14)

**Linked BR:** BR-07

### 9.1 Product Management
| ID | Requirement |
|----|-------------|
| FR-ADM-01 | Admin SHALL view all products via `GET /admin/products` with status/category filter tabs. |
| FR-ADM-02 | Admin SHALL create a new product (with at least one variant) via `POST /admin/products`. |
| FR-ADM-03 | Admin SHALL edit product details via `PUT /admin/products/{id}`. |
| FR-ADM-04 | Admin SHALL delete a product via `DELETE /admin/products/{id}` (with confirmation dialog). |
| FR-ADM-05 | Admin SHALL add additional variants to a product via `POST /admin/products/{productId}/variants`. |
| FR-ADM-06 | Admin SHALL update stock quantity of a variant via `PATCH /admin/products/variants/{variantId}/stock?quantity=X`. |

### 9.2 AI Product Suggestion
| ID | Requirement |
|----|-------------|
| FR-ADM-07 | Admin SHALL enter a product description to request AI-generated category, brand, and variant suggestions via `POST /admin/products/ai-suggest`. |
| FR-ADM-08 | Admin SHALL review the suggestion and confirm saving it to the catalog via `POST /admin/products/admin-confirm`. |

### 9.3 Category, Brand & Sport Management
| ID | Requirement |
|----|-------------|
| FR-ADM-09 | Admin SHALL perform full CRUD on product categories (supporting parent-child hierarchy). |
| FR-ADM-10 | Admin SHALL perform full CRUD on brands (with active/inactive toggle). |
| FR-ADM-11 | Admin SHALL perform full CRUD on sports/activity types (with icon association). |

---

## 10. Admin: User & Staff Management (F17)

| ID | Requirement |
|----|-------------|
| FR-ADM-12 | Admin SHALL view all registered users and staff members. |
| FR-ADM-13 | Admin SHALL create new staff accounts (SHIPPER or other staff roles). |
| FR-ADM-14 | Admin SHALL update user details and role assignments. |
| FR-ADM-15 | Admin SHALL block/unblock user accounts on the platform. |

---

## 11. Admin: Financial Dashboard & Reports (F16)

**Linked BR:** BR-08

| ID | Requirement |
|----|-------------|
| FR-ADM-16 | Admin SHALL access a financial report via `GET /admin/reports/dashboard?startDate=X&endDate=Y`. |
| FR-ADM-17 | The dashboard SHALL display: total revenue, total orders, top-selling products, and order status breakdown for the selected date range. |
| FR-ADM-18 | Admin SHALL be able to select custom date ranges via a date picker. |

---

## 12. Delivery Staff (Shipper) Module (F18, F19)

**Linked BR:** BR-05

| ID | Requirement |
|----|-------------|
| FR-SHP-01 | Shipper SHALL see their assigned order list via `GET /orders/admin` (filtered by eligible statuses). |
| FR-SHP-02 | Eligible COD orders SHALL have `PENDING` status; eligible VNPAY orders SHALL have `CONFIRMED`/`PAID` status. |
| FR-SHP-03 | Shipper SHALL mark an order as "Start Delivery" (`SHIPPING`) via `PATCH /orders/{orderId}/status?status=SHIPPING`. |
| FR-SHP-04 | Shipper SHALL mark an order as "Delivered" (`DELIVERED`) via `PATCH /orders/{orderId}/status?status=DELIVERED`. |
| FR-SHP-05 | Shipper SHALL mark an order as "Failed/Cancelled" via `PATCH /orders/{orderId}/status?status=CANCELLED`. |
| FR-SHP-06 | All status updates SHALL require a confirmation dialog. |
| FR-SHP-07 | The order list SHALL support filtering by status (All / SHIPPING / DELIVERED / CANCELLED). |

---

## 13. Cross-Cutting Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-SYS-01 | All HTTP requests to authenticated endpoints SHALL include `Authorization: Bearer {accessToken}`. |
| FR-SYS-02 | All network errors (4xx, 5xx, timeout) SHALL display a user-friendly Vietnamese error message via an in-app banner or toast; the app SHALL NOT crash. |
| FR-SYS-03 | All screens with async data loading SHALL display a loading indicator (spinner or skeleton). |
| FR-SYS-04 | Navigation SHALL be role-gated: GUESTs attempting protected routes SHALL be redirected to Login. |
| FR-SYS-05 | The app SHALL support Android Emulator (`10.0.2.2:8080`) and Web/Localhost (`localhost:8080`) base URL detection via `kIsWeb` flag. |
| FR-SYS-06 | All UI text/labels SHALL be in Vietnamese; code identifiers SHALL remain in English. |
| FR-SYS-07 | `debugPrint` SHALL be used for logging; `print()` is prohibited in production code. |

---

## 14. Feature Status Summary

| Feature ID | Feature Name | Status |
|-----------|-------------|--------|
| F01 | Authentication (Login/Register/Forgot/Reset/Change Password) | ✅ Done |
| F02 | Product Recommendations & Summaries | ✅ Done |
| F03 | Product Detail & Variant Selection | ✅ Done |
| F04 | Search & Filter Catalog | ✅ Done |
| F05 | Cart Management | ✅ Done |
| F06 | Address Book CRUD | ✅ Done |
| F07 | Checkout Order with COD | ✅ Done |
| F08 | Checkout Order with VNPay Online Payment | ✅ Done |
| F09 | Customer Order History & Status Tracking | ✅ Done |
| F10 | AI Support Chatbot | ✅ Done |
| F11 | Live Chat Support Room (Customer side) | ✅ Done |
| F12 | Admin Catalog CRUD (Products/Categories/Brands/Sports) | ✅ Done |
| F13 | Admin Variant & Inventory Control | ✅ Done |
| F14 | Admin AI Product Suggestion Generator | ✅ Done |
| F15 | Admin Chat Support Room Dashboard | ✅ Done |
| F16 | Admin Financial Reports & Metrics | ✅ Done |
| F17 | Admin User & Staff Management | ✅ Done |
| F18 | Shipper Order Lists & Filter | ✅ Done |
| F19 | Shipper Delivery Status Updates | ✅ Done |
| F20 | Advanced Riverpod State Management Migration | 🔲 Pending |
| F21 | Local Storage & Recommended Products Caching | 🔲 Pending |
| F22 | Push Notifications (FCM Integration) | 🔲 Pending |
