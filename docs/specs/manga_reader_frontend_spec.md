# Manga Reader Frontend - Functional Specifications

This specification document outlines the user interface screens, navigation/routing configuration, authentication flows, offline detection rules, and download mechanisms for the Manga Reader Flutter application.

---

## 1. User Interface & Screen Specifications

The application uses a modern, clean design with **Red** as the primary color. **Dark Mode is the default theme**, but Light Mode is supported. **All user interface texts, buttons, messages, alerts, and system notifications are defined in pt-BR (Portuguese BR) by default.**

### 1.1 Authentication Screens
*   **Login Screen (`/login`)**
    *   **Fields**: Email (validated format), Password (minimum 8 characters).
    *   **Actions**: "Entrar" (Sign In) button (triggers Laravel Sanctum authentication), "Criar Conta" (Create Account) link (navigates to `/register`).
    *   **Error Handling**: Inline validation errors; API-based errors (e.g., "Credenciais inválidas" or network issues) displayed via custom SnackBar.
*   **Register Screen (`/register`)**
    *   **Fields**: Name, Email, Password, Confirm Password.
    *   **Actions**: "Cadastrar" (Sign Up) button (calls Laravel backend registration endpoint, auto-logs in upon success), "Voltar para o Login" (Back to Login) link.
    *   **Error Handling**: Validates password match, format, and backend-returned validation messages.

### 1.2 Core Screens (Online Mode)
*   **Home/Library Feed (`/`)**
    *   **Content**: A grid view showing mangas currently tracked by the user (library) or recently read, and a quick-access carousel.
    *   **Visuals**: High-quality manga covers with title overlays, reading progress indicators (e.g., "Cap. 5 - 40% lido" / "Ch. 5 - 40% read"), and a floating action button (FAB) or search bar leading to `/search`.
    *   **Tabs/Categories**: "Todos" (All), "Lendo" (Reading), "Concluídos" (Completed), "Planejo Ler" (Plan to Read).
*   **Search Screen (`/search`)**
    *   **Content**: Search bar with debounced input (500ms delay), genre/tag filters (action, romance, adventure, etc.), and search history list.
    *   **Results**: Proxied through Laravel backend (which acts as a cache and rate-limit buffer for MangaDex API). Results shown in list or grid view with titles, cover thumbnails, and authors.
*   **Manga Details (`/manga/:id`)**
    *   **Content**: Large manga cover header with glassmorphism/gradient effect, title, authors, genres, description/synopsis, and a tabbed view for chapters list.
    *   **Actions**: 
        *   "Adicionar à Biblioteca" (Add to Library) button.
        *   "Começar a Ler" (Start Reading - resumes last read chapter or starts chapter 1).
        *   "Baixar Todos" (Download All) / individual chapter "Baixar" (Download) icon buttons.
    *   **Chapters List**: Sorted chronologically (ascending/descending toggle), showing chapter number, title, publish date, and download status icon (Não Baixado, Na Fila, Baixando, Baixado).
*   **Chapter Reader (`/manga/:id/chapter/:chapterId`)**
    *   **Content**: Immersive fullscreen view of the chapter pages.
    *   **Modes**:
        *   *Vertical Continuous Scroll* (Default): Pages stacked vertically with lazy-loading.
        *   *Horizontal Page View*: Swipe left/right to navigate pages.
    *   **Control Overlay**: Tap center of screen to toggle navigation bars.
        *   *Top Bar*: Back button, Chapter Title, Settings gear.
        *   *Bottom Bar*: Page slider (e.g., 5/22), next/previous chapter buttons.
    *   **Settings Drawer**: Layout mode toggle, image preloading range config, brightness/contrast adjust, double-tap zoom settings.
    *   **Page Rendering**: Constructs image URLs dynamically using `MANGADEX_UPLOADS_URL` (e.g., `https://uploads.mangadex.org/data/{hash}/{filename}`).

### 1.3 Downloads Screen (`/downloads`)
*   **Content**: A dashboard list of all mangas containing downloaded chapters.
*   **Offline Mode Safe**: This screen must remain fully functional when the device is offline.
*   **Manga Download Details (`/downloads/:id`)**: Displays the downloaded chapters list for a specific manga. Tapping a downloaded chapter launches the reader in offline mode.
*   **Active Downloads Manager**: An overlay/bottom-sheet showing active download tasks, current progress percentage, and options to pause/cancel.

### 1.4 Offline Fallback Screen (`/offline`)
*   **Content**: Fullscreen graphic indicating no internet connection.
*   **Actions**:
    *   "Tentar novamente" (Try Again) button (forces connection check and re-attempts loading the blocked route).
    *   "Ir para os downloads" (Go to Downloads) button (directs user to `/downloads` to read offline content).

---

## 2. Routing Configuration & GoRouter Settings

The application utilizes `go_router` for declarative navigation. The router structure supports authentication guards, dynamic path variables, and network status redirection.

```
                  ┌──────────────┐
                  │  App Startup │
                  └──────┬───────┘
                         │
              [Token Present & Valid?]
               /                   \
            Yes                     No
            /                         \
    ┌──────────────┐            ┌──────────────┐
    │  Home (/)    │            │ Login (/login│
    └──────┬───────┘            └──────────────┘
           │
     [Connectivity?]
      /          \
   Online       Offline
    /              \
[Normal Navigation]  ┌─────────────────────────────────┐
                     │ Redirect to /offline            │
                     │ (Except if accessing /downloads)│
                     └─────────────────────────────────┘
```

### 2.1 Route Mapping
| Route Path | Screen / Page Widget | Allowed Offline? | Description |
| :--- | :--- | :--- | :--- |
| `/login` | `LoginScreen` | No | Login form |
| `/register` | `RegisterScreen` | No | Registration form |
| `/` | `HomeScreen` | No (Cached library view metadata only) | Library & home feed |
| `/search` | `SearchScreen` | No | Manga search and filters |
| `/manga/:id` | `MangaDetailsScreen` | Only if manga metadata is synced/downloaded | Detailed manga screen |
| `/manga/:id/chapter/:chapterId` | `ChapterReaderScreen` | Yes (Uses local files if downloaded) | Reading viewer |
| `/downloads` | `DownloadsScreen` | Yes | List of downloaded mangas |
| `/offline` | `OfflineScreen` | Yes | Fallback screen when internet is lost |

### 2.2 Navigation Guards & Redirects
1.  **Authentication Guard (`redirect` callback)**:
    *   Reads token state from authentication Riverpod provider.
    *   If token is empty/expired, and the requested route is NOT `/login` or `/register`, redirect to `/login`.
    *   If token is present and the requested route is `/login` or `/register`, redirect to `/` (Home).
2.  **Connectivity Guard (Reactive Router Redirect)**:
    *   Listens to `ConnectivityStatusProvider`.
    *   If status transitions to `ConnectivityResult.none`:
        *   If the current path is NOT `/offline`, `/downloads`, or `/manga/:id/chapter/:chapterId` (where the chapter has been downloaded), GoRouter redirects to `/offline`.
        *   Saves the attempted route in a fallback variable.
    *   If status transitions back to connected:
        *   Redirects back to the fallback variable or `/` (Home).

---

## 3. Authentication & Token Management Flow

Laravel Sanctum uses persistent bearer tokens for Flutter API access. 

```
                                  [API Request]
                                        │
                         [Is Token Expired / Expiring?]
                          /                        \
                        No                         Yes
                       /                             \
             [Inject Auth Header]           [Clear Storage / Redirect]
                     │                                 │
           ┌──────────────────┐               ┌──────────────────┐
           │ Send to Backend  │               │ GoRouter /login  │
           └────────┬─────────┘               └──────────────────┘
                    │
           [HTTP Response Code]
            /               \
         200 OK          401 Unauthorized
          /                   \
    [Process Data]       [Auth Provider Logout]
```

### 3.1 Authentication Handshake
1.  **User Credentials Entry**: Users log in or register.
2.  **Token Issuance**: Backend returns an API Token (e.g., `{"token": "1|abc123xyz...", "user": {...}}`).
3.  **Secure Storage**: Store the token string inside `flutter_secure_storage`.
4.  **Application State Updates**: Set authenticated user details in the Riverpod `authProvider`.

### 3.2 Dio Interceptor Integration
All outbound HTTP requests (except login/register) pass through an interceptor:
*   **Request Interceptor**:
    *   Reads the token from secure storage.
    *   Appends `Authorization: Bearer <token>` and `Accept: application/json` headers.
*   **Response Interceptor (Token Expiry Handling)**:
    *   If the backend returns an HTTP `401 Unauthorized` response:
        *   Trigger `authProvider.notifier.logout()` to wipe state and secure storage.
        *   GoRouter automatically intercepts the state change and navigates the user to `/login`.
        *   Displays a SnackBar message: "Sessão expirada. Por favor, faça login novamente." ("Session expired. Please log in again.")

---

## 4. Offline Detection & User Experience Behavior

The application monitors connection status dynamically using the `connectivity_plus` package.

### 4.1 Connectivity State Machine
*   **CONNECTED State**:
    *   Regular API calls allowed.
    *   Images loaded from network (`CachedNetworkImage` with fallback).
*   **DISCONNECTED State**:
    *   Redirects network-dependent screens to `/offline`.
    *   Only `/downloads` and `/manga/:id/chapter/:chapterId` (local path) remain accessible.
    *   If a network request is attempted during transient offline states, return a custom `DioException` of type `connectionError` and handle gracefully without crashing.

### 4.2 Offline User Interface Elements
1.  **Offline Screen (`/offline`)**:
    *   *Tentar novamente* (Try Again): Re-runs connection check via `Connectivity().checkConnectivity()`. If positive, triggers GoRouter redirect to previous screen.
    *   *Ir para os downloads* (Go to Downloads): Routes directly to `/downloads`.
2.  **Global Banner Alert**:
    *   A top or bottom persistent red/yellow banner: "Você está offline. Mostrando apenas conteúdo baixado." ("You are offline. Showing downloaded content only.") when navigating inside permitted offline areas.

---

## 5. Download Management & Local Caching Flow

Downloading mangas is a key feature. We bypass MangaDex limits by downloading files, organizing them locally, and restricting access using storage security measures.

```
[Start Download Request]
         │
 [Create Manga & Chapter in Isar]
         │
 [Download Pages Sequentially] ──► [Write Page Image File to Disk]
         │                                       │
 [Update Notification Progress]                 [Update Isar Local Paths]
         │                                       │
 [All Pages Saved?] ◄────────────────────────────┘
    /          \
   No          Yes
  /              \
[Next Page]   [Mark Chapter as Completed in Isar]
              [Show Finished Notification]
```

### 5.1 Step-by-Step Download Lifecycle
1.  **Request Download**: User clicks download on a chapter in `/manga/:id`.
2.  **Isar Storage Entry**: Write/update the chapter record in the local database with `downloadStatus = DownloadStatus.queued`.
3.  **Queue Execution**: A background task queue (singleton service) processes chapters. Only one chapter downloads at a time to prevent server bans and bandwidth exhaustion.
4.  **Fetch Page List**: Backend API returns the page filenames and hash for the chapter.
5.  **Sequential Download**:
    *   Iterate through page URLs: `https://uploads.mangadex.org/data/{hash}/{filename}`.
    *   Download each image via Dio, saving directly to `/app_support_dir/downloads/{mangaId}/{chapterId}/page_{index}.{extension}`.
    *   Update Isar with the local file path list.
6.  **Progress Notification**: Update a system notification with progress details (e.g., "Baixando Capítulo 12: Página 4/20" / "Downloading Chapter 12: Page 4/20").
7.  **Finalization**: Mark status as `downloaded` in Isar. Remove task from queue. Show "Download concluído" ("Download complete") notification.

### 5.2 Storage Organization & Folder Structure
```
/app_support_dir (via getApplicationSupportDirectory)
 └── downloads/
      ├── .nomedia                          <-- Protects images from scanner
      └── {mangaId}/
           ├── cover.png                     <-- Locally cached manga cover
           └── {chapterId}/
                ├── page_001.jpg             <-- Downloaded pages
                ├── page_002.jpg
                └── ...
```
*   **Security & Protection**:
    *   Store all assets in the application's internal data directory (never in public/external storage directories like Gallery or Pictures).
    *   Write a blank `.nomedia` file immediately inside the root `/downloads/` directory when creating it. This instructs Android/iOS system scanners to skip indexing these directories, preventing manga pages from appearing in the user's gallery app.

---

## 6. Environment Configurations (Dev vs. Prod)

The application supports multiple environments to isolate development/testing settings from production endpoints.

### 6.1 Configuration Files
Environment-specific variables are defined in external JSON files located inside the `config/` directory. These files are excluded from version control to protect credentials and backend URLs.
*   **Development Configuration (`config/dev.json`)**: Contains configuration properties for local development, emulator, or staging environments.
*   **Production Configuration (`config/prod.json`)**: Contains configuration properties targeting the production backend service.

### 6.2 Environment Keys
Both files must define the same structure and keys:
*   `API_URL`: The base URL pointing to the Laravel backend API (e.g., `http://10.0.2.2:8000/api` for Android Emulator development, or the production URL).
*   `MANGADEX_UPLOADS_URL`: The domain used to construct manga page image URLs (e.g., `https://uploads.mangadex.org`).

These configurations are injected into the build using `--dart-define-from-file` and resolved dynamically in Dart via `String.fromEnvironment`.

