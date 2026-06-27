# Project-Scoped Rules: Manga Reader Frontend

This project implements a Flutter mobile application that communicates with our Laravel backend to manage and read mangas.

## Architectural Rules

1. **Clean Architecture by Features**:
   - Code must be organized inside `lib/features/<feature_name>/` using three distinct layers:
     - `data/`: Datasources, Models, and Repository implementations.
     - `domain/`: Entities, Repository interfaces, and Use Cases.
     - `presentation/`: Riverpod Providers, Pages, and Widgets.
   - Cross-cutting concerns and shared features reside under `lib/core/` (e.g. `lib/core/network/`, `lib/core/router/`, `lib/core/theme/`, `lib/core/widgets/`, `lib/core/services/`).

2. **State Management & DI**:
   - Use **Flutter Riverpod** (classic StateNotifier or Notifier style, without code generation).
   - Avoid global variables; use providers for dependencies and configuration.

3. **Networking & Router**:
   - Use **Dio** for HTTP requests with custom interceptors to handle Sanctum persistent Bearer Tokens.
   - Use **GoRouter** for declarative navigation.

4. **UI/UX Design Guidelines**:
   - Modern, clean, and responsive interface.
   - Primary color: **Red**.
   - Theme options: Support Light and Dark themes, with **Dark Theme as default**.

5. **Offline & Download Strategy**:
   - Use **connectivity_plus** to monitor internet connectivity in real-time.
   - If offline, only the "Downloads/Offline Area" is accessible. Other screens must show a "No internet connection" screen with options: "Try again" and "Go to downloaded mangas".
   - Use **Isar** (or Hive) as the local NoSQL database to save downloaded manga metadata (title, cover_filename, description, list of downloaded chapters).
   - Downloaded chapters must be saved as local files in the app's **internal documents directory** (private, using `path_provider`).
   - Create a `.nomedia` file in the downloads folder to hide images from the system gallery.
   - Show a **system notification with a progress bar** when starting and updating a chapter download (using `flutter_local_notifications`).

## Agent Specialist Roles

1. **Architecture & Planning Agent (architect)**: Responsible for writing frontend system designs, routing maps, riverpod state flows, implementation plans, and checklists.
2. **Coder Agent (coder)**: Responsible for writing Clean Architecture Dart code, configuring GoRouter, Riverpod providers, Dio, Isar database, and views.
3. **Reviewer Agent (reviewer)**: Responsible for auditing the code against Clean Architecture layering, strict Dart linting rules, security, and state management guidelines.
4. **Tester Agent (tester)**: Responsible for writing unit, widget, and integration tests using Flutter's test frameworks, ensuring mock services are utilized.
