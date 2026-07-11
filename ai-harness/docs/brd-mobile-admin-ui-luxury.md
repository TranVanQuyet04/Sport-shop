# BRD - StrideX Mobile Admin UI Luxury

## Objective

Create a premium, sporty, mobile-first Admin experience for StrideX while preserving all backend contracts and business logic.

The harness must help the AI agent:

- Map every Admin UI screen to a backend-supported module.
- Scan every Admin screen for MVP states and interaction coverage.
- Detect visible UI quality risks before the user has to find them manually.
- Apply only safe, mechanical UI fixes automatically.
- Produce a focused report for higher-level luxury UI upgrades.

## Non-Negotiable Constraints

- Do not change backend code from this UI harness.
- Do not change API endpoint paths, request fields, response fields, auth, role logic, pricing, order, payment, inventory, or database behavior.
- Do not call API directly from Flutter View files.
- Do not expose a Mobile Admin feature unless it is supported by `ai-harness/config/backend-feature-map.json`.
- Do not delete buttons just because data is empty. Empty states must explain the data state and keep safe actions available.
- UI auto-fixes must be limited to safe mechanical changes such as bottom padding, obvious route correction, tooltip additions, and text/spacing polishing.

## Target Users

- Admin: manages products, catalog metadata, collections, staff/users, orders, delivery monitoring, chat, dashboard, and settings.
- Shop staff / operational roles: may use subsets of order, delivery, staff, or support flows when allowed by backend.

## Supported Admin Modules

The UI must be mapped to backend-supported modules:

- Dashboard / Reports
- Products
- Product Variants / Inventory
- Categories
- Brands
- Sports
- Collections
- Orders
- Order Assignments
- Delivery Reports
- Users / Staff
- Roles
- Work Shifts
- Leave Requests
- System Settings
- Chat Rooms
- Chat Messages
- Auth / Profile / Change Password

Unsupported ideas must be hidden or marked as coming soon:

- Coupons / vouchers
- Product reviews / ratings
- Banner carousel management
- Standalone notification delivery settings
- Standalone size/color master data
- Warehouse import receipts
- Supplier purchase orders

## Premium Sport UI Principles

### Visual Direction

- Modern, clean, premium, sporty.
- Core palette: white, near-white `#F8FAFC`, dark slate `#0F172A`, slate text `#475569`, muted text `#64748B`, primary blue `#2563EB`.
- Bordeaux/red is reserved for warning, danger, and logout contexts.
- Avoid heavy dark blocks, muddy grays, excessive gradients, and crowded cards.

### Layout

- Mobile-first width, generous spacing, easy thumb targets.
- Fixed bottom navigation must never cover content.
- Scrollable pages with bottom nav need bottom padding around `96-108px`.
- Compact admin dashboards should prioritize scanability over marketing-style hero layouts.
- Search/filter areas should be visible and not clip chips/tabs.

### Components

- Use `AdminSurface`, `AdminOutlinedSurface`, `AdminIconBadge`, `AdminPageHeader`, `AdminInlineBanner`, `PremiumEmptyState`, and shared admin design-system widgets when possible.
- Cards should use consistent radius around `12-16px`, soft shadow, and restrained border.
- Buttons must have hierarchy:
  - Primary: blue filled/gradient.
  - Secondary: outlined or soft surface.
  - Danger/logout: pale red background and `#DC2626`.
- Icon-only buttons need concise tooltips.
- Empty states should include:
  - Specific reason/data state.
  - One safe primary action.
  - Optional secondary refresh action.
  - Visual icon with premium treatment.

## MVP State Requirements Per Screen

Every list-like Admin screen must support:

- Loading state.
- Empty state.
- Error state.
- Refresh or retry action.
- Primary create/manage action if backend supports it.
- Bottom nav spacing if `AdminBottomNav` is present.

Every form-like Admin screen must support:

- Input labels.
- Validation or disabled submit protection.
- Loading/submitting state.
- Back navigation that does not crash when `context.canPop()` is false.
- Safe success/error feedback.

Every detail screen must support:

- Loading/detail state.
- Error or fallback state.
- Back navigation.
- No direct API calls inside View.

## Automated Harness Behavior

The harness should:

1. Read `mobile-admin-screen-map.json`.
2. Read `backend-feature-map.json`.
3. Verify every mapped Admin route exists in Flutter router.
4. Verify every mapped screen file exists.
5. Verify every mapped screen references a backend-supported module.
6. Scan every Admin view for:
   - Mojibake text.
   - Direct API calls in View.
   - Missing bottom padding with bottom navigation.
   - Missing loading/empty/error state.
   - Icon buttons without tooltip.
   - Hardcoded `/admin` route review notes.
   - Known route mismatches in Settings.
   - Known Product tab FAB overlap risks.
7. Generate:
   - `admin-mobile-ui-audit-latest.md/json`
   - `admin-mobile-button-inventory-latest.md/json`
   - `admin-mobile-luxury-review-latest.md/json`
8. With `-ApplySafeFixes`, apply only safe mechanical UI fixes.
9. With `-RunMobileChecks`, run format, analyze, and tests.

## Done Criteria

- Harness audit status is `pass`.
- Flutter analyze passes.
- Flutter test passes.
- Button inventory has no strict blocking findings.
- Luxury review either has no critical notes or notes are acknowledged for manual UI polish.
- User-facing UI does not show backend-unsupported features as real actions.

