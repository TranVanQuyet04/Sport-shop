# StrideX AI Harness Design

## Component map

| Component | Location | StrideX adaptation |
|---|---|---|
| Model config | `config/models.json` | Agent model/timeouts and command defaults |
| Prompts | `agents/*.prompt.md` | Implementer, reviewer, tester roles for Spring Boot + Flutter |
| Context | `config/context-map.json` | Maps slices to docs and source folders |
| Workflow | `workflows/ralph-loop.json` | One-slice implementation loop policy |
| Memory/State | `state/progress.md`, `state/guardrails.md`, `whole-app-backlog.json` | Persistent lessons and slice queue |
| Validation | `scripts/run-checks.ps1` | Maven tests + Flutter analyze/test + optional frontend checks |
| Test cases | `test-case-index.json` | Lightweight requirement-test status registry |
| Docs | `docs/` in project root + module harness docs | Existing StrideX project documentation |

## Loop model

```text
pick slice -> read context-map -> implement narrowly -> run checks -> review -> mark pass/log progress
```

## Stack-aware guardrails

### Backend
- Controllers expose stable endpoints.
- DTO/request/response field names are contract-sensitive.
- Entity/database changes require explicit task scope and migration awareness.
- Spring Security role checks must not be relaxed accidentally.

### Mobile
- View must not call API services directly.
- Use Controller + Repository + Service + AppDependencies pattern.
- UI-only tasks must not change API payload, role logic, order/payment/inventory math.
- `dart format lib test`, `init.ps1 -Analyze`, and `init.ps1 -Test` are expected checks.

### Cross-stack
- API contract changes must be reflected in backend, mobile endpoints/models, docs, and tests.
- Prefer small, reversible slices over broad rewrites.
