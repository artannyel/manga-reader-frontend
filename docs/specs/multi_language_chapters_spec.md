# Spec-Driven Development: Multi-Language Chapters (Frontend)

This specification defines the frontend changes to support multi-language chapter filtering and metadata resolution.

---

## 1. Manga Details & Chapters Filtering
* **Language Selection UI**:
  * The Manga Details Screen must render a dropdown or chips list showing all available languages (`availableLanguages`) for that manga.
  * Defaults to `pt-br` if present, falls back to `en` if present, falls back to the first language in the list.
* **Filtering Logic**:
  * The displayed chapters list must show only chapters matching the user's selected language.
  * Sorting (ascending/descending) applies to the filtered list.
* **Metadata Translation**:
  * Fallbacks are resolved by the backend (Brazilian Portuguese first, then English, then others), so the frontend will render the strings directly from the response.

---

## 2. API Communication
* **Manga Details JSON Mapping**:
  * The repository must parse `available_languages` from `GET /api/manga/{id}` details response.
* **Chapter Pages JSON Mapping**:
  * When calling `GET /api/chapters/{chapterId}/pages`, the client must forward the selected language in the query parameters as `?language={selectedLanguage}`.
  * This matches the updated backend pages API.

---

## 3. Router and Navigation Updates
* **Optional Query Parameter**:
  * The path `/manga/:id/chapter/:chapterId` must accept an optional query parameter `?language=pt-br`.
  * The `ChapterReaderScreen` must pass this language value to the notifier/provider to request pages in that specific translation.
