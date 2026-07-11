# StrideX AI Harness

Harness nÃ y Ä‘Æ°á»£c thiáº¿t káº¿ cho dá»± Ã¡n `sportswear-shop-system` dá»±a trÃªn máº«u `ai-engineering-learning-master`, nhÆ°ng Ä‘Ã£ Ä‘iá»u chá»‰nh cho stack tháº­t cá»§a StrideX:

- `backend/`: Spring Boot, Maven, JPA/Spring Security.
- `mobile/`: Flutter app theo kiáº¿n trÃºc View/Controller/Repository/Service/Core.
- `frontend/`: web/admin náº¿u cÃ²n Ä‘Æ°á»£c dÃ¹ng trong dá»± Ã¡n.
- `docs/`: tÃ i liá»‡u yÃªu cáº§u, module, phase, role flow vÃ  acceptance checklist.

Má»¥c tiÃªu cá»§a harness lÃ  buá»™c AI Agent lÃ m viá»‡c theo lÃ¡t cáº¯t nhá», Ä‘á»c Ä‘Ãºng ngá»¯ cáº£nh, khÃ´ng phÃ¡ API/business logic, vÃ  luÃ´n cháº¡y kiá»ƒm tra sau khi sá»­a.

## Cáº¥u trÃºc

| File/Folder | Vai trÃ² |
|---|---|
| `HARNESS-DESIGN.md` | Báº£n Ä‘á»“ cÃ¡c thÃ nh pháº§n harness |
| `whole-app-backlog.json` | HÃ ng Ä‘á»£i lÃ¡t cáº¯t cÃ´ng viá»‡c |
| `config/context-map.json` | Má»—i lÃ¡t cáº¯t cáº§n Ä‘á»c tÃ i liá»‡u/file nÃ o |
| `config/models.json` | Cáº¥u hÃ¬nh model/timeout máº·c Ä‘á»‹nh cho agent loop |
| `config/device-profiles.json` | Cáº¥u hÃ¬nh thiáº¿t bá»‹ test UI, máº·c Ä‘á»‹nh lÃ  Google Pixel 7 viewport 412x915 |
| `agents/*.prompt.md` | Prompt vai trÃ² implementer/reviewer/tester |
| `workflows/ralph-loop.json` | Policy cho vÃ²ng implement/check/review |
| `state/guardrails.md` | BÃ i há»c vÃ  quy táº¯c khÃ´ng Ä‘Æ°á»£c tÃ¡i pháº¡m |
| `state/progress.md` | Nháº­t kÃ½ tiáº¿n Ä‘á»™ harness |
| `scripts/run-checks.ps1` | Check backend/mobile/frontend theo kháº£ nÄƒng hiá»‡n cÃ³ |
| `scripts/check-mobile-solid.ps1` | Cháº·n Dart file quÃ¡ lá»›n (>450 dÃ²ng máº·c Ä‘á»‹nh), nháº¯c tÃ¡ch UI theo SOLID/SRP |
| `scripts/Invoke-AdminMobileUiHarness.ps1` | QuÃ©t MVP/UI/navigation cho cÃ¡c mÃ n Mobile Admin |
| `test-case-index.json` | Tráº¡ng thÃ¡i test case theo requirement tag |

## Quy trÃ¬nh khuyáº¿n nghá»‹

1. Chá»n má»™t slice trong `whole-app-backlog.json` cÃ³ `passes: false`.
2. Äá»c `config/context-map.json` Ä‘á»ƒ láº¥y tÃ i liá»‡u/ngá»¯ cáº£nh liÃªn quan.
3. Sá»­a code Ä‘Ãºng pháº¡m vi slice.
4. Cháº¡y:

```powershell
./ai-harness/scripts/run-checks.ps1
```

5. Náº¿u pass, cáº­p nháº­t `state/progress.md` vÃ  set slice `passes: true` náº¿u báº¡n quáº£n lÃ½ backlog thá»§ cÃ´ng.

## Lá»‡nh kiá»ƒm tra thá»§ cÃ´ng

Backend:

```powershell
cd backend
./mvnw test
```

Mobile:

```powershell
cd mobile
dart format lib test
./init.ps1 -Analyze
./init.ps1 -Test
```

Root harness:

```powershell
./ai-harness/scripts/run-checks.ps1
```

Kiá»ƒm tra riÃªng rule SOLID/file-size cho Flutter mobile:

```powershell
./ai-harness/scripts/check-mobile-solid.ps1
```

Admin Mobile UI harness:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1
```

Browser smoke tests dÃ¹ng thiáº¿t bá»‹ máº·c Ä‘á»‹nh trong `ai-harness/config/device-profiles.json`.
Hiá»‡n táº¡i thiáº¿t bá»‹ máº·c Ä‘á»‹nh lÃ  **Google Pixel 7** vá»›i viewport **412 x 915**.
CÃ³ thá»ƒ Ä‘á»•i táº¡m báº±ng biáº¿n mÃ´i trÆ°á»ng:

```powershell
$env:SPORTSHOP_TEST_DEVICE="pixel7"
node ./ai-harness/scripts/admin-ui-browser-smoke.mjs
node ./ai-harness/scripts/customer-staff-ui-browser-smoke.mjs
```

Admin Mobile UI harness vá»›i auto-fix an toÃ n cho lá»—i UI/navigation cÃ³ máº«u rÃµ rÃ ng:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1 -ApplySafeFixes -MaxAttempts 3
```

Cháº¡y audit kÃ¨m format/analyze/test mobile:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1 -RunMobileChecks
```

Cháº¡y vÃ²ng Ä‘áº§y Ä‘á»§: audit, tá»± sá»­a lá»—i an toÃ n, retry, format, analyze vÃ  test:

```powershell
./ai-harness/scripts/Invoke-AdminMobileUiHarness.ps1 -ApplySafeFixes -MaxAttempts 3 -RunMobileChecks
```

## NguyÃªn táº¯c quan trá»ng

- KhÃ´ng Ä‘á»•i API endpoint/request/response náº¿u slice khÃ´ng yÃªu cáº§u.
- KhÃ´ng gá»i API trá»±c tiáº¿p trong Flutter View.
- KhÃ´ng sá»­a database/entity/DTO/business logic khi task chá»‰ lÃ  UI.
- KhÃ´ng rollback thay Ä‘á»•i ngoÃ i pháº¡m vi task.
- KhÃ´ng gom toÃ n bá»™ feature vÃ o má»™t class/file. Screen lá»›n pháº£i tÃ¡ch widget/dialog/card/filter theo trÃ¡ch nhiá»‡m, Æ°u tiÃªn file khoáº£ng 300-400 dÃ²ng vÃ  khÃ´ng vÆ°á»£t 450 dÃ²ng náº¿u cÃ³ thá»ƒ.
- Má»i thay Ä‘á»•i pháº£i cÃ³ kiá»ƒm chá»©ng báº±ng script hoáº·c ghi rÃµ lÃ½ do khÃ´ng cháº¡y Ä‘Æ°á»£c.
