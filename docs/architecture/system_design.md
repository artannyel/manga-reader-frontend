# Manga Reader Frontend - System Design

This document details the system design, folder structure, database entities, state management providers, and platform integrations for the Manga Reader Flutter application.

---

## 1. Clean Architecture by Features - Folder Structure

The project implements Clean Architecture organized around high-level features. Reusable components and shared services are located in `lib/core/`. **The application uses pt-BR (Portuguese BR) by default for all user-facing interface text, buttons, alerts, and notification contents.**

### 1.1 Structural Layout
```
lib/
 ├── core/                              <-- Shared/Common Code
 │    ├── network/                      <-- Dio, Interceptors, API Client, Connectivity
 │    ├── router/                       <-- GoRouter setup, Guards
 │    ├── theme/                        <-- Theme Data (Red Theme, Dark/Light modes)
 │    ├── services/                     <-- Isar, PathProvider, Local Notifications
 │    ├── widgets/                      <-- Reusable global UI widgets (buttons, text fields)
 │    └── utils/                        <-- Helpers and Extensions
 └── features/                          <-- Feature Modules
      ├── auth/                         <-- Authentication feature
      ├── library/                      <-- Home library and feed
      ├── search/                       <-- Search and exploration
      ├── details/                      <-- Manga and chapter details
      ├── reader/                       <-- Immersive chapter reading
      └── downloads/                    <-- Local storage & offline manager
```

### 1.2 Feature Module Architecture
Each module under `lib/features/{feature_name}/` is split into three layers:

```
                  ┌──────────────────────────────────────────────┐
                  │                 PRESENTATION                 │
                  │   UI Widgets, Screens, StateNotifier/State   │
                  └──────────────┬───────────────────▲───────────┘
                                 │                   │
                     Uses Repository Interface  Emits Immutable State
                                 │                   │
                  ┌──────────────▼───────────────────┴───────────┐
                  │                    DOMAIN                    │
                  │   Entities, Use Cases, Repository Interface  │
                  └──────────────┬───────────────────▲───────────┘
                                 │                   │
                    Implements Interface       Provides Entities
                                 │                   │
                  ┌──────────────▼───────────────────┴───────────┐
                  │                     DATA                     │
                  │   Models (DTOs), Data Sources, Repo Impl     │
                  └──────────────────────────────────────────────┘
```

1.  **Domain Layer**:
    *   `entities/`: Pure Dart representation of data consumed by UI.
    *   `repositories/`: Abstract contract definitions of operations.
2.  **Data Layer**:
    *   `models/`: JSON serialization models, extending/mapping to entities.
    *   `datasources/`: Remote (Dio-based APIs) and Local (Isar-based caching).
    *   `repositories/`: Implementations of Domain repositories, coordinating local vs remote strategies.
3.  **Presentation Layer**:
    *   `screens/`: Main viewport screen widgets.
    *   `widgets/`: Feature-specific smaller components.
    *   `providers/`: Riverpod `StateNotifier` or `Notifier` classes orchestrating UI state.

---

## 2. State Management (Riverpod Providers Dependency)

We use `flutter_riverpod` (classic `StateNotifier` and `Notifier` style, without code generation).

### 2.1 Provider Declarations and Relationships

```
              ┌──────────────────────────┐
              │  connectivityProvider    │
              └────────────┬─────────────┘
                           │ Listened to by
                           ▼
 ┌──────────────┐     ┌──────────────┐
 │ secureStorage│     │ isarServiceProvider
 └──────┬───────┘     └──────┬───────┘
        │ Inject             │ Inject
        ▼                    ▼
 ┌──────────────┐     ┌──────────────┐
 │ dioProvider  │     │ localRepoImpl│
 └──────┬───────┘     └──────┬───────┘
        │ Inject             │ Inject
        ▼                    ▼
 ┌──────────────┐     ┌──────────────┐
 │  authProvider│     │ downloadQueue│
 └──────────────┘     └──────┬───────┘
                             │ Listened to by
                             ▼
                      ┌──────────────┐
                      │ downloadProv │
                      └──────────────┘
```

*   **`connectivityProvider`** (StreamProvider):
    *   Listens to `connectivity_plus` broadcast streams and emits `ConnectivityResult`.
*   **`secureStorageProvider`** (Provider):
    *   Returns a singleton instance of `FlutterSecureStorage`.
*   **`dioProvider`** (Provider):
    *   Provides the configured `Dio` client, injecting the authentication token read from `secureStorageProvider`.
*   **`authProvider`** (StateNotifierProvider):
    *   Manages the current user authentication state (`Unauthenticated`, `Authenticating`, `Authenticated`, `AuthenticationFailed`).
    *   Depends on `dioProvider` and `secureStorageProvider` to perform HTTP calls and persist credentials.
*   **`isarServiceProvider`** (Provider):
    *   Asynchronously initializes and exposes the Isar database singleton instance.
*   **`mangaDetailsProvider(mangaId)`** (StateNotifierProvider.family):
    *   Loads details of a specific manga. Merges backend data (if online) with local download metadata.
*   **`downloadQueueProvider`** (StateNotifierProvider):
    *   Maintains the active and queued downloading chapters list. Coordinates path directories, fetches, and notifies updates.

---

## 3. Local Offline Database (Isar Entity Schemas)

Isar is chosen for high-performance object persistence.

### 3.1 `MangaEntity` Schema
Represents metadata of mangas stored locally for offline tracking or downloads.

```dart
import 'package:isar/isar.dart';

part 'manga_entity.g.dart';

@collection
class MangaEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mangaDexId;

  late String title;
  late String? description;
  late String coverUrl;
  String? localCoverPath;
  
  late bool isFavorite;
  late DateTime lastSyncedAt;
}
```

### 3.2 `ChapterEntity` Schema
Represents a chapter of a manga, containing download files status and local disk file locations.

```dart
import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@collection
class ChapterEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mangaDexId;

  @Index()
  late String mangaId; // Points to MangaEntity.mangaDexId

  late String chapterNumber;
  late String title;
  late int pagesCount;
  
  // Local disk paths for the downloaded images
  List<String>? localPagePaths;

  @enumerated
  late DownloadStatus downloadStatus;

  DateTime? downloadedAt;
  
  // Reader Progress Tracking
  late int lastReadPage;
  late double readPercentage;
  late DateTime lastReadAt;
}

enum DownloadStatus {
  notDownloaded,
  queued,
  downloading,
  downloaded,
  failed
}
```

---

## 4. Storage Architecture & Directory Protection

To prevent downloaded manga chapters from cluttering the device gallery, we follow a strict directory structure using the application documents directory combined with system bypass configurations.

### 4.1 Storage Layout
```
/var/mobile/Containers/Data/Application/UUID/Library/Application Support/ (iOS)
/data/user/0/com.example.manga_reader/files/ (Android)
 └── downloads/
      ├── .nomedia
      └── manga_abc123/
           ├── cover.jpg
           └── chapter_xyz789/
                ├── page_001.jpg
                └── page_002.jpg
```

### 4.2 `.nomedia` File Creation Architecture
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileProtectionService {
  Future<Directory> getDownloadsDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final downloadsDir = Directory('${supportDir.path}/downloads');
    
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    // Create the hidden media scanner bypass file
    final nomediaFile = File('${downloadsDir.path}/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }
    
    return downloadsDir;
  }
}
```

---

## 5. System Notifications Progress Architecture

We use `flutter_local_notifications` to provide native feedback when chapter downloads run in the background. All notification texts are in pt-BR by default.

### 5.1 Progress Notification Mechanism
*   **Unique Notifications Channel**: Initialize a dedicated channel for downloading processes.
    *   *ID*: `"manga_downloads_channel"`
    *   *Name*: `"Manga Downloads"`
    *   *Description*: `"Notifications for manga chapters download progress."`
    *   *Importance*: `Importance.low` (prevents sound/vibration popping on every single progress increment).
*   **Dynamic Notification ID**: Match the notification ID directly to the integer ID of the `ChapterEntity` inside Isar. This allows modifying, updating, or clearing notifications for individual chapters concurrently.
*   **Progress Update Throttle**: Avoid flooding the OS notification manager. Limit notification progress updates to **at most once per second** or **every 5% change in completion progress**.

```
[Chapter Download Triggered]
            │
  [Create Notification ID = chapter.id]
  [Show Notification: "Iniciando download..." ("Starting Download...")]
            │
            ├─────────► [Download Page]
            │               │
     [Throttle Check] ◄─────┘
      /            \
 [Skip Update]   [Update progress bar on notification: "Baixando Capítulo X: Página Y/Z"]
      │                     │
      ├─────────────────────┘
      │
[All Pages Downloaded?]
  /                \
 Leave                Yes
  /                  \
[Next Page]      [Update Notification: "Capítulo X: Download concluído" ("Chapter X Download Completed")]
                 [Auto-cancel after 3 seconds or keep persistent]
```

---

## 6. Build Configurations & Product Flavors (Android)

To manage separate environments on Android, the project utilizes Gradle Product Flavors combined with Flutter's compiler-level definitions.

### 6.1 Gradle Product Flavors (`android/app/build.gradle`)
The application defines a single flavor dimension `"default"` containing two distinct flavors (`dev` and `prod`). Each flavor is customized with separate package IDs (application ID suffix) and application names to allow installing both versions side-by-side on the same device.

```groovy
android {
    ...
    flavorDimensions "default"

    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "Manga Reader Dev"
        }
        prod {
            dimension "default"
            // Production maps to the base applicationId (e.g., com.example.manga_reader)
            resValue "string", "app_name", "Manga Reader"
        }
    }
}
```

#### Android Manifest Integration
To dynamically resolve the app name according to the active build flavor, `android/app/src/main/AndroidManifest.xml` must map its label attribute to the generated resource value:
```xml
<application
    android:label="@string/app_name"
    ... >
```

### 6.2 Flutter `--dart-define-from-file` Compilation Setup
During compilation, Flutter reads custom configurations from JSON files and injects them as global environment variables.

#### CLI Execution Commands
*   **Run/Build Development Mode**:
    ```bash
    flutter run --flavor dev --dart-define-from-file=config/dev.json
    flutter build apk --flavor dev --dart-define-from-file=config/dev.json
    ```
*   **Run/Build Production Mode**:
    ```bash
    flutter run --flavor prod --dart-define-from-file=config/prod.json
    flutter build apk --flavor prod --dart-define-from-file=config/prod.json
    ```

#### Dart Configuration Mapping (`ApiConstants`)
A dedicated configuration class reads these variables from the environment at compile-time:
```dart
class ApiConstants {
  static const String backendUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api', // Fallback for dev emulator
  );

  static const String mangadexUploadsUrl = String.fromEnvironment(
    'MANGADEX_UPLOADS_URL',
    defaultValue: 'https://uploads.mangadex.org',
  );
}
```
