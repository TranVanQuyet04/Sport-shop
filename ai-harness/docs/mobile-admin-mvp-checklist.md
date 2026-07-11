# Mobile Admin MVP Checklist

Use this checklist before and after every Admin mobile UI change. The goal is to keep the Admin experience usable, premium, and safe without changing business logic.

## MVP screen contract

- Every Admin screen has a clear page title and a visible primary task.
- Every list screen handles loading, empty, error, and data states.
- Every fixed bottom navigation screen reserves at least 88px bottom padding in scrollable content.
- Every destructive action uses warning color and confirmation or existing safe flow.
- Every form keeps labels readable, inputs rounded, focus states visible, and submit hierarchy clear.
- Every visible Vietnamese UI string must render correctly; mojibake patterns such as `Ã`, `áº`, `Ă`, `ş`, `Ł`, `â„¢` are blockers.
- Every route from Settings points to the correct Admin module and never to a random CRUD form.
- Every Admin button/control must appear in `admin-mobile-button-inventory-latest.md`.
- Icon-only actions should have a tooltip.
- Destructive controls should use warning styling and keep the existing confirmation flow.
- UI polish may improve visual hierarchy, spacing, radius, shadow, label clarity, tooltip, and touch comfort, but must not remove buttons or change business behavior.
- Views do not call API clients directly; they use controllers/repositories through the existing architecture.

## Premium UI contract

- Primary action: blue `#2563EB`, rounded 12-16px, clear icon or text.
- Warning/logout action: red `#DC2626` on pale red background, never blue.
- Cards: white surface, 12-16px radius, soft shadow, enough internal padding.
- Tags/chips: compact, readable, with icon when they describe product metadata.
- Sport items: dynamic icon by sport name, not one generic icon for all rows.
- Typography: title `#0F172A`, supporting text `#64748B`, no accidental all-uppercase labels.

## Navigation MVP

- Dashboard: route `/admin/dashboard`, bottom nav active index 0.
- Orders: route `/admin/orders`, bottom nav active index 1.
- Products: route `/admin/products`, bottom nav active index 2.
- Staff: route `/admin/staff`, bottom nav active index 3.
- Settings: route `/admin/settings`, bottom nav active index 4.
- Sports can be reached either as independent route `/admin/sports` or as Products tab `/admin/products?tab=sports`, but the chosen behavior must be explicit and consistent in the screen map.
- Collections: Settings must route to `AppRoutes.adminCollections`, list must show loading/empty/error/data states, and add/delete actions must keep existing controller flow.
- Chat Rooms: Settings must route to `AppRoutes.adminChatRooms`, list must show loading/empty/error/data states, search must be usable, and each room must navigate to chat detail.

## Retry loop

1. Run `ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1`.
2. Read `ai-harness/state/admin-mobile-ui-audit-latest.md` and `ai-harness/state/admin-mobile-button-inventory-latest.md`.
3. Fix only the reported UI/navigation issue in `mobile/`.
4. Run `dart format lib test` from `mobile/`.
5. Run `./init.ps1 -Analyze` and `./init.ps1 -Test` from `mobile/`.
6. Repeat until the audit and checks pass.
