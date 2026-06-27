# Manga Reader Frontend - SDD Implementation Checklist

This checklist tracks the implementation of features for the Manga Reader Flutter application across all five planned phases.

---

## [ ] Phase 1: Core Setup, Routing & Theme
*   [ ] **1.1 Project Dependencies**
    *   [ ] Add `flutter_riverpod` and state management packages to `pubspec.yaml`.
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
*   [x] **Testing & Verification**
    *   [x] Verify compilation success and correct theme loaded
    *   [x] Implement and run startup widget tests

---

## [ ] Phase 2: Auth Flow
*   [ ] **2.1 Token persistence setup**
    *   [ ] Create `SecureStorageService` instance.
    *   [ ] Add helper functions to read, save, and wipe string tokens.
*   [ ] **2.2 Network Interceptor**
    *   [ ] Create `DioClient` provider class.
    *   [ ] Implement request headers injection interceptor for `Authorization: Bearer <token>`.
    *   [ ] Implement response `401 Unauthorized` interceptor forcing session cleanup.
*   [ ] **2.3 Authentication States**
    *   [ ] Create `AuthUser` data models.
    *   [ ] Define Riverpod states enum representing authentication progress.
    *   [ ] Implement `AuthNotifier` logic handling Login and Register API queries.
*   [ ] **2.4 Screens & Integration**
    *   [ ] Design login screen widget inputs (email, password validation).
    *   [ ] Design registration screen forms.
    *   [ ] Integrate `authProvider` to control UI loaders and display dialogs.
    *   [ ] Wire GoRouter redirect filters based on authentication state values.

---

## [ ] Phase 3: Feed, Search & Details
*   [ ] **3.1 Home / Library Feed**
    *   [ ] Construct library grid UI view displaying saved manga covers.
    *   [ ] Create library fetcher services pulling content lists from database/API.
*   [ ] **3.2 Search Interface**
    *   [ ] Construct Search input interface with genre filtering buttons.
    *   [ ] Add debounce utility timer delay to trigger API requests 500ms after text typing stops.
    *   [ ] Render search result list views.
*   [ ] **3.3 Details View**
    *   [ ] Create blurred cover background detail viewport.
    *   [ ] Render title, description, genres, and chronological list of chapters.
    *   [ ] Implement favorite toggle button mapping details directly into library tracking list.
*   [ ] **3.4 Database Initialization**
    *   [ ] Setup Isar service initialization config.
    *   [ ] Define `MangaEntity` schema entity code.
    *   [ ] Define `ChapterEntity` schema entity code.
    *   [ ] Generate database model helpers schema.

---

## [ ] Phase 4: Chapter Reader
*   [ ] **4.1 Chapter Loading & URL Assembly**
    *   [ ] Create dynamic URL builder parsing chapter image paths using `MANGADEX_UPLOADS_URL`.
*   [ ] **4.2 Continuous Scroll Mode**
    *   [ ] Construct vertical lazy-loader list parsing image page indexes.
    *   [ ] Configure caching restrictions, retry buttons, and loaders.
*   [ ] **4.3 Page View Mode**
    *   [ ] Build horizontal viewport layout using Flutter's `PageView`.
*   [ ] **4.4 Reader Progress tracking**
    *   [ ] Map reader gestures to show/hide overlay control tools.
    *   [ ] Record current reading page index status inside Riverpod states.
    *   [ ] Connect Isar update hooks updating database page percentages upon scrolling or page changes.
    *   [ ] Add remote backend sync API service calls updates.

---

## [ ] Phase 5: Local Downloads & Offline Mode
*   [ ] **5.1 Connection Monitoring**
    *   [ ] Wire `connectivity_plus` listener updating the reactive Riverpod state.
    *   [ ] Build network warning status panels.
    *   [ ] Implement Router offline guards automatically blocking remote screens when offline.
*   [ ] **5.2 Safe Directory Bypass**
    *   [ ] Set up downloads folder inside application internal support directory.
    *   [ ] Verify the file creation of `.nomedia` file to avoid gallery indexing.
*   [ ] **5.3 Sequential Download manager**
    *   [ ] Implement background thread sequential download queue logic.
    *   [ ] Fetch and download chapter image files sequentially via Dio.
    *   [ ] Update Isar properties with local disk file strings.
*   [ ] **5.4 Notification alerts**
    *   [ ] Configure `flutter_local_notifications` download status channel.
    *   [ ] Push progress notifications updating values as pages download.
    *   [ ] Show completion or failure banners when download completes.
*   [ ] **5.5 Offline Screen**
    *   [ ] Create `/offline` fallback page.
    *   [ ] Add "Try Again" network check triggers.
    *   [ ] Add redirect navigate to `/downloads` option.
