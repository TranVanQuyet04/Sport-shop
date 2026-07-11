# StrideX Harness Usage

## Run all available checks

Copy `.env.example` to `.env` once, then keep account, API URL, web URL,
payment, mail, and AI keys there. Harness scripts load `.env` automatically.

```powershell
./ai-harness/scripts/run-checks.ps1
```

## Backend only

```powershell
./ai-harness/scripts/run-checks.ps1 -BackendOnly
```

## Mobile only

```powershell
./ai-harness/scripts/run-checks.ps1 -MobileOnly
```

The mobile check now includes:

- Dart format for `mobile/lib` and `mobile/test`.
- Vietnamese text encoding guard for mobile UI, presenters, tests, and `mobile/init.ps1`.
- SOLID file-size guard with `ai-harness/config/mobile-solid-baseline.json`; existing large files are tracked as debt, while new oversized files or growth beyond baseline fail the run.
- Flutter analyze and Flutter tests.

For a quick local pass without the file-size guard:

```powershell
./ai-harness/scripts/run-checks.ps1 -MobileOnly -SkipSolid
```

## Mobile Admin UI harness

Static audit only:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1 -StrictButtonAudit
```

Audit, apply safe UI fixes, then run mobile format/analyze/test:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1 -StrictButtonAudit -ApplySafeFixes -RunMobileChecks
```

Generated reports:

- `ai-harness/state/admin-mobile-ui-audit-latest.md`
- `ai-harness/state/admin-mobile-button-inventory-latest.md`
- `ai-harness/state/admin-mobile-luxury-review-latest.md`

Design source:

- `ai-harness/docs/brd-mobile-admin-ui-luxury.md`
- `ai-harness/config/mobile-admin-screen-map.json`
- `ai-harness/config/backend-feature-map.json`
- `ai-harness/config/admin-ui-backend-contract-map.json`
- `ai-harness/docs/admin-ui-backend-contract-map.md`
- `ai-harness/config/customer-staff-ui-backend-contract-map.json`
- `ai-harness/docs/customer-staff-ui-backend-contract-map.md`

## Mobile Admin browser smoke test

Run a real browser pass across the main Admin mobile routes:

```powershell
node ai-harness/scripts/admin-ui-browser-smoke.mjs
```

The script logs in through the UI with the seeded admin account, visits the Admin dashboard, product management, product Sport tab, sports, collections, orders, staff, users, chats, settings, profile, and change-password screens, then fails if Flutter reports runtime errors such as RenderFlex overflow or router pop crashes.

Generated reports:

- `ai-harness/state/admin-mobile-browser-smoke-latest.md`
- `ai-harness/state/admin-mobile-browser-smoke-latest.json`
- `ai-harness/state/browser-admin-smoke/*.png`

## Customer & Staff browser smoke test

Run a real browser pass across Customer and Delivery Staff routes:

```powershell
node ai-harness/scripts/customer-staff-ui-browser-smoke.mjs
```

This smoke test also checks the public/auth routes `/`, `/onboarding`, `/login`, `/register`, `/forgot-password`, `/reset-password`, `/guest-chat`, `/unauthorized`, and verifies that the login back button falls back to `/onboarding` when the page was opened directly.

Accounts come from `.env`:

- `SPORTSHOP_MEMBER_EMAIL` / `SPORTSHOP_MEMBER_PASSWORD`
- `SPORTSHOP_SHIPPER_EMAIL` / `SPORTSHOP_SHIPPER_PASSWORD`

Generated reports:

- `ai-harness/state/customer-staff-browser-smoke-latest.md`
- `ai-harness/state/customer-staff-browser-smoke-latest.json`
- `ai-harness/state/browser-customer-staff-smoke/*.png`

## Full MVP harness

Run backend/mobile/frontend checks, Admin UI audit, and API MVP CRUD smoke:

```powershell
.\ai-harness\scripts\Invoke-FullMvpHarness.ps1
```

Run the full order lifecycle E2E as well:

```powershell
.\ai-harness\scripts\Invoke-FullMvpHarness.ps1 `
  -RunOrderE2E
```

Run Admin/Staff operations smoke as well:

```powershell
.\ai-harness\scripts\Invoke-FullMvpHarness.ps1 `
  -RunOrderE2E `
  -RunAdminOps
```

Run the deeper MVP end-to-end pass that covers Customer + Staff + Shipper + Admin, role guards, inventory guard, dashboard, notification settings, VNPay URL generation, and order history:

```powershell
.\ai-harness\scripts\Invoke-FullMvpHarness.ps1 `
  -RunFullMvpE2E `
  -RunOrderE2E `
  -RunAdminOps
```

Include browser smoke when a Flutter web build/server is already running:

```powershell
.\ai-harness\scripts\Invoke-FullMvpHarness.ps1 `
  -RunBrowserSmoke
```

To start Flutter web with the same `.env` API URL:

```powershell
cd mobile
.\init.ps1 -Web
```

Generated MVP API reports:

- `ai-harness/state/mvp-api-smoke-latest.md`
- `ai-harness/state/mvp-api-smoke-latest.json`
- `ai-harness/state/full-mvp-e2e-latest.md`
- `ai-harness/state/full-mvp-e2e-latest.json`
- `ai-harness/state/order-e2e-smoke-latest.md`
- `ai-harness/state/order-e2e-smoke-latest.json`
- `ai-harness/state/admin-ops-smoke-latest.md`
- `ai-harness/state/admin-ops-smoke-latest.json`

## Typical AI workflow

1. Pick a slice in `whole-app-backlog.json`.
2. Read `state/guardrails.md` and `config/context-map.json`.
3. Implement narrowly.
4. Run checks.
5. Append `state/progress.md`.
