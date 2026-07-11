# ARCHITECTURE.md - KiÃ¡ÂºÂ¿n trÃƒÂºc DÃ¡Â»Â± ÃƒÂ¡n (Clean Architecture & Layers)

TÃƒÂ i liÃ¡Â»â€¡u nÃƒÂ y mÃƒÂ´ tÃ¡ÂºÂ£ chi tiÃ¡ÂºÂ¿t kiÃ¡ÂºÂ¿n trÃƒÂºc phÃ¡ÂºÂ§n mÃ¡Â»Âm, cÃ¡ÂºÂ¥u trÃƒÂºc thÃ†Â° mÃ¡Â»Â¥c, cÃƒÂ¡c lÃ¡Â»â€ºp (layers) vÃƒÂ  quy tÃ¡ÂºÂ¯c phÃ¡Â»Â¥ thuÃ¡Â»â„¢c (dependency rules) ÃƒÂ¡p dÃ¡Â»Â¥ng trong dÃ¡Â»Â± ÃƒÂ¡n Flutter **sportswear-shop-system (mobile)**.

---

## 1. TÃ¡Â»â€¢ng quan KiÃ¡ÂºÂ¿n trÃƒÂºc

DÃ¡Â»Â± ÃƒÂ¡n ÃƒÂ¡p dÃ¡Â»Â¥ng mÃƒÂ´ hÃƒÂ¬nh **Clean Architecture** kÃ¡ÂºÂ¿t hÃ¡Â»Â£p vÃ¡Â»â€ºi mÃƒÂ´ hÃƒÂ¬nh **MVP \(Model-View-Presenter\)** gÃ¡Â»Ân nhÃ¡ÂºÂ¹ Ã„â€˜Ã¡Â»Æ’ quÃ¡ÂºÂ£n lÃƒÂ½ trÃ¡ÂºÂ¡ng thÃƒÂ¡i. KiÃ¡ÂºÂ¿n trÃƒÂºc Ã„â€˜Ã†Â°Ã¡Â»Â£c thiÃ¡ÂºÂ¿t kÃ¡ÂºÂ¿ nhÃ¡ÂºÂ±m Ã„â€˜Ã¡ÂºÂ¡t Ã„â€˜Ã†Â°Ã¡Â»Â£c sÃ¡Â»Â± Ã„â€˜Ã¡Â»â„¢c lÃ¡ÂºÂ­p giÃ¡Â»Â¯a giao diÃ¡Â»â€¡n ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng, logic nghiÃ¡Â»â€¡p vÃ¡Â»Â¥ vÃƒÂ  cÃƒÂ¡c nguÃ¡Â»â€œn dÃ¡Â»Â¯ liÃ¡Â»â€¡u bÃƒÂªn ngoÃƒÂ i.

```mermaid
graph TD
    %% LÃ¡Â»â€ºp Giao diÃ¡Â»â€¡n (Presentation Layer)
    subgraph Presentation Layer
        View[View / Screen - lib/view]
        Widget[Custom Widgets - lib/widgets]
        Presenter[Presenter - lib/presenter]
    end

    %% LÃ¡Â»â€ºp NghiÃ¡Â»â€¡p vÃ¡Â»Â¥ / DÃ¡Â»Â¯ liÃ¡Â»â€¡u (Domain & Data Layer)
    subgraph Data & Domain Layer
        Repository[Repository - lib/repository]
        Service[API Service - lib/service]
        Model[Domain Model - lib/model]
    end

    %% LÃ¡Â»â€ºp CÃ¡Â»â€˜t lÃƒÂµi (Core Layer)
    subgraph Core Layer
        ApiClient[ApiClient - lib/core/network]
        Storage[TokenStorage - lib/core/storage]
        DI[AppDependencies - lib/core/di]
        Router[GoRouter - lib/app]
    end

    %% LuÃ¡Â»â€œng phÃ¡Â»Â¥ thuÃ¡Â»â„¢c (Dependency Rule)
    View -->|LÃ¡ÂºÂ¯ng nghe trÃ¡ÂºÂ¡ng thÃƒÂ¡i| Presenter
    Presenter -->|Constructor Injection| Repository
    Repository -->|TriÃ¡Â»Æ’n khai interface| Service
    Repository -->|LÃ†Â°u trÃ¡Â»Â¯ token| Storage
    Service -->|YÃƒÂªu cÃ¡ÂºÂ§u HTTP| ApiClient
    DI -->|KhÃ¡Â»Å¸i tÃ¡ÂºÂ¡o & Cung cÃ¡ÂºÂ¥p| Repository
    DI -->|KhÃ¡Â»Å¸i tÃ¡ÂºÂ¡o & Cung cÃ¡ÂºÂ¥p| Service
    Router -->|Ã„ÂiÃ¡Â»Âu hÃ†Â°Ã¡Â»â€ºng| View
    
    %% SÃ¡Â»Â­ dÃ¡Â»Â¥ng chung Models
    Presenter -.-> Model
    Repository -.-> Model
    Service -.-> Model
```

---

## 2. MÃƒÂ´ tÃ¡ÂºÂ£ cÃƒÂ¡c LÃ¡Â»â€ºp trong HÃ¡Â»â€¡ thÃ¡Â»â€˜ng (Layers)

### 2.1 Core Layer (`lib/core/`)
LÃƒÂ  nÃ†Â¡i chÃ¡Â»Â©a cÃƒÂ¡c thÃƒÂ nh phÃ¡ÂºÂ§n dÃƒÂ¹ng chung cho toÃƒÂ n bÃ¡Â»â„¢ Ã¡Â»Â©ng dÃ¡Â»Â¥ng, ÃƒÂ­t khi thay Ã„â€˜Ã¡Â»â€¢i theo logic nghiÃ¡Â»â€¡p vÃ¡Â»Â¥ cÃ¡Â»Â¥ thÃ¡Â»Æ’.
* **`network/` (ApiClient, ApiEndpoints):** CÃ¡ÂºÂ¥u hÃƒÂ¬nh client HTTP (sÃ¡Â»Â­ dÃ¡Â»Â¥ng thÃ†Â° viÃ¡Â»â€¡n `Dio`), thiÃ¡ÂºÂ¿t lÃ¡ÂºÂ­p timeout, thÃƒÂªm header Authorization (Bearer Token), xÃ¡Â»Â­ lÃƒÂ½ exception tÃ¡ÂºÂ­p trung thÃƒÂ nh lÃ¡Â»â€”i tiÃ¡ÂºÂ¿ng ViÃ¡Â»â€¡t dÃ¡Â»â€¦ hiÃ¡Â»Æ’u (`ApiException`).
* **`storage/` (TokenStorage):** QuÃ¡ÂºÂ£n lÃƒÂ½ lÃ†Â°u trÃ¡Â»Â¯ cÃ¡Â»Â¥c bÃ¡Â»â„¢ cÃƒÂ¡c thÃƒÂ´ng tin nhÃ¡ÂºÂ¡y cÃ¡ÂºÂ£m nhÃ†Â° Access Token, Refresh Token, Role cÃ¡Â»Â§a ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng Ã„â€˜ang Ã„â€˜Ã„Æ’ng nhÃ¡ÂºÂ­p thÃƒÂ´ng qua `FlutterSecureStorage`.
* **`di/` (AppDependencies):** Ã„ÂÃƒÂ³ng vai trÃƒÂ² lÃƒÂ  mÃ¡Â»â„¢t Service Locator tÃ¡ÂºÂ­p trung theo mÃƒÂ´ hÃƒÂ¬nh Singleton, chÃ¡Â»â€¹u trÃƒÂ¡ch nhiÃ¡Â»â€¡m khÃ¡Â»Å¸i tÃ¡ÂºÂ¡o vÃƒÂ  kÃ¡ÂºÂ¿t nÃ¡Â»â€˜i cÃƒÂ¡c Service vÃƒÂ  Repository tÃ†Â°Ã†Â¡ng Ã¡Â»Â©ng.
* **`theme/` & `constants/`:** Ã„ÂÃ¡Â»â€¹nh nghÃ„Â©a hÃ¡Â»â€¡ thÃ¡Â»â€˜ng Design System gÃ¡Â»â€œm mÃƒÂ u sÃ¡ÂºÂ¯c (`AppColors`), kiÃ¡Â»Æ’u chÃ¡Â»Â¯ (`AppTextStyles`), khoÃ¡ÂºÂ£ng cÃƒÂ¡ch lÃ¡Â»Â (`AppSpacing`), vÃƒÂ  cÃƒÂ¡c hÃ¡ÂºÂ±ng sÃ¡Â»â€˜ cÃ¡ÂºÂ¥u hÃƒÂ¬nh.

### 2.2 Domain / Model Layer (`lib/model/`)
ChÃ¡Â»Â©a cÃƒÂ¡c thÃ¡Â»Â±c thÃ¡Â»Æ’ dÃ¡Â»Â¯ liÃ¡Â»â€¡u (entities) thuÃ¡ÂºÂ§n tÃƒÂºy cÃ¡Â»Â§a Ã¡Â»Â©ng dÃ¡Â»Â¥ng, khÃƒÂ´ng bÃ¡Â»â€¹ phÃ¡Â»Â¥ thuÃ¡Â»â„¢c vÃƒÂ o cÃƒÂ¡c thÃ†Â° viÃ¡Â»â€¡n bÃƒÂªn ngoÃƒÂ i hay cÃƒÂ¡c thÃƒÂ nh phÃ¡ÂºÂ§n UI.
* Ã„ÂÃ¡Â»â€¹nh nghÃ„Â©a cÃƒÂ¡c phÃ†Â°Ã†Â¡ng thÃ¡Â»Â©c ÃƒÂ¡nh xÃ¡ÂºÂ¡ JSON nhÃ†Â° `fromJson` vÃƒÂ  `toJson` Ã„â€˜Ã¡Â»Æ’ chuyÃ¡Â»Æ’n Ã„â€˜Ã¡Â»â€¢i dÃ¡Â»Â¯ liÃ¡Â»â€¡u tÃ¡Â»Â« API.
* Ã„ÂÃ†Â°Ã¡Â»Â£c phÃƒÂ¢n chia theo phÃƒÂ¢n hÃ¡Â»â€¡ chÃ¡Â»Â©c nÃ„Æ’ng: `admin/`, `auth/`, `chat/`, `customer/`, `delivery_staff/`, `common/`.

### 2.3 Remote Service Layer (`lib/service/`)
Ã„ÂÃƒÂ³ng vai trÃƒÂ² lÃƒÂ  cÃ¡ÂºÂ§u nÃ¡Â»â€˜i trÃ¡Â»Â±c tiÃ¡ÂºÂ¿p tÃ¡Â»â€ºi REST API cÃ¡Â»Â§a Backend.
* MÃ¡Â»â€”i module chÃ¡Â»Â©c nÃ„Æ’ng Ã„â€˜Ã¡Â»Âu khai bÃƒÂ¡o mÃ¡Â»â„¢t giao diÃ¡Â»â€¡n (`abstract interface class`) vÃƒÂ  mÃ¡Â»â„¢t lÃ¡Â»â€ºp triÃ¡Â»Æ’n khai cÃ¡Â»Â¥ thÃ¡Â»Æ’ (vÃƒÂ­ dÃ¡Â»Â¥: `AuthService` vÃƒÂ  `AuthApiService`).
* LÃ¡Â»â€ºp Service sÃ¡Â»Â­ dÃ¡Â»Â¥ng `ApiClient` Ã„â€˜Ã¡Â»Æ’ gÃ¡Â»Â­i cÃƒÂ¡c yÃƒÂªu cÃ¡ÂºÂ§u HTTP (GET, POST, PUT, DELETE, PATCH) vÃƒÂ  chuyÃ¡Â»Æ’n Ã„â€˜Ã¡Â»â€¢i kÃ¡ÂºÂ¿t quÃ¡ÂºÂ£ JSON thÃƒÂ´ nhÃ¡ÂºÂ­n Ã„â€˜Ã†Â°Ã¡Â»Â£c thÃƒÂ nh cÃƒÂ¡c Model tÃ†Â°Ã†Â¡ng Ã¡Â»Â©ng.

### 2.4 Data Repository Layer (`lib/repository/`)
ChÃ¡Â»â€¹u trÃƒÂ¡ch nhiÃ¡Â»â€¡m cung cÃ¡ÂºÂ¥p dÃ¡Â»Â¯ liÃ¡Â»â€¡u sÃ¡ÂºÂ¡ch cho Presenter, Ã„â€˜iÃ¡Â»Âu phÃ¡Â»â€˜i nguÃ¡Â»â€œn dÃ¡Â»Â¯ liÃ¡Â»â€¡u giÃ¡Â»Â¯a Remote API (Service) vÃƒÂ  Local Storage (Token Storage).
* GiÃƒÂºp che giÃ¡ÂºÂ¥u chi tiÃ¡ÂºÂ¿t triÃ¡Â»Æ’n khai lÃ¡ÂºÂ¥y dÃ¡Â»Â¯ liÃ¡Â»â€¡u Ã¡Â»Å¸ Ã„â€˜ÃƒÂ¢u vÃƒÂ  nhÃ†Â° thÃ¡ÂºÂ¿ nÃƒÂ o khÃ¡Â»Âi lÃ¡Â»â€ºp nghiÃ¡Â»â€¡p vÃ¡Â»Â¥.
* TÃƒÂ¡ch biÃ¡Â»â€¡t interface vÃƒÂ  triÃ¡Â»Æ’n khai cÃ¡Â»Â¥ thÃ¡Â»Æ’ (vÃƒÂ­ dÃ¡Â»Â¥: `AuthRepository` vÃƒÂ  `AuthRepositoryImpl`).

### 2.5 Presenter Layer (`lib/presenter/`)
ChÃ¡Â»Â©a logic nghiÃ¡Â»â€¡p vÃ¡Â»Â¥ cÃ¡Â»Â§a mÃƒÂ n hÃƒÂ¬nh giao diÃ¡Â»â€¡n (Presentation logic) vÃƒÂ  quÃ¡ÂºÂ£n lÃƒÂ½ trÃ¡ÂºÂ¡ng thÃƒÂ¡i UI.
* KÃ¡ÂºÂ¿ thÃ¡Â»Â«a `ChangeNotifier` cÃ¡Â»Â§a Flutter.
* NhÃ¡ÂºÂ­n cÃƒÂ¡c Repositories cÃ¡ÂºÂ§n thiÃ¡ÂºÂ¿t thÃƒÂ´ng qua hÃƒÂ m dÃ¡Â»Â±ng (Constructor Injection).
* ChÃ¡Â»â€¹u trÃƒÂ¡ch nhiÃ¡Â»â€¡m xÃƒÂ¡c thÃ¡Â»Â±c dÃ¡Â»Â¯ liÃ¡Â»â€¡u Ã„â€˜Ã¡ÂºÂ§u vÃƒÂ o cÃ¡Â»Â§a biÃ¡Â»Æ’u mÃ¡ÂºÂ«u (Form validation), gÃ¡Â»Âi API qua Repository, quÃ¡ÂºÂ£n lÃƒÂ½ cÃ¡Â»Â trÃ¡ÂºÂ¡ng thÃƒÂ¡i (`isLoading`, `isUpdating`, `errorMessage`), vÃƒÂ  thÃƒÂ´ng bÃƒÂ¡o cho View cÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t giao diÃ¡Â»â€¡n bÃ¡ÂºÂ±ng `notifyListeners()`.

### 2.6 Presentation Layer (`lib/view/`, `lib/widgets/`)
ChÃ¡Â»Â©a giao diÃ¡Â»â€¡n ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng thÃ¡Â»Â±c tÃ¡ÂºÂ¿ vÃƒÂ  Ã„â€˜iÃ¡Â»Âu hÃ†Â°Ã¡Â»â€ºng.
* GÃ¡Â»â€œm cÃƒÂ¡c trang mÃƒÂ n hÃƒÂ¬nh (`Pages` / `Screens`) Ã„â€˜Ã†Â°Ã¡Â»Â£c phÃƒÂ¢n chia theo vai trÃƒÂ² ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng (Admin, Customer, Delivery Staff, Public, Splash).
* CÃƒÂ¡c View sÃ¡Â»Â­ dÃ¡Â»Â¥ng `StatefulWidget`, khÃ¡Â»Å¸i tÃ¡ÂºÂ¡o Presenter tÃ†Â°Ã†Â¡ng Ã¡Â»Â©ng vÃƒÂ  lÃ¡ÂºÂ¯ng nghe cÃƒÂ¡c thay Ã„â€˜Ã¡Â»â€¢i bÃ¡ÂºÂ±ng cÃƒÂ¡ch thÃƒÂªm Listener vÃƒÂ o Presenter:
  ```dart
  _Presenter.addListener(() {
    if (mounted) setState(() {});
  });
  ```
* HÃ¡Â»â€¡ thÃ¡Â»â€˜ng Ã„â€˜Ã¡Â»â€¹nh tuyÃ¡ÂºÂ¿n Ã¡Â»Â©ng dÃ¡Â»Â¥ng sÃ¡Â»Â­ dÃ¡Â»Â¥ng `GoRouter` (`lib/app/sportshop_router.dart`), tÃƒÂ­ch hÃ¡Â»Â£p bÃ¡Â»â„¢ lÃ¡Â»Âc chuyÃ¡Â»Æ’n hÃ†Â°Ã¡Â»â€ºng tÃ¡Â»Â± Ã„â€˜Ã¡Â»â„¢ng (Route Guard) dÃ¡Â»Â±a trÃƒÂªn vai trÃƒÂ² (Role) vÃƒÂ  trÃ¡ÂºÂ¡ng thÃƒÂ¡i Token hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i cÃ¡Â»Â§a ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng.

---

## 3. Quy tÃ¡ÂºÂ¯c phÃ¡Â»Â¥ thuÃ¡Â»â„¢c (Dependency Rule)

1. **ChiÃ¡Â»Âu phÃ¡Â»Â¥ thuÃ¡Â»â„¢c mÃ¡Â»â„¢t chiÃ¡Â»Âu (Inward Dependency):**
   * CÃƒÂ¡c lÃ¡Â»â€ºp bÃƒÂªn ngoÃƒÂ i (UI/Presentation) phÃ¡Â»Â¥ thuÃ¡Â»â„¢c vÃƒÂ o cÃƒÂ¡c lÃ¡Â»â€ºp bÃƒÂªn trong (Presenter, Repository).
   * LÃ¡Â»â€ºp bÃƒÂªn trong tuyÃ¡Â»â€¡t Ã„â€˜Ã¡Â»â€˜i khÃƒÂ´ng biÃ¡ÂºÂ¿t gÃƒÂ¬ vÃ¡Â»Â chi tiÃ¡ÂºÂ¿t cÃ¡Â»Â§a lÃ¡Â»â€ºp bÃƒÂªn ngoÃƒÂ i. VÃƒÂ­ dÃ¡Â»Â¥: Repository khÃƒÂ´ng bao giÃ¡Â»Â chÃ¡Â»Â©a code UI hay tham chiÃ¡ÂºÂ¿u tÃ¡Â»â€ºi Widget.
2. **LÃ¡ÂºÂ­p trÃƒÂ¬nh hÃ†Â°Ã¡Â»â€ºng giao diÃ¡Â»â€¡n (Interface-based Programming):**
   * Presenter chÃ¡Â»â€° tham chiÃ¡ÂºÂ¿u tÃ¡Â»â€ºi cÃƒÂ¡c lÃ¡Â»â€ºp giao diÃ¡Â»â€¡n `interface` cÃ¡Â»Â§a Repository (vÃƒÂ­ dÃ¡Â»Â¥: `AuthRepository`), khÃƒÂ´ng tham chiÃ¡ÂºÂ¿u trÃ¡Â»Â±c tiÃ¡ÂºÂ¿p lÃ¡Â»â€ºp hiÃ¡Â»â€¡n thÃ¡Â»Â±c `AuthRepositoryImpl`. Ã„ÂiÃ¡Â»Âu nÃƒÂ y giÃƒÂºp dÃ¡Â»â€¦ dÃƒÂ ng viÃ¡ÂºÂ¿t mock test cho Presenter.
3. **QuÃ¡ÂºÂ£n lÃƒÂ½ VÃƒÂ²ng Ã„â€˜Ã¡Â»Âi Ã„ÂÃ¡Â»â€˜i tÃ†Â°Ã¡Â»Â£ng (Lifecycle Management):**
   * HÃ¡ÂºÂ§u hÃ¡ÂºÂ¿t cÃƒÂ¡c Repository vÃƒÂ  Service lÃƒÂ  cÃƒÂ¡c biÃ¡ÂºÂ¿n khÃ¡Â»Å¸i tÃ¡ÂºÂ¡o trÃ¡Â»â€¦ (`late final`) dÃ¡ÂºÂ¡ng Singleton bÃƒÂªn trong `AppDependencies` vÃƒÂ  tÃ¡Â»â€œn tÃ¡ÂºÂ¡i suÃ¡Â»â€˜t vÃƒÂ²ng Ã„â€˜Ã¡Â»Âi Ã¡Â»Â©ng dÃ¡Â»Â¥ng.
   * NgÃ†Â°Ã¡Â»Â£c lÃ¡ÂºÂ¡i, cÃƒÂ¡c Presenter Ã„â€˜Ã†Â°Ã¡Â»Â£c khÃ¡Â»Å¸i tÃ¡ÂºÂ¡o tÃ¡ÂºÂ¡i `initState` cÃ¡Â»Â§a View vÃƒÂ  tÃ¡Â»Â± giÃ¡ÂºÂ£i phÃƒÂ³ng bÃ¡Â»â„¢ nhÃ¡Â»â€º (`_Presenter.dispose()`) tÃ¡ÂºÂ¡i `dispose` cÃ¡Â»Â§a View Ã„â€˜Ã¡Â»Æ’ trÃƒÂ¡nh rÃƒÂ² rÃ¡Â»â€° bÃ¡Â»â„¢ nhÃ¡Â»â€º (memory leaks).
