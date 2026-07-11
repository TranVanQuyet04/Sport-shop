# NFR - Non-Functional Requirements  
## Sportswear Shop System – Mobile Application

**Version:** 1.0  
**Date:** 2026-07-04  
**References:** BRD.md, SRS.md, AGENTS.md

---

## 1. Performance Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-PERF-01 | Product list (recommended) must load within | **< 3 seconds** on 4G network |
| NFR-PERF-02 | Search results must appear after user finishes typing | **< 1.5 seconds** |
| NFR-PERF-03 | Cart update (add/remove/update quantity) round-trip | **< 1 second** |
| NFR-PERF-04 | App cold start (splash to first screen) | **< 5 seconds** |
| NFR-PERF-05 | Admin product list (all products) must load within | **< 4 seconds** |
| NFR-PERF-06 | Shipper order list must refresh within | **< 2 seconds** after pull-to-refresh |

---

## 2. Reliability & Availability Requirements

| ID | Requirement |
|----|-------------|
| NFR-REL-01 | The app SHALL NOT crash (white screen / fatal error) on any network failure scenario. |
| NFR-REL-02 | All async operations SHALL display a loading indicator while in progress and revert to a usable state on failure. |
| NFR-REL-03 | Network errors (timeout, 5xx) SHALL display a human-readable Vietnamese error message. |
| NFR-REL-04 | VNPay payment cancellation SHALL NOT result in data loss; the order SHALL remain accessible in `PENDING` state. |
| NFR-REL-05 | Token expiry SHALL be handled silently without user interruption; only force re-login if refresh token is also invalid. |

---

## 3. Security Requirements

| ID | Requirement |
|----|-------------|
| NFR-SEC-01 | Access tokens and refresh tokens SHALL be stored exclusively in **FlutterSecureStorage** (AES-256 encrypted at rest). |
| NFR-SEC-02 | No tokens, passwords, or personally identifiable information (PII) SHALL appear in application logs. |
| NFR-SEC-03 | The `print()` function is PROHIBITED in production code; `debugPrint()` or dedicated logging library must be used. |
| NFR-SEC-04 | All protected API calls SHALL include `Authorization: Bearer {accessToken}`. |
| NFR-SEC-05 | Role-based route guards SHALL prevent unauthorized users from accessing admin or shipper routes; violating users are redirected to the Login screen. |
| NFR-SEC-06 | On session clearance (logout or failed refresh), ALL locally stored tokens and user data SHALL be deleted immediately. |
| NFR-SEC-07 | The VNPay payment WebView SHALL only be opened with URLs originating from the trusted backend endpoint (`/payment/create_payment`). |

---

## 4. Usability & Accessibility Requirements

| ID | Requirement |
|----|-------------|
| NFR-USE-01 | All user-facing text, labels, and messages SHALL be written in **Vietnamese**. |
| NFR-USE-02 | All code identifiers (class names, function names, variable names) SHALL be in **English**. |
| NFR-USE-03 | All list/grid screens with no data SHALL show a meaningful **empty-state** (illustration + descriptive message in Vietnamese). |
| NFR-USE-04 | All destructive actions (delete, cancel order, clear cart) SHALL require a **confirmation dialog** before execution. |
| NFR-USE-05 | All interactive buttons SHALL provide visual feedback (press animation / loading state). |
| NFR-USE-06 | Color palette shall align with the **Supersports brand**: Navy (`#003087`), Red (`#E31837`), White, with Gold accent for premium feel. |
| NFR-USE-07 | Font SHALL use a modern sans-serif typeface (e.g., Google Fonts: **Roboto** or **Inter**). |
| NFR-USE-08 | Card border radius SHALL be consistent: `8px` for product cards; `12px` for modals/bottom sheets. |
| NFR-USE-09 | The app SHALL be fully functional on **standard Android phone screen sizes** (360–414dp width). |

---

## 5. Maintainability Requirements

| ID | Requirement |
|----|-------------|
| NFR-MNT-01 | No single Dart file SHALL exceed **600 lines**. Complex widgets SHALL be extracted to sub-widgets or a `widgets/` directory. |
| NFR-MNT-02 | All code SHALL be formatted with `dart format lib test` before commit. |
| NFR-MNT-03 | The project SHALL pass `flutter analyze` with zero errors (warnings may be addressed iteratively). |
| NFR-MNT-04 | All API endpoint paths SHALL be defined as constants in `ApiEndpoints` class; no hardcoded URLs in service classes. |
| NFR-MNT-05 | Business logic SHALL reside exclusively in the **Presenter** layer; View layers SHALL only handle rendering and user events. |
| NFR-MNT-06 | All presenter methods that call APIs SHALL be wrapped in `try-catch`; caught errors assigned to `errorMessage` and `notifyListeners()` called. |
| NFR-MNT-07 | Dependency injection SHALL flow exclusively through `AppDependencies` (Service Locator) and constructor injection on Presenters. |

---

## 6. Portability & Compatibility Requirements

| ID | Requirement |
|----|-------------|
| NFR-COMP-01 | The primary target platform is **Android** (API level 24 / Android 7.0 and above). |
| NFR-COMP-02 | The secondary target platform is **Web** (Chrome/Edge latest stable). |
| NFR-COMP-03 | Platform-specific URL differences (10.0.2.2 vs localhost) SHALL be handled via the `kIsWeb` constant. |
| NFR-COMP-04 | The app SHALL NOT require iOS support in version 1.0. |

---

## 7. Scalability Requirements

| ID | Requirement |
|----|-------------|
| NFR-SCAL-01 | The architecture SHALL support future addition of Riverpod global state providers (F20) without requiring a full rewrite of existing Presenters. |
| NFR-SCAL-02 | Product caching (F21) SHALL be implementable as a Repository-layer concern without affecting Service or View layers. |
| NFR-SCAL-03 | Push notification integration (F22 – FCM) SHALL be addable as a standalone service layer with minimal changes to existing screens. |

---

## 8. Testability Requirements

| ID | Requirement |
|----|-------------|
| NFR-TEST-01 | All Repository classes SHALL depend on injected `Service` interfaces (not concrete implementations), enabling mock substitution in unit tests. |
| NFR-TEST-02 | The project SHALL maintain a `test/` directory; at minimum, tests SHALL cover: Splash screen widget, auth presenter validation, and cart calculation logic. |
| NFR-TEST-03 | The CI pipeline SHALL run `flutter test` and block builds on test failures. |

---

## 9. Compliance Requirements

| ID | Requirement |
|----|-------------|
| NFR-COMP-01 | The app SHALL comply with the **Vietnamese Cybersecurity Law** (Luật An ninh mạng 2018) by not storing PII beyond what is necessary. |
| NFR-COMP-02 | Payment integration SHALL comply with **VNPay sandbox** specifications during development and VNPay production certification before go-live. |
| NFR-COMP-03 | The `AGENTS.md` coding standards document is MANDATORY and binding for all development agents and contributors. |
