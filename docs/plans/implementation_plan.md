# Manga Reader Frontend - Implementation Plan

This document outlines the step-by-step development process for the Manga Reader Flutter application, structured into five logical phases to ensure clean architecture and regression-free delivery.

---

## Phase 1: Core Setup, Routing & Theme
Set up the base architecture, state management framework, routing engine, and UI design styling guidelines. All UI texts, error handling, offline alerts, and notification copy will be in pt-BR (Portuguese BR) by default.

### 1.1 Actions
1.  **Dependencies Setup**: Add packages in `pubspec.yaml`:
    *   `flutter_riverpod` (state management)
    *   `go_router` (declarative routing)
    *   `dio` (network requests client)
    *   `flutter_secure_storage` (secure storage for auth tokens)
    *   `isar` / `isar_flutter_libs` (local offline database)
    *   `connectivity_plus` (network status detection)
    *   `flutter_local_notifications` (push and local notifications)
    *   `path_provider` (system directory helper)
    *   `cached_network_image` (cached image renderer)
2.  **Core Directory Structures**: Create the folders inside `lib/core/` (router, network, theme, services, widgets, utils).
3.  **Theme Configuration**:
    *   Implement Red-focused color schema (light and default dark mode) in `lib/core/theme/app_theme.dart`.
    *   Configure font styling, button shapes, and default transition animations.
4.  **Router Configuration**:
    *   Initialize GoRouter in `lib/core/router/app_router.dart`.
    *   Configure path strings and map placeholders for Login, Home, Search, Details, Reader, Downloads, and Offline pages.

### 1.2 Verification
*   Compile the project successfully.
*   Toggle system dark/light modes and ensure the default theme displays red highlights correctly.
*   Navigate between placeholder screens using GoRouter paths to confirm routing paths work.

---

## Phase 2: Auth Flow
Connect authentication screens to the Riverpod state notifier and the Dio client to handle Sanctum persistent tokens.

### 2.1 Actions
1.  **Storage Interface**: Set up `secureStorageProvider` for reading and writing tokens.
2.  **Dio Interceptor Setup**:
    *   Create request interceptor to fetch the local token and attach it as a Bearer authorization header.
    *   Create response interceptor to intercept `401 Unauthorized` responses and trigger forced logout.
3.  **Authentication State**:
    *   Define `AuthState` models (User entity, loading status, credentials, errors).
    *   Create the `AuthNotifier` extending `StateNotifier` without code generation.
4.  **UI Construction**:
    *   Implement `/login` and `/register` views using the global red theme.
    *   Connect fields to validate inputs and bind buttons to `AuthNotifier` functions.
5.  **GoRouter Guard Implementation**:
    *   Add redirect handlers checks inside GoRouter configuration depending on token validity.

### 2.2 Verification
*   Run the app: confirm it automatically redirects to `/login` if no token is saved.
*   Perform registration: confirm user is auto-logged in, token is stored, and UI redirects to `/`.
*   Simulate a `401 Unauthorized` error (e.g., manually expire the token on backend) and confirm the app logs the user out and redirects them back to `/login` with the pt-BR warning message ("Sessão expirada. Por favor, faça login novamente.").

---

## Phase 3: Feed, Search & Details
Implement content discovery by building the Home/Library, search filters, and manga information sheets.

### 3.1 Actions
1.  **Library Feed (`/`)**:
    *   Build layout grid containing manga covers.
    *   Create library notifier fetching tracked user mangas from the backend API.
2.  **Search Module (`/search`)**:
    *   Build search bar with 500ms debounce to prevent hitting rate limits during typing.
    *   Add tag filters grid.
    *   Connect the UI to the backend proxy search endpoint.
3.  **Manga Details Page (`/manga/:id`)**:
    *   Design cover art overlay header with blur/glassmorphism effect.
    *   Render manga description, authors, category tags, and list of chapters.
    *   Implement chronological sorting action button for chapter items.
4.  **Isar Service Hookup**:
    *   Initialize the Isar service inside `main.dart`.
    *   Generate models schema files.

### 3.2 Verification
*   Search for a manga, verify that requests are sent only 500ms after the user stops typing.
*   Verify that search results load covers and sync metadata properly.
*   Navigate to manga details and check that the description is readable and chapter sorting toggles correctly.

---

## Phase 4: Chapter Reader
Render the chapter contents in a high-performance immersive viewer supporting dynamic page requests.

### 4.1 Actions
1.  **Page Construction Helper**: Create utility functions constructing full page URLs dynamically pointing to the configured `MANGADEX_UPLOADS_URL`.
2.  **Continuous Vertical Scroll View**:
    *   Build list views using lazy-loading images via `CachedNetworkImage`.
    *   Add memory cache size limits and custom loaders/error fallbacks.
3.  **Horizontal Page Slider**:
    *   Build horizontal PageView swipe layout.
4.  **Reader State Notifier**:
    *   Track active page index.
    *   Record page reading progress percentage (e.g., `(currentPage / totalPages) * 100`).
    *   Report and save progress inside local database (Isar) and periodically sync with Laravel backend.
5.  **Control Overlay Drawer**:
    *   Implement center screen tap gesture to slide in settings and chapter controls.

### 4.2 Verification
*   Launch a chapter reader, scroll down, and check that images fetch and render smoothly.
*   Toggle settings drawer, check that reader layout shifts between horizontal and vertical modes.
*   Exit the reader and re-open it to verify reading progress (e.g., starting at page 5) is preserved.

---

## Phase 5: Local Downloads & Offline Mode
Protect download paths, run download workers, and support offline fallback navigation.

### 5.1 Actions
1.  **Connectivity Engine (`connectivity_plus`)**:
    *   Create a reactive stream tracking online/offline states.
    *   Configure GoRouter redirects: if offline and user attempts to access any route besides `/downloads` or `/manga/:id/chapter/:chapterId` (where the chapter has been downloaded), force redirect to `/offline`.
2.  **Download Directory Setup**:
    *   Locate target directory using `path_provider` support folder.
    *   Create `downloads/` directory and immediately write a `.nomedia` file to avoid systems media indexing.
3.  **Sequential Download Queue**:
    *   Build single-job executor handling chapter page image downloads sequentially.
    *   Update Isar database status from `queued` to `downloading`, then to `downloaded` with local file paths mapped.
4.  **Local Notifications Integrator**:
    *   Link download manager to `flutter_local_notifications`.
    *   Send and update channel notifications reflecting download percentage status.
5.  **Offline Screen Layout**:
    *   Design `/offline` view in pt-BR (incorporating "Tentar novamente" and "Ir para os downloads" buttons/texts).
    *   Bind "Tentar novamente" action checking network status and triggering router return.

### 5.2 Verification
*   Initiate chapter download: verify notification appears in pt-BR with progress percentage updates (e.g., "Baixando Capítulo...").
*   Check local filesystem (via simulator or file browser) to verify the `.nomedia` file exists and download images exist in the isolated support folder.
*   Turn on Airplane mode (simulate offline status):
    *   Verify the app immediately redirects to `/offline` if on a remote page.
    *   Verify the user can access `/downloads` and read pre-downloaded chapters without any network connection.
