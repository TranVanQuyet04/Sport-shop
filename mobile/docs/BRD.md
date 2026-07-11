# BRD - Business Requirements Document  
## Sportswear Shop System – Mobile Application

**Version:** 1.0  
**Date:** 2026-07-04  
**Prepared by:** Project Team  
**Reference Platform:** Supersports.com (Sportswear Retail E-Commerce)  
**Project Repository:** `sportswear-shop-system/mobile`

---

## 1. Executive Summary

This document defines the **Business Requirements** for the **Sportswear Shop System – Mobile Application**, a Flutter-based cross-platform e-commerce app (Android + Web) designed to replicate and modernize the omni-channel retail experience offered by leading sportswear retailers such as [Supersports](https://www.supersports.com). The product allows customers to browse and purchase branded sportswear, footwear, and accessories from their mobile devices, while providing shop administrators and delivery staff with the operational tools they need to run daily business.

---

## 2. Business Objectives

| # | Objective | Success Metric |
|---|-----------|----------------|
| BO-01 | Provide a seamless mobile shopping experience for sportswear products | ≥ 90% task completion rate for core customer flows (browse → checkout) |
| BO-02 | Increase sales conversion by enabling fast, secure online payment | VNPay checkout integration live, COD available |
| BO-03 | Reduce customer service workload by providing AI-powered product recommendations and automated chat | AI Chatbot deflects ≥ 60% of common product queries |
| BO-04 | Empower admins to manage catalog and view financial reports without desktop dependency | 100% of admin catalog CRUD + reporting via mobile |
| BO-05 | Streamline last-mile delivery operations for shipper staff via mobile | Shippers update order statuses in real-time via mobile |
| BO-06 | Establish a scalable, maintainable codebase aligned with Clean Architecture standards | Zero UI-layer API calls; architecture compliance in code review |

---

## 3. Business Scope

### 3.1 In-Scope

- **Customer (MEMBER/GUEST):** Product discovery, cart management, address book, order placement (COD & VNPay), order tracking, AI chatbot, live chat support.
- **Admin:** Full catalog management (products, categories, brands, sports), inventory control, user/staff management, live chat responses, financial dashboard and reporting.
- **Delivery Staff (SHIPPER):** View and filter assigned orders, update delivery statuses (SHIPPING / DELIVERED / CANCELLED).
- **Platform:** Android (primary), Web (secondary for admin/shipper use).
- **Payment:** Cash on Delivery (COD) and VNPay online gateway.
- **AI:** AI-powered chatbot for customer support; AI-assisted product suggestion generator for admins.

### 3.2 Out-of-Scope (v1.0)

- iOS native build
- Third-party courier integration (e.g., GHN, GHTK APIs)
- Loyalty points / rewards system
- Product reviews and star ratings (customer-written)
- Multi-vendor marketplace
- Barcode/QR scanning for in-store inventory
- Push notifications (planned for v1.1 via FCM)

---

## 4. Stakeholders

| Role | Responsibility |
|------|----------------|
| **Project Owner** | Approves scope, priorities, and business rules |
| **Admin** | Operates catalog, inventory, staff, reports, customer chat |
| **Customer (Member)** | Purchases products, manages orders and addresses |
| **Guest (Unauthenticated)** | Browses catalog and chats with AI bot only |
| **Shipper / Delivery Staff** | Manages physical delivery and updates order statuses |
| **Backend Developer** | Exposes REST APIs consumed by the Flutter client |
| **Flutter Developer (AI Agent)** | Builds and maintains the mobile app codebase |

---

## 5. Business Roles & Access Rights

| Feature Area | GUEST | MEMBER | SHIPPER | ADMIN |
|---|:---:|:---:|:---:|:---:|
| View product catalog & details | ✅ | ✅ | ✅ | ✅ |
| Search & filter products | ✅ | ✅ | ✅ | ✅ |
| AI Chatbot | ✅ | ✅ | — | — |
| Cart management | ❌ | ✅ | — | — |
| Address CRUD | ❌ | ✅ | — | — |
| Checkout (COD/VNPay) | ❌ | ✅ | — | — |
| Order history & tracking | ❌ | ✅ | — | — |
| Cancel own order (PENDING) | ❌ | ✅ | — | — |
| Live chat support room | ❌ | ✅ | — | — |
| View & update assigned orders | — | — | ✅ | — |
| Admin catalog & inventory CRUD | — | — | — | ✅ |
| Admin AI product generator | — | — | — | ✅ |
| Admin user/staff management | — | — | — | ✅ |
| Admin live chat responses | — | — | — | ✅ |
| Admin financial dashboard | — | — | — | ✅ |

---

## 6. High-Level Business Requirements

### BR-01: Product Discovery (Inspired by Supersports Catalog)
- The app **MUST** display a curated homepage featuring recommended products, filterable by Sport, Category, and Brand.
- Products **MUST** be displayed with name, image, price range (min–max across variants), category, brand, and sport tags.
- Customers **MUST** be able to search products by keyword in real-time.

### BR-02: Product Detail & Variant Selection
- Each product page **MUST** display a full image gallery, description, and all available variants (size × color combinations).
- Customers **MUST** select a specific variant before adding to cart.
- Out-of-stock variants **MUST** be visually disabled and unselectable.

### BR-03: Shopping Cart
- Cart items **MUST** be linked to a specific `variantId` (size + color).
- Cart **MUST** be preserved across sessions (API-backed).
- Adding the same variant again **MUST** increase quantity rather than duplicate the item.
- Cart quantity changes **MUST** not exceed available `stockQuantity` of the selected variant.

### BR-04: Secure Checkout
- Checkout **MUST** require a valid saved delivery address.
- Supported payment methods: **COD** and **VNPay** (online gateway via secure webview).
- After successful VNPay payment, order status **MUST** automatically transition to `CONFIRMED`.
- An empty cart **MUST NOT** be checkable.

### BR-05: Order Lifecycle Management
- Order status **MUST** follow the defined business state machine:  
  `PENDING → CONFIRMED → SHIPPING → DELIVERED/CANCELLED`
- Customers **MUST** only cancel their own orders while in `PENDING` status.
- Shippers **MUST** be able to update orders in `CONFIRMED/SHIPPING` states.

### BR-06: AI Chatbot & Live Support
- The AI Chatbot **MUST** accept free-text queries and respond with product recommendations or shop information.
- The Live Chat feature **MUST** allow customers to create support rooms and exchange real-time messages with admin staff.

### BR-07: Admin Catalog & Inventory Management
- Admins **MUST** be able to Create, Read, Update, and Delete products along with their variants.
- Stock quantities **MUST** be updatable per variant via a dedicated inventory control action.
- The AI product suggestion feature **MUST** allow admins to generate product templates from a description and optionally save them to the catalog.

### BR-08: Admin Reporting
- Admins **MUST** access a financial dashboard showing total revenue and order counts for any selected date range.

### BR-09: Authentication & Session Security
- All users **MUST** authenticate via email/password.
- Access Tokens **MUST** be refreshed silently when expired; if refresh fails, the session **MUST** be cleared and the user redirected to login.
- Password reset via email **MUST** be supported.

---

## 7. Business Constraints

| Constraint | Details |
|------------|---------|
| **Platform** | Flutter (Dart) – Android + Web only for v1.0 |
| **Backend** | Spring Boot REST API at `localhost:8080/api` or `10.0.2.2:8080/api` (Android emulator) |
| **Payment gateway** | VNPay sandbox (production upgrade pending business registration) |
| **Architecture** | Clean Architecture + MVP (ChangeNotifier Presenter) mandated by AGENTS.md |
| **State Management** | ChangeNotifier (current); Riverpod migration planned (F20) |
| **Token storage** | FlutterSecureStorage (encrypted, device-local) |
| **Language** | Vietnamese UI labels; English identifiers (classes, functions, fields) |
| **File size limit** | Maximum 600 lines per Dart file |

---

## 8. Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| VNPay integration fails in production | Medium | High | Maintain COD as fallback; test with sandbox before go-live |
| AI chatbot gives incorrect product advice | Medium | Medium | Limit AI to product catalog context; fallback to live chat |
| Stock oversell (concurrent orders) | Low | High | Backend validates stock at checkout; app disables OOS variants |
| Token/session security breach | Low | High | FlutterSecureStorage + silent refresh + force re-login on failure |
| Performance degradation with large catalog | Medium | Medium | Implement product caching (F21 – planned) |

---

## 9. Key Performance Indicators (KPI)

| KPI | Target (v1.0 Launch) |
|-----|----------------------|
| App startup to product list visible | < 3 seconds |
| Search results displayed after query | < 1.5 seconds |
| Checkout flow completion time | < 2 minutes (average) |
| Admin product creation (with 2 variants) | < 3 minutes |
| Order status update by shipper | < 30 seconds |

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **Variant** | A specific product configuration defined by Size + Color combination; carries its own price and stock |
| **MEMBER** | Authenticated customer with full shopping privileges |
| **GUEST** | Unauthenticated visitor with read-only access |
| **SHIPPER** | Staff role responsible for physical order delivery |
| **ADMIN** | Super-user with full system management access |
| **COD** | Cash on Delivery – payment collected at delivery |
| **VNPay** | Vietnamese online payment gateway |
| **Presenter** | MVP Presenter layer (ChangeNotifier) controlling View state |
| **AppDependencies** | Singleton Service Locator providing all repositories and services |
