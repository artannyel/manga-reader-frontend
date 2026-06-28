# Implementation Plan: Multi-Language Chapters (Frontend)

This plan describes the frontend implementation steps to support displaying a language selector on the details screen and requesting language-specific chapter pages.

---

## Phase 1: Domain Entities & Model Updates
1. **Domain Entity Update**:
   * Add `final List<String> availableLanguages;` to `MangaDetails` class.
2. **Repository Mapping**:
   * Update `MangaRepositoryImpl@fetchMangaDetails` to extract `available_languages` list from backend API response and map it to `MangaDetails`.
   * For offline fallback, calculate `availableLanguages` dynamically using `.map((c) => c.language).toSet().toList()`.
3. **Repository Page Query Update**:
   * Update signature of `MangaRepository@fetchChapterPages` to accept `String? language`.
   * Pass the `language` query parameter inside `MangaRemoteDataSource@fetchChapterPages`.

## Phase 2: State Management & Navigation
1. **Manga Details State**:
   * Add `String? selectedLanguage` to `MangaDetailsState`.
   * When loading finishes, resolve default language: `pt-br` -> `pt` -> `en` -> first available.
   * Add `changeLanguage(String lang)` action to `MangaDetailsNotifier`.
2. **App Router Update**:
   * Update route `/manga/:id/chapter/:chapterId` inside `app_router.dart` to read `language` query parameter and forward it to `ChapterReaderScreen`.
3. **Chapter Reader Provider**:
   * Update `chapterReaderProvider` family parameter to a custom parameter class `ChapterReaderParam` containing both `chapterId` and `language`.
   * Forward `language` parameter in the repository page lookup call.

## Phase 3: Presentation UI Updates
1. **Details Screen Language Selector**:
   * Render a clean `DropdownButton` or chips selector on `MangaDetailsScreen` under the cover title card if `availableLanguages` contains more than 1 language.
   * Selecting a language calls `changeLanguage(newLang)`.
   * Filter the list of displayed chapters using `chapter.language == selectedLanguage`.
2. **Chapter Navigation from Details**:
   * When pushing to the reader route, include the selected language as a query parameter (e.g. `?language=pt-br`).

## Phase 4: Verification & Testing
1. **Verify Unit Tests**:
   * Update existing mocks and provider test suites.
   * Run `flutter test` to ensure all tests pass.
