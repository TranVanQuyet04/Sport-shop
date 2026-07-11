# SportShop Harness Guardrails

Read before every implementation slice.

## Global rules

- Do not change API endpoints, request fields, response fields, authentication, authorization, database schema, entity, model, or DTO unless the active slice explicitly requires it.
- Do not call APIs directly from Flutter View files.
- Do not introduce mock data into production paths.
- Do not hide errors with empty catch blocks; surface friendly messages through controller/UI state.
- Do not alter order total, payment, stock, revenue, role, or delivery status logic for UI-only requests.
- Do not revert unrelated dirty files.

## Backend signs

- Spring controllers should delegate business logic to services where feasible.
- Repository calls must not silently bypass role constraints.
- Exception handling must avoid duplicate handlers that break Spring context startup.
- Status mapping between backend and mobile must be explicit and tested when changed.

## Mobile signs

- Keep new UI widgets private in the same file unless reusable.
- Apply SOLID/SRP to Flutter screens: a page should orchestrate state and navigation, while large UI blocks, dialogs, cards, filters, and empty states must be split by feature responsibility.
- Keep Dart files under 450 lines whenever feasible and target 300-400 lines for complex feature files. If a file exceeds the limit, split it before adding more UI.
- Avoid overflow on small mobile screens.
- Bottom navigation fixed bars require content bottom padding.
- Use existing design system (`AppSpacing`, `AppTextStyles`, Admin design widgets) before inventing new style tokens.
- For Admin UI work, update or consult `ai-harness/config/mobile-admin-screen-map.json` before changing routes.
- Admin UI auto-fix must be agent-driven: audit first, patch the smallest UI/navigation issue, then rerun audit/analyze/test.
- Do not let the Sport menu accidentally navigate to product creation or unrelated product flows.

## Verification signs

- Backend slice: run `backend/mvnw test` or explain why not.
- Mobile slice: run `dart format lib test`, `./init.ps1 -Analyze`, `./init.ps1 -Test` from `mobile/`.
- Full-stack slice: run root `./ai-harness/scripts/run-checks.ps1` when possible.
- Admin UI slice: run `./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1` from project root.
