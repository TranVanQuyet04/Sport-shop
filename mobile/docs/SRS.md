# SRS - Software Requirements Specification  
## Sportswear Shop System – Mobile Application

**Version:** 1.0  
**Date:** 2026-07-04  
**References:** BRD.md, FRD.md, api-contract.md, architecture.md, domain-rules.md

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification (SRS) provides a complete and precise description of the software system — the Sportswear Shop Mobile Application — developed in Flutter. It consolidates functional and non-functional requirements, system context, use-case descriptions, interface specifications, and architectural constraints.

### 1.2 Scope
The system is a multi-role Flutter mobile/web e-commerce application for a sportswear retail shop. It serves four types of users: Guests, Members (customers), Shippers, and Admins. The system is backed by a Spring Boot REST API and supports COD and VNPay payment methods.

### 1.3 Definitions, Acronyms, and Abbreviations

| Term | Meaning |
|------|---------|
| SRS | Software Requirements Specification |
| BRD | Business Requirements Document |
| FRD | Functional Requirements Document |
| API | Application Programming Interface |
| COD | Cash on Delivery |
| DI | Dependency Injection |
| MVP | Model-View-Presenter |
| FCM | Firebase Cloud Messaging |
| JWT | JSON Web Token (used as Access/Refresh Token) |
| OOS | Out of Stock |
| VNPay | Vietnamese domestic online payment gateway |

---

## 2. Overall Description

### 2.1 Product Perspective
The mobile app is the **primary customer and operational interface** of the sportswear shop. It communicates with a single Spring Boot backend via a RESTful HTTP API. There is no database or business logic on the client — all state is server-authoritative. Local storage is limited to authentication tokens (FlutterSecureStorage).

### 2.2 Product Functions (Summary)
- User authentication (login, register, password management)
- Product catalog browsing, search, and filtering
- Product detail view with variant selection
- Cart management and order checkout (COD + VNPay)
- Order history and lifecycle tracking
- AI chatbot and live customer support chat
- Admin product/catalog/inventory management
- Admin financial reporting dashboard
- Shipper order management and delivery status updates

### 2.3 User Characteristics

| User Class | Technical Proficiency | Primary Device | Use Frequency |
|---|---|---|---|
| Guest | Low | Android phone | Occasional |
| Member (Customer) | Low–Medium | Android phone | Daily–Weekly |
| Shipper | Low | Android phone | Daily (working hours) |
| Admin | Medium–High | Android / Web browser | Daily |

### 2.4 Operating Environment
- **Primary OS:** Android (API 24+)
- **Secondary:** Web (Chrome, Edge)
- **Backend:** Spring Boot, accessible via local network or production server
- **Flutter SDK:** Latest stable channel
- **Dart:** Null-safe, sound type system

### 2.5 Design and Implementation Constraints
- Architecture: **Clean Architecture + MVP (ChangeNotifier)**
- State management: **ChangeNotifier** (Riverpod migration planned, F20)
- Routing: **GoRouter** with role-based guards
- HTTP client: **Dio**
- Secure storage: **flutter_secure_storage**
- No business logic in View layer
- No UI imports in Model/Service/Repository layers
- Maximum 600 lines per Dart file

---

## 3. Use Cases

### UC-01: Customer Browses and Purchases a Product

**Actor:** Member  
**Precondition:** User is authenticated as MEMBER.  
**Main Flow:**
1. User opens the app → sees the recommended product list.
2. User taps a filter chip (e.g., "Chạy bộ" sport) → list updates.
3. User taps a product card → Product Detail screen opens.
4. User selects Size "42" and Color "Black" → price/stock updates.
5. User taps "Add to Cart" → item added, cart badge increments.
6. User navigates to Cart → adjusts quantity to 2.
7. User taps "Checkout" → selects saved address, selects VNPay.
8. System calls `POST /orders/checkout` then `GET /payment/create_payment/{orderId}`.
9. VNPay WebView opens → user completes payment.
10. System detects callback → shows success screen → order status becomes CONFIRMED.

**Alternate Flow:**
- Step 4a: User selects OOS variant → button stays disabled; no action possible.
- Step 9a: User cancels VNPay → order remains PENDING; user sees cancellation message.

---

### UC-02: Admin Creates a New Product with AI Assistance

**Actor:** Admin  
**Precondition:** Admin authenticated, on Admin Products screen.  
**Main Flow:**
1. Admin taps "Thêm sản phẩm với AI".
2. Admin enters product description text → taps "Gợi ý AI".
3. System calls `POST /admin/products/ai-suggest` → shows suggested category, brand, variants.
4. Admin reviews and edits the suggestion as needed.
5. Admin taps "Xác nhận & Lưu" → system calls `POST /admin/products/admin-confirm`.
6. Product appears in the catalog list.

---

### UC-03: Shipper Completes a Delivery

**Actor:** Shipper  
**Precondition:** Shipper authenticated, order visible in their list (CONFIRMED status).  
**Main Flow:**
1. Shipper sees order #1234 in their list.
2. Shipper taps "Bắt đầu giao hàng" → confirmation dialog appears → taps "Xác nhận".
3. System calls `PATCH /orders/1234/status?status=SHIPPING` → order moves to SHIPPING.
4. Shipper delivers package → taps "Giao thành công" → confirmation dialog.
5. System calls `PATCH /orders/1234/status?status=DELIVERED` → order completed.

**Alternate Flow:**
- Step 4a: Customer unreachable → Shipper taps "Giao thất bại/Hủy" → `status=CANCELLED`.

---

### UC-04: Customer Cancels a Pending Order

**Actor:** Member  
**Precondition:** Order exists with status = `PENDING`.  
**Main Flow:**
1. User navigates to "Đơn hàng của tôi".
2. User taps the PENDING order → sees "Hủy đơn" button.
3. User taps "Hủy đơn" → confirmation dialog appears.
4. User confirms → system calls `PATCH /orders/{orderId}/orderStatus?status=CANCELLED`.
5. Order status updates to CANCELLED on screen.

---

## 4. External Interface Requirements

### 4.1 Backend REST API
- Base URL (Android emulator): `http://10.0.2.2:8080/api`
- Base URL (Web/localhost): `http://localhost:8080/api`
- All authenticated endpoints require: `Authorization: Bearer <accessToken>`
- Responses follow structure: `{ "result": <payload> }` for success, or `{ "message": "...", "code": ... }` for errors.
- Full contract documented in `api-contract.md`.

### 4.2 VNPay Payment Gateway
- The app receives a `paymentUrl` from `GET /payment/create_payment/{orderId}`.
- The URL is opened in a Flutter WebView (in-app browser).
- Success/failure is detected via URL callback pattern.

### 4.3 AI Chat Interface
- AI messages are sent to `POST /chat/send` with full session history.
- Responses are streamed/returned as plain text from the backend AI service.

---

## 5. System Attributes (Quality Requirements)

### 5.1 Performance
| Requirement | Target |
|---|---|
| Product list load time | < 3 seconds on 4G |
| Search results response | < 1.5 seconds |
| Cart update round-trip | < 1 second |
| Checkout flow end-to-end | < 2 minutes |

### 5.2 Availability
- The app shall gracefully handle server unavailability with a "Không thể kết nối máy chủ" banner.
- No screen shall crash (white screen) on network failure.

### 5.3 Security
- Access tokens stored in FlutterSecureStorage (AES-256 encrypted).
- Silent token refresh on 401; force re-login if refresh fails.
- Role-based route guards: unauthorized route access redirects to login.
- No tokens or sensitive data logged via `print()`.

### 5.4 Usability
- All user-facing text in Vietnamese.
- All loading states show a progress indicator.
- Empty states show an illustration + helpful message.
- All destructive actions require a confirmation dialog.

### 5.5 Maintainability
- Clean Architecture layers strictly enforced (no cross-layer imports).
- Maximum file size: 600 lines.
- All code formatted with `dart format lib test`.
- Linter rules from `analysis_options.yaml` respected.

### 5.6 Portability
- Android (primary): API level 24+.
- Web (secondary): modern Chromium-based browsers.
- URL detection logic uses `kIsWeb` Flutter constant.

---

## 6. Logical Database Requirements (Data Entities)

The following entities are consumed from the backend API:

| Entity | Key Fields |
|--------|-----------|
| **User** | id, email, fullName, phoneNumber, role, isBlocked |
| **Product** | id, productName, description, imageUrl, categoryName, brandName, sportName, minPrice, maxPrice |
| **ProductVariant** | id, size, color, price, stockQuantity, imageUrl |
| **CartItem** | id, variantId, quantity, variantDetails |
| **Address** | id, recipientName, phoneNumber, city, district, ward, street, isDefault |
| **Order** | id, createdAt, totalAmount, paymentMethod, status, address, items[] |
| **ChatMessage** | content, sender, timestamp |
| **ChatRoom** | id, customerName, messages[] |
| **Report** | startDate, endDate, totalRevenue, totalOrders, productSales[] |

---

## 7. Non-Functional Constraints Summary

| ID | Category | Requirement |
|----|----------|-------------|
| NF-01 | Security | No raw credentials or tokens in logs |
| NF-02 | Security | FlutterSecureStorage for token persistence |
| NF-03 | Performance | App cold start < 5 seconds |
| NF-04 | Architecture | No UI code in Model/Service/Repository layers |
| NF-05 | Architecture | No hardcoded API URLs (use ApiEndpoints constants) |
| NF-06 | Reliability | All async calls wrapped in try-catch with `errorMessage` fallback |
| NF-07 | Scalability | Dependency injection via AppDependencies (singleton pattern) |
| NF-08 | Maintainability | Files ≤ 600 lines; complex widgets extracted to sub-widgets |
| NF-09 | Localization | Vietnamese user-facing labels; English code identifiers |
| NF-10 | Compatibility | Android API 24+ and modern web browsers |
