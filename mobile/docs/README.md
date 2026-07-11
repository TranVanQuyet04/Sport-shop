# docs/ – Documentation Index  
## Sportswear Shop System – Mobile Application

**Last updated:** 2026-07-04  
**Reference platform:** [Supersports](https://www.supersports.com) (Sportswear Retail E-Commerce)

---

## 📚 Document Library

| Document | File | Description |
|----------|------|-------------|
| **BRD** – Business Requirements Document | [BRD.md](./BRD.md) | Business objectives, scope, stakeholders, business rules, KPIs, and risks |
| **FRD** – Functional Requirements Document | [FRD.md](./FRD.md) | Detailed functional requirements per module (Auth, Catalog, Cart, Checkout, Orders, Chat, Admin, Shipper) |
| **SRS** – Software Requirements Specification | [SRS.md](./SRS.md) | Full system spec: use cases, interface descriptions, quality attributes, data entities |
| **NFR** – Non-Functional Requirements | [NFR.md](./NFR.md) | Performance, security, usability, maintainability, portability, testability requirements |
| **UAT** – User Acceptance Test Plan | [UAT.md](./UAT.md) | Test cases organized by module with priority levels and sign-off table |

---

## 🏗️ Architecture & Developer Docs (Root Level)

| Document | File | Description |
|----------|------|-------------|
| **Architecture** | [architecture.md](../architecture.md) | Clean Architecture layers, MVP pattern, dependency rules, Mermaid diagram |
| **API Contract** | [api-contract.md](../api-contract.md) | Full REST API endpoint specification for all backend calls |
| **Domain Rules** | [domain-rules.md](../domain-rules.md) | Business rules for roles, auth lifecycle, order state machine, cart/inventory |
| **Feature List** | [feature_list.json](../feature_list.json) | JSON registry of all features with status (done/pending) |
| **Progress Log** | [progress.md](../progress.md) | Session-by-session progress notes and pending improvements |
| **Coding Standards** | [AGENTS.md](../AGENTS.md) | Mandatory coding standards for all developers and AI agents |

---

## 🗺️ Documentation Relationships

```
BRD (Business Goals)
 └──► FRD (Functional Requirements per module)
       └──► SRS (Technical specification + Use Cases)
             ├──► NFR (Non-functional constraints)
             └──► UAT (Acceptance test cases)
```

---

## 🛍️ Platform Reference

This system is modeled after the **Supersports** sportswear retail experience, covering:
- Multi-brand product catalog (Nike, Adidas, Puma, Under Armour, etc.)
- Sport-segmented browsing (Running, Football, Basketball, Training, Swimming…)
- Size & color variant selection
- Online payment gateway integration
- Multi-role operations: Customer, Admin, Delivery Staff

---

## 👥 User Roles Quick Reference

| Role | Access Level | Default Route |
|------|-------------|---------------|
| **GUEST** | Catalog browsing + AI chatbot only | `/home` |
| **MEMBER** | Full customer shopping experience | `/home` |
| **SHIPPER** | Delivery order management | `/shipper/orders` |
| **ADMIN** | Full system administration | `/admin/dashboard` |

---

## 📋 Feature Status Overview

| Status | Count | Features |
|--------|-------|---------|
| ✅ Done | 19 | F01–F19 (all core MVP features) |
| 🔲 Pending | 3 | F20 (Riverpod), F21 (Caching), F22 (FCM Push) |
