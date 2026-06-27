---
name: coder
description: Skill for writing high-quality Clean Architecture Flutter code, using Riverpod, GoRouter, Dio, and Isar database.
---

# Coder Skill (Frontend)

This skill is used to implement frontend features.

## Guidelines

1. **Clean Architecture Structure**:
   - Strictly separate code into `data/`, `domain/`, and `presentation/` within each feature folder.
   - Use Data sources in the data layer to perform API calls with Dio. Map raw JSON responses to Models, and expose Repository implementations.
   - Use Repository interfaces and Use Cases in the domain layer to handle clean entities and business rules.
   - Use StateNotifiers or Notifiers in presentation layer to manage UI states, binding them to Pages and Widgets.

2. **UI & Theme**:
   - Follow red primary branding guidelines.
   - Implement Theme switching with dark mode set as default.
   - Use clean, modular widget trees, separating large widgets into smaller functional widgets.

3. **Offline & Downloads**:
   - Monitor connection state via connectivity_plus.
   - Save chapter image files into the app's secure local documents directory.
   - Write a `.nomedia` file to the download directory to prevent galleries from index-scanning the images.
   - Save manga metadata (title, cover, description, chapters) to Isar/Hive.
   - Trigger progress notifications via flutter_local_notifications during downloads.
