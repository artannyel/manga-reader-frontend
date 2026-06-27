import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/reader/presentation/providers/chapter_reader_provider.dart';
import 'package:manga_reader/features/reader/presentation/providers/chapter_reader_state.dart';

class MockMangaRepository implements MangaRepository {
  Future<Chapter?> Function(String chapterId)? fetchChapterHandler;
  Future<List<String>> Function(String chapterId, {String quality})? fetchChapterPagesHandler;
  Future<void> Function(String chapterId, int pageIndex)? updateReadingProgressHandler;

  @override
  Future<List<Manga>> fetchFeed({required int limit, required int offset}) => throw UnimplementedError();

  @override
  Future<List<Manga>> searchManga({required String query, required int limit, required int offset}) => throw UnimplementedError();

  @override
  Future<MangaDetails> fetchMangaDetails(String id) => throw UnimplementedError();

  @override
  Future<void> toggleFavorite(String id) => throw UnimplementedError();

  @override
  Future<bool> isFavorite(String id) => throw UnimplementedError();

  @override
  Future<Chapter?> fetchChapter(String chapterId) {
    if (fetchChapterHandler != null) {
      return fetchChapterHandler!(chapterId);
    }
    return Future.value(null);
  }

  @override
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data'}) {
    if (fetchChapterPagesHandler != null) {
      return fetchChapterPagesHandler!(chapterId, quality: quality);
    }
    return Future.value([]);
  }

  @override
  Future<void> updateReadingProgress(String chapterId, int pageIndex) {
    if (updateReadingProgressHandler != null) {
      return updateReadingProgressHandler!(chapterId, pageIndex);
    }
    return Future.value();
  }
}

void main() {
  late MockMangaRepository mockRepository;

  setUp(() {
    mockRepository = MockMangaRepository();
  });

  group('ChapterReaderNotifier Tests -', () {
    test('initializes, calls fetchChapterPages, and updates state with page list', () async {
      final mockPages = ['page1.jpg', 'page2.jpg', 'page3.jpg'];
      final mockChapter = Chapter(
        id: 'chapter_1',
        mangaId: 'manga_1',
        chapterNumber: '1',
        title: 'Test Chapter Title',
        pagesCount: 3,
        downloadStatus: DownloadStatus.notDownloaded,
        lastReadPage: 1,
        readPercentage: 0.0,
      );

      mockRepository.fetchChapterHandler = (chapterId) {
        expect(chapterId, 'chapter_1');
        return Future.value(mockChapter);
      };

      mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) {
        expect(chapterId, 'chapter_1');
        return Future.value(mockPages);
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation of provider and notifier constructor
      final stateBeforeLoad = container.read(chapterReaderProvider('chapter_1'));
      expect(stateBeforeLoad.isLoading, true);

      // Wait for all async operations to finish
      await pumpEventQueue();

      final stateAfterLoad = container.read(chapterReaderProvider('chapter_1'));
      expect(stateAfterLoad.isLoading, false);
      expect(stateAfterLoad.pages, mockPages);
      expect(stateAfterLoad.currentPageIndex, 1); // clamped(0, 2) from lastReadPage
      expect(stateAfterLoad.title, 'Test Chapter Title');
      expect(stateAfterLoad.errorMessage, isNull);
    });

    test('handles error gracefully when loading pages fails', () async {
      mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
      mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) {
        return Future.error('Network Error');
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation of provider
      container.read(chapterReaderProvider('chapter_1'));

      // Wait for loadPages to run and finish
      await pumpEventQueue();

      final state = container.read(chapterReaderProvider('chapter_1'));
      expect(state.isLoading, false);
      expect(state.pages, isEmpty);
      expect(state.errorMessage, contains('Falha ao carregar as páginas do capítulo: Network Error'));
    });

    test('changing page index (setPage) updates progress and schedules write after 1.5 seconds', () {
      fakeAsync((async) {
        final mockPages = ['page1.jpg', 'page2.jpg', 'page3.jpg'];
        mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
        mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) => Future.value(mockPages);

        int updateProgressCallCount = 0;
        int? lastUpdatedPageIndex;
        mockRepository.updateReadingProgressHandler = (chapterId, pageIndex) {
          updateProgressCallCount++;
          lastUpdatedPageIndex = pageIndex;
          return Future.value();
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(chapterReaderProvider('chapter_1').notifier);
        
        // Complete initial load
        async.elapse(const Duration(milliseconds: 10)); 
        
        expect(container.read(chapterReaderProvider('chapter_1')).currentPageIndex, 0);

        // Change page to 2
        notifier.setPage(2);

        // State updates immediately
        expect(container.read(chapterReaderProvider('chapter_1')).currentPageIndex, 2);
        expect(updateProgressCallCount, 0); // Not called yet (debounced by 1500ms)

        // Advance 1.0 second (less than 1.5s)
        async.elapse(const Duration(seconds: 1));
        expect(updateProgressCallCount, 0);

        // Advance another 0.6 seconds (total 1.6s)
        async.elapse(const Duration(milliseconds: 600));
        expect(updateProgressCallCount, 1);
        expect(lastUpdatedPageIndex, 2);
      });
    });

    test('successive setPage calls debounce/reset the progress sync timer', () {
      fakeAsync((async) {
        final mockPages = ['page1.jpg', 'page2.jpg', 'page3.jpg'];
        mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
        mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) => Future.value(mockPages);

        int updateProgressCallCount = 0;
        int? lastUpdatedPageIndex;
        mockRepository.updateReadingProgressHandler = (chapterId, pageIndex) {
          updateProgressCallCount++;
          lastUpdatedPageIndex = pageIndex;
          return Future.value();
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(chapterReaderProvider('chapter_1').notifier);
        async.elapse(const Duration(milliseconds: 10)); // Complete initial load

        // Change to page 1
        notifier.setPage(1);
        
        // Advance 1.0 second
        async.elapse(const Duration(seconds: 1));
        expect(updateProgressCallCount, 0);

        // Change to page 2 (resets the timer)
        notifier.setPage(2);

        // Advance 1.0 second from second call (total 2.0s from first call)
        async.elapse(const Duration(seconds: 1));
        expect(updateProgressCallCount, 0); // Still 0, because second timer has not elapsed 1.5s yet

        // Advance another 0.6 seconds (1.6s from second call)
        async.elapse(const Duration(milliseconds: 600));
        expect(updateProgressCallCount, 1); // Called only once
        expect(lastUpdatedPageIndex, 2); // With index 2
      });
    });

    test('swapping layout modes (toggleLayoutMode) successfully updates layout state', () async {
      mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
      mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) => Future.value([]);

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(chapterReaderProvider('chapter_1').notifier);
      await pumpEventQueue();

      // Initial layout mode (by default isHorizontalLayout = true)
      expect(container.read(chapterReaderProvider('chapter_1')).isHorizontalLayout, true);

      // Toggle layout mode
      notifier.toggleLayoutMode();
      expect(container.read(chapterReaderProvider('chapter_1')).isHorizontalLayout, false);

      // Toggle again
      notifier.toggleLayoutMode();
      expect(container.read(chapterReaderProvider('chapter_1')).isHorizontalLayout, true);
    });

    test('calling dispose() on notifier immediately flushes/saves progress if sync timer is active', () {
      fakeAsync((async) {
        final mockPages = ['page1.jpg', 'page2.jpg', 'page3.jpg'];
        mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
        mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) => Future.value(mockPages);

        int updateProgressCallCount = 0;
        int? lastUpdatedPageIndex;
        mockRepository.updateReadingProgressHandler = (chapterId, pageIndex) {
          updateProgressCallCount++;
          lastUpdatedPageIndex = pageIndex;
          return Future.value();
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final notifier = container.read(chapterReaderProvider('chapter_1').notifier);
        async.elapse(const Duration(milliseconds: 10)); // Complete initial load

        // Change page to 2 (starts progress timer)
        notifier.setPage(2);
        expect(updateProgressCallCount, 0);

        // Dispose container/notifier (which triggers notifier's dispose method)
        container.dispose();

        // Progress should be saved immediately, even before 1.5 seconds have passed
        expect(updateProgressCallCount, 1);
        expect(lastUpdatedPageIndex, 2);

        // Make sure no more updates are triggered when time advances
        async.elapse(const Duration(seconds: 2));
        expect(updateProgressCallCount, 1);
      });
    });

    test('dispose does not save progress if sync timer is not active', () {
      fakeAsync((async) {
        final mockPages = ['page1.jpg', 'page2.jpg', 'page3.jpg'];
        mockRepository.fetchChapterHandler = (chapterId) => Future.value(null);
        mockRepository.fetchChapterPagesHandler = (chapterId, {quality = 'data'}) => Future.value(mockPages);

        int updateProgressCallCount = 0;
        mockRepository.updateReadingProgressHandler = (chapterId, pageIndex) {
          updateProgressCallCount++;
          return Future.value();
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        container.read(chapterReaderProvider('chapter_1').notifier);
        async.elapse(const Duration(milliseconds: 10)); // Complete initial load

        // Dispose container (no page changes, so sync timer is not active)
        container.dispose();

        // updateReadingProgress should not have been called
        expect(updateProgressCallCount, 0);
      });
    });
  });
}
