# Admin Mobile UI - Backend Contract Map

This document maps the current StrideX Admin mobile UI to confirmed backend APIs. Use it before adding, hiding, or redesigning Admin screens.

## Navigation IA

| Bottom nav | Domain | Screens |
| --- | --- | --- |
| Tá»•ng quan | Overview and revenue | Dashboard, Revenue |
| Sáº£n pháº©m | Product catalog and inventory | Products, Add Product, Variants, Categories, Brands, Sports, Collections |
| ÄÆ¡n hÃ ng | Orders and fulfillment | Orders, Delivery Monitoring |
| NhÃ¢n sá»± | Staff, users, roles | Staff, Staff Detail, Users |
| CÃ i Ä‘áº·t | Account, settings, support | Settings, Profile, Change Password, Chat Rooms, Chat Detail |

## Screen To Backend Map

| UI screen | Route | Backend APIs | Status |
| --- | --- | --- | --- |
| Dashboard | `/admin/dashboard` | `GET /api/admin/reports/dashboard` | Mapped |
| Revenue | `/admin/revenue` | `GET /api/admin/reports/dashboard` | Mapped |
| Products | `/admin/products` | `GET/POST /api/admin/products`, product lookup APIs | Mapped |
| Add Product | `/admin/products/new` | `POST /api/admin/products`, `GET /api/admin/sports`, `GET /api/collections`, `PUT /api/collections/admin/{id}` | Mapped |
| Variants / Stock | `/admin/products/{id}/variants` | product variant CRUD and stock patch APIs | Mapped |
| Categories | `/admin/categories` | `GET/POST/PUT/DELETE /api/admin/categories` | Mapped |
| Brands | `/admin/brands` | `GET/POST/PUT/DELETE /api/brands` | Mapped |
| Sports | `/admin/sports` | `GET/POST/PUT/DELETE /api/admin/sports` | Mapped |
| Collections | `/admin/collections` | `GET /api/collections`, `POST/PUT/DELETE /api/collections/admin...` | Mapped |
| Orders | `/admin/orders` | `GET /api/orders/admin`, `PATCH /api/orders/{id}/status`, `PATCH /api/orders/{id}/orderStatus` | Mapped |
| Delivery Monitoring | `/admin/deliveries` | orders plus delivery-report APIs | Mapped |
| Staff | `/admin/staff` | `GET /api/admin/users`, `GET /api/admin/roles` | Mapped |
| Users | `/admin/users` | `GET/POST/PUT/DELETE /api/admin/users`, roles | Mapped |
| Chat Rooms | `/admin/chats` | `GET /api/chat/rooms/admin/me`, `POST /api/chat/rooms` | Mapped |
| Chat Detail | `/admin/chats/{id}` | `GET/POST /api/chat/rooms/{roomId}/messages` | Mapped |
| Settings | `/admin/settings` | `GET/POST/PUT/DELETE /api/admin/settings` | Partially mapped |
| Profile | `/admin/profile` | `GET/PUT /api/user/profile/me` | Mapped |
| Change Password | `/admin/change-password` | `PUT /api/auth/change-pass` | Mapped |

## Product Catalog Rule

Danh má»¥c, ThÆ°Æ¡ng hiá»‡u, MÃ´n thá»ƒ thao, and Bá»™ sÆ°u táº­p are product catalog data. Even when opened from Settings, their bottom navigation active state should be Sáº£n pháº©m.

## Backend Exists, UI Can Be Expanded

| Backend module | Existing APIs | Recommended Admin UI placement |
| --- | --- | --- |
| Order assignments | `/api/admin/order-assignments...` | Fold into Orders or Delivery Monitoring |
| Work shifts | `/api/admin/work-shifts...` | Add as Staff schedule tab |
| Leave requests | `/api/admin/leave-requests...` | Add as Staff approval tab |
| System settings CRUD | `/api/admin/settings...` | Expand Cáº¥u hÃ¬nh Shop from Settings |

## Do Not Expose As Active UI Yet

The backend scan does not currently confirm dedicated support for voucher management, review moderation, banner carousel management, warehouse import receipts, supplier purchase orders, or standalone size/color master data. Keep these hidden, disabled, or marked as coming soon until backend support is added.

## Flutter Pro UI Guardrails

- View must not call APIs directly.
- View talks to Controller, Controller to Repository, Repository to Service.
- Every Admin screen needs loading, empty, error, refresh, and bottom-nav-safe spacing.
- Destructive actions need confirmation.
- Primary actions use clear hierarchy; secondary navigation should not compete with create/save actions.
- Product catalog child screens use bottom nav Sáº£n pháº©m.
- Fulfillment screens use bottom nav ÄÆ¡n hÃ ng.
- Staff/user screens use bottom nav NhÃ¢n sá»±.
- Account/settings/support screens use bottom nav CÃ i Ä‘áº·t.
