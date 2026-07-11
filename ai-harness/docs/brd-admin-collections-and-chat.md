# BRD - Admin Collections And Chat

## 1. Purpose

This BRD defines MVP behavior and UI quality gates for the StrideX Mobile Admin screens:

- Collections management (`/admin/collections`)
- Chat rooms management (`/admin/chats`)

The harness uses this document as product context when auditing, feeding back, and fixing Admin mobile UI.

## 2. Business Goals

- Help Admin organize products into sale seasons, campaigns, featured groups, and sportswear merchandising collections.
- Help Admin monitor customer support conversations and enter the correct chat room quickly.
- Keep both screens clear, mobile-friendly, and consistent with StrideX Premium Admin UI.

## 3. User Roles

- Primary user: `ADMIN`
- Support user: internal staff if the backend route allows it in a future slice.

No role or authorization logic may be changed by a UI-only task.

## 4. Collections MVP

### Functional expectations

- Admin can open Collections from Settings, either as the independent Collections screen or the Products management Collections tab.
- Screen fetches collections through the existing controller/repository/service chain.
- Screen shows loading, empty, error, and populated states.
- Each collection row should show at least:
  - Collection name
  - Type or campaign grouping
  - Variant/product count when available
- Admin can create a collection using the existing dialog/form.
- Admin can delete a collection using the existing delete flow.
- Existing request/response fields must not change.

### UI expectations

- White card/list item surface, rounded corners, comfortable padding.
- Icon communicates collections or campaign grouping.
- Floating Add action is visible and does not overlap bottom navigation.
- Scroll content reserves bottom safe space when a fixed bottom nav is present.

## 5. Chat Rooms MVP

### Functional expectations

- Admin can open Chat Rooms from Settings.
- Screen fetches rooms through the existing ChatController and repository.
- View must not call API directly.
- Screen shows loading, empty, error, and populated states.
- Admin can search/filter rooms locally without changing backend contracts.
- Each chat room row should show at least:
  - Customer name or room identifier
  - Assigned admin/staff status
  - Unread indicator when available
- Tapping a room navigates to the existing chat detail route.

### UI expectations

- Search input is visible at top.
- Rows are easy to tap on mobile.
- Unread state is visually distinct but not noisy.
- Empty state explains what happens when no support conversation exists.
- Content must remain visible above bottom navigation.

## 6. Route Contracts

- Settings -> Collections must navigate to `AppRoutes.adminCollections` or `AppRoutes.adminProducts` with `tab=collections`.
- Settings -> Chat Rooms must navigate to `AppRoutes.adminChatRooms`.
- Chat room tile must navigate to `/admin/chats/{id}` or the equivalent `AppRoutes.adminChatDetail` path.

## 7. Non-Goals

- Do not change backend endpoints.
- Do not change DTOs/models/entities.
- Do not change auth/role logic.
- Do not change chat message protocol.
- Do not add new dependencies.
- Do not introduce mock data into production UI.

## 8. Harness Acceptance

- `Invoke-AdminMobileUiHarness.ps1` passes.
- `dart format lib test` passes.
- `./init.ps1 -Analyze` passes.
- `./init.ps1 -Test` passes.
