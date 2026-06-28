# Task Checklist: Multi-Language Chapters (Frontend)

- [ ] **Phase 1: Domain Entities & Model Updates**
  - [ ] Add `availableLanguages` list to `MangaDetails` class.
  - [ ] Parse `available_languages` from details response in `MangaRepositoryImpl@fetchMangaDetails`.
  - [ ] Support passing optional `language` in pages fetch repository & datasource calls.

- [ ] **Phase 2: State Management & Navigation**
  - [ ] Add `selectedLanguage` to `MangaDetailsState` and select default (`pt-br` -> `en` -> first).
  - [ ] Implement `changeLanguage(String lang)` in `MangaDetailsNotifier`.
  - [ ] Pass `language` query parameter inside `app_router.dart` for the reader route.
  - [ ] Create `ChapterReaderParam` composite parameters class and update `chapterReaderProvider` family signature.

- [ ] **Phase 3: Presentation UI Updates**
  - [ ] Add language selector Dropdown on `MangaDetailsScreen`.
  - [ ] Filter chapters in UI by `selectedLanguage`.
  - [ ] Append selected language query parameter to GoRouter reader route transitions.

- [ ] **Phase 4: Verification & Testing**
  - [ ] Update mocks and provider test suites.
  - [ ] Execute `flutter test` and check for compiling and passing results.
