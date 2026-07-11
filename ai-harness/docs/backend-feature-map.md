# Backend Feature Map For Mobile UI

Generated from `backend/src/main/java/com/team6/ecommercesystem/controller`.

Use this file as the source of truth when deciding which Mobile Admin screens should be visible or mapped. If a UI feature is not listed here, keep it hidden, mark it as coming soon, or remove it from Admin navigation until backend support exists.

## Confirmed Admin Modules

| Mobile module | Backend support | Main endpoints | UI mapping note |
| --- | --- | --- | --- |
| Dashboard / Reports | Yes | `GET /api/admin/reports/dashboard` | Keep Admin dashboard statistics. |
| Products | Yes | `GET/POST /api/admin/products`, `GET/PUT/DELETE /api/admin/products/{id}` | Keep product list, detail, create/edit/delete. |
| Product Variants / Inventory | Yes | `POST /api/admin/products/{productId}/variants`, `PUT/DELETE /api/admin/products/variants/{vId}`, `PATCH /api/admin/products/variants/{vId}/stock` | Keep variant and stock screens. |
| AI Product Suggest | Yes | `POST /api/admin/products/ai-suggest`, `POST /api/admin/products/admin-confirm` | Optional Admin helper flow. |
| Categories | Yes | `GET/POST /api/admin/categories`, `GET/PUT/DELETE /api/admin/categories/{id}` | Keep category management. |
| Brands | Yes | `GET /api/brands`, `POST/PUT/DELETE /api/brands` | Keep brand management. Admin mutations require Admin role. |
| Sports | Yes | `GET/POST /api/admin/sports`, `GET/PUT/DELETE /api/admin/sports/{id}` | BRD maps Settings -> `/admin/products?tab=sport`; standalone `AppRoutes.adminSports` may remain as a direct route. |
| Collections | Yes | `GET /api/collections`, `GET /api/collections/{id}`, `GET /api/collections/slug/{slug}`, `POST/PUT/DELETE /api/collections/admin...` | Keep standalone Collection management at `AppRoutes.adminCollections`. Empty state may appear if DB has no data. |
| Orders | Yes | `GET /api/orders/admin`, `GET /api/orders/admin/{id}`, `PATCH /api/orders/{id}/status`, `PATCH /api/orders/{id}/orderStatus`, `DELETE /api/orders/admin/{id}` | Keep Admin/Staff order operations. |
| Order Assignment | Yes | `GET/POST /api/admin/order-assignments`, `GET/PUT/DELETE /api/admin/order-assignments/{id}`, order-specific assignment endpoints | Keep staff/shipper assignment UI if present. |
| Delivery Reports | Yes | `GET /api/admin/delivery-reports`, `GET/POST /api/orders/{orderId}/delivery-reports`, `PUT/DELETE /api/admin/delivery-reports/{id}` | Keep delivery report flow. |
| Users / Staff / Customers | Yes | `GET/POST /api/admin/users`, `GET/PUT/DELETE /api/admin/users/{id}` | Keep user management. |
| Roles | Yes | `GET /api/admin/roles` | Use for role dropdown/display. |
| Work Shifts | Yes | `GET/POST /api/admin/work-shifts`, `GET/PUT/DELETE /api/admin/work-shifts/{id}` | Keep staff schedule UI if present. |
| Leave Requests | Yes | `/api/admin/leave-requests...`, `/api/user/leave-requests...` | Keep leave request UI if present. |
| System Settings | Yes | `GET/POST /api/admin/settings`, `GET/PUT/DELETE /api/admin/settings/{key}` | Keep shop/system config UI. |
| Chat Rooms | Yes | `POST /api/chat/rooms`, `GET /api/chat/rooms/me`, `GET /api/chat/rooms/admin/me` | Keep Admin chat room list. |
| Chat Messages | Yes | `GET/POST /api/chat/rooms/{roomId}/messages` | Keep chat detail/send message UI. |
| Chatbot | Yes | `POST /api/chat/send` | Optional customer support bot feature. |

## Confirmed Customer / Shared Modules

| Mobile module | Backend support | Main endpoints | UI mapping note |
| --- | --- | --- | --- |
| Authentication | Yes | `POST /api/auth/login`, `register`, `logout`, `refresh`, `refresh-token`, `forgot-password`, `reset-password`, `PUT /api/auth/change-pass` | Keep auth and change password screens. |
| Profile | Yes | `GET/PUT /api/user/profile/me` | Admin profile should use this or auth session, not admin user list. |
| Public Product Browse | Yes | `GET /api/products`, `GET /api/products/{id}`, `GET /api/products/brands`, `GET /api/products/categories` | Keep customer product catalog. Supports `categoryId`, `brandId`, `sportId` filters. |
| Navigation | Yes | `GET /api/navigation/main` | Keep dynamic customer navigation if used. |
| Cart | Yes | `GET /api/cart`, `POST /api/cart/add`, `PUT/DELETE /api/cart/items/{itemId}`, `DELETE /api/cart/clear` | Keep cart UI. |
| Checkout / My Orders | Yes | `POST /api/orders/checkout`, `GET /api/orders`, `GET /api/orders/my-orders`, `GET /api/orders/{id}` | Keep checkout and customer order screens. |
| Payment | Yes | `GET /api/payment/create_payment/{orderId}`, `GET /api/payment/vnpay_return` | Keep VNPay/payment flow. |
| Addresses | Yes | `GET/POST /api/user/addresses`, `PUT/DELETE /api/user/addresses/{id}`, `PATCH /api/user/addresses/{id}/default` | Keep address book. |

## Do Not Map Unless Backend Is Added

The current backend scan did not find dedicated controllers for these possible UI ideas:

- Coupon / voucher management.
- Product reviews / ratings management.
- Banner / homepage carousel management.
- Notification settings delivery backend beyond generic system settings.
- Size/color master data management as standalone catalogs. Size/color currently belong to product variants.
- Warehouse import receipts or supplier purchase orders as standalone flows.

If these appear in Mobile Admin UI, hide them, label them as coming soon, or implement backend first.
