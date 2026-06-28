# Manga Reader Frontend - SDD Implementation Checklist

This checklist tracks the implementation of features for the Manga Reader Flutter application across all five planned phases.

---

## [x] Phase 1: Core Setup, Routing & Theme
*   [x] **Dependencies Setup**
    *   [x] Add packages in `pubspec.yaml`
    *   [x] Run `flutter pub get` successfully
*   [x] **Core Directory Structuring**
    *   [x] Create `lib/core/` subfolders (`router/`, `network/`, `theme/`, `services/`, `widgets/`, `utils/`)
*   [x] **Theme Setup**
    *   [x] Implement light and default dark mode in `app_theme.dart` (Red primary highlight)
*   [x] **Placeholder Screens**
    *   [x] Create simple placeholders widgets for Login, Register, Home, Search, Details, Reader, Downloads, and Offline screens in pt-BR
*   [x] **Router Configuration**
    *   [x] Implement GoRouter in `app_router.dart` exposing a Provider
    *   [x] Configure `StatefulShellRoute` navigation shell
    *   [x] Connect router configuration in `lib/main.dart`
*   [x] **Environment Configurations & Android Flavors**
    *   [x] Add `config/` entry to `.gitignore` to prevent configuration leakage.
    *   [x] Create `config/dev.json`, `config/prod.json`, and `config/dev.json.example` configuration files.
    *   [x] Set up Android product flavors in `android/app/build.gradle.kts` (dimension "default", flavors `dev` and `prod`, suffixes, and resValues).
    *   [x] Bind application name via `@string/app_name` resource inside `android/app/src/main/AndroidManifest.xml`.
    *   [x] Implement compile-time variables check using `String.fromEnvironment` in `ApiConstants` under `lib/core/network/api_constants.dart`.
*   [x] **Testing & Verification**
    *   [x] Verify compilation success and correct theme loaded
    *   [x] Implement and run startup widget tests

---

## [x] Phase 2: Auth Flow
*   [x] **Token Persistence**
    *   [x] Configure secure storage provider wrapping `FlutterSecureStorage`.
*   [x] **Network Interceptors**
    *   [x] Build request interceptor to append authorization token.
    *   [x] Build response interceptor to intercept `401 Unauthorized` states and trigger logout.
*   [x] **Clean Architecture Layers**
    *   [x] Create pure domain objects (User, UseCases, Repositories interfaces).
    *   [x] Create data mapping objects (UserModel, AuthResponse).
    *   [x] Create Dio remote datasource executing backend endpoints.
    *   [x] Create repository implementations coordinating token storage.
*   [x] **State Management**
    *   [x] Implement `AuthState` sealed structure class.
    *   [x] Create `authProvider` notifier executing login/register/logout use cases.
*   [x] **Form & Inputs Validation**
    *   [x] Re-implement `LoginScreen` using pt-BR validation strings.
    *   [x] Re-implement `RegisterScreen` with matching password checks.
*   [x] **Navigation Redirection**
    *   [x] Add GoRouter guards evaluating auth token validity.
*   [x] **Verification**
    *   [x] Implement and verify state transition unit tests.

---

## [x] Phase 3: Feed, Search & Details
*   [x] **Home / Library Feed**
    *   [x] Construct library grid UI view displaying saved manga covers.
    *   [x] Create library fetcher services pulling content lists from database/API.
*   [x] **Search Interface**
    *   [x] Design search input fields supporting text queries debouncing.
    *   [x] Implement filters and fetch results from proxy.
*   [x] **Manga Details Sheet**
    *   [x] Design blurred cover header backdrop overlays.
    *   [x] Design chapter listing views with sorting methods.
*   [x] **Isar Service hookup**
    *   [x] Instantiate and register Isar instance in main application wrapper.
*   [x] **Verification**
    *   [x] Assert debounce execution limits and cover layouts.

---

## [x] Phase 4: Chapter Reader
*   [x] **Continuous Scroll Mode**
    *   [x] Construct vertical lazy-loader list parsing image page indexes.
    *   [x] Configure caching restrictions, retry buttons, and loaders.
*   [x] **Page View Mode**
    *   [x] Build horizontal viewport layout using Flutter's `PageView`.
*   [x] **Reader Progress tracking**
    *   [x] Map reader gestures to show/hide overlay control tools.
    *   [x] Record current reading page index status inside Riverpod states.
    *   [x] Connect Isar update hooks updating database page percentages upon scrolling or page changes.
    *   [x] Add remote backend sync API service calls updates.

---

## [x] Phase 5: Local Downloads & Offline Mode
*   [x] **Connection Monitoring**
    *   [x] Wire `connectivity_plus` listener updating the reactive Riverpod state.
    *   [x] Build network warning status panels.
    *   [x] Implement Router offline guards automatically blocking remote screens when offline.
*   [x] **Safe Directory Bypass**
    *   [x] Set up downloads folder inside application internal support directory.
    *   [x] Verify the file creation of `.nomedia` file to avoid gallery indexing.
*   [x] **Sequential Download manager**
    *   [x] Implement background thread sequential download queue logic.
    *   [x] Fetch and download chapter image files sequentially via Dio.
    *   [x] Update Isar properties with local disk file strings.
*   [x] **Notification alerts**
    *   [x] Configure `flutter_local_notifications` download status channel.
    *   [x] Push progress notifications updating values as pages download.
    *   [x] Show completion or failure banners when download completes.
*   [x] **Offline Screen**
    *   [x] Create `/offline` fallback page.
    *   [x] Add "Tentar novamente" network check triggers.
    *   [x] Add redirect navigate to `/downloads` option.
