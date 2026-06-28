import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/search/presentation/providers/manga_search_provider.dart';
import 'package:fake_async/fake_async.dart';

class MockMangaRepository implements MangaRepository {
  Future<List<Manga>> Function({required int limit, required int offset})? fetchFeedHandler;
  Future<List<Manga>> Function({required String query, required int limit, required int offset})? searchMangaHandler;
  Future<MangaDetails> Function(String id)? fetchMangaDetailsHandler;
  Future<void> Function(String id)? toggleFavoriteHandler;
  Future<bool> Function(String id)? isFavoriteHandler;

  @override
  Future<List<Manga>> fetchFeed({required int limit, required int offset}) {
    if (fetchFeedHandler != null) {
      return fetchFeedHandler!(limit: limit, offset: offset);
    }
    throw UnimplementedError('fetchFeedHandler not set');
  }

  @override
  Future<List<Manga>> searchManga({required String query, required int limit, required int offset}) {
    if (searchMangaHandler != null) {
      return searchMangaHandler!(query: query, limit: limit, offset: offset);
    }
    throw UnimplementedError('searchMangaHandler not set');
  }

  @override
  Future<MangaDetails> fetchMangaDetails(String id) {
    if (fetchMangaDetailsHandler != null) {
      return fetchMangaDetailsHandler!(id);
    }
    throw UnimplementedError('fetchMangaDetailsHandler not set');
  }

  @override
  Future<void> toggleFavorite(String id) {
    if (toggleFavoriteHandler != null) {
      return toggleFavoriteHandler!(id);
    }
    return Future.value();
  }

  @override
  Future<bool> isFavorite(String id) {
    if (isFavoriteHandler != null) {
      return isFavoriteHandler!(id);
    }
    return Future.value(false);
  }

  @override
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data', String? language}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateReadingProgress(String chapterId, int pageIndex) {
    return Future.value();
  }

  @override
  Future<Chapter?> fetchChapter(String chapterId) {
    throw UnimplementedError();
  }
}

Manga _createManga(int index) {
  return Manga(
    id: 'manga_$index',
    title: 'Manga $index',
    coverUrl: 'https://example.com/cover_$index.jpg',
    isFavorite: false,
  );
}

void main() {
  late MockMangaRepository mockRepository;

  setUp(() {
    mockRepository = MockMangaRepository();
  });

  group('MangaSearchNotifier Tests -', () {
    test('initial state is correct', () {
      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(mangaSearchProvider);
      expect(state.query, '');
      expect(state.mangas, isEmpty);
      expect(state.isLoading, false);
      expect(state.isLoadMore, false);
      expect(state.hasReachedMax, false);
      expect(state.errorMessage, isNull);
    });

    test('onQueryChanged immediately updates query state but debounces repository call', () {
      fakeAsync((async) {
        int searchCallCount = 0;
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          searchCallCount++;
          return Future.value([]);
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);
        
        notifier.onQueryChanged('One Piece');
        
        // Immediately updates the query
        expect(container.read(mangaSearchProvider).query, 'One Piece');
        expect(searchCallCount, 0); // Not called yet

        // Advance 400ms (debounce is 500ms)
        async.elapse(const Duration(milliseconds: 400));
        expect(searchCallCount, 0); // Still not called

        // Advance another 150ms (total 550ms)
        async.elapse(const Duration(milliseconds: 150));
        expect(searchCallCount, 1); // Called once
      });
    });

    test('debounces multiple successive query changes', () {
      fakeAsync((async) {
        int searchCallCount = 0;
        String lastSearchedQuery = '';
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          searchCallCount++;
          lastSearchedQuery = query;
          return Future.value([]);
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);

        notifier.onQueryChanged('O');
        async.elapse(const Duration(milliseconds: 200));

        notifier.onQueryChanged('On');
        async.elapse(const Duration(milliseconds: 200));

        notifier.onQueryChanged('One');
        async.elapse(const Duration(milliseconds: 600)); // Enough to trigger

        expect(searchCallCount, 1);
        expect(lastSearchedQuery, 'One');
      });
    });

    test('clears results and does not search when query becomes empty', () {
      fakeAsync((async) {
        int searchCallCount = 0;
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          searchCallCount++;
          return Future.value([]);
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);

        // First search for something to populate
        notifier.onQueryChanged('Naruto');
        async.elapse(const Duration(milliseconds: 600));
        expect(searchCallCount, 1);

        // Now clear it
        notifier.onQueryChanged('');
        expect(container.read(mangaSearchProvider).query, '');
        expect(container.read(mangaSearchProvider).mangas, isEmpty);

        async.elapse(const Duration(seconds: 1));
        expect(searchCallCount, 1); // No new search call
      });
    });

    test('executes search successfully and updates state', () {
      fakeAsync((async) {
        final results = [
          _createManga(1),
          _createManga(2),
        ];

        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          expect(query, 'Bleach');
          expect(limit, 20);
          expect(offset, 0);
          return Future.value(results);
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);
        notifier.onQueryChanged('Bleach');

        async.elapse(const Duration(milliseconds: 550));
        async.flushMicrotasks();

        final state = container.read(mangaSearchProvider);
        expect(state.isLoading, false);
        expect(state.mangas, results);
        expect(state.hasReachedMax, true);
        expect(state.errorMessage, isNull);
      });
    });

    test('handles search error correctly', () {
      fakeAsync((async) {
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          return Future.error('API Error');
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);
        notifier.onQueryChanged('Bleach');

        async.elapse(const Duration(milliseconds: 550));
        async.flushMicrotasks();

        final state = container.read(mangaSearchProvider);
        expect(state.isLoading, false);
        expect(state.mangas, isEmpty);
        expect(state.errorMessage, contains('Erro ao buscar mangás: API Error'));
      });
    });

    test('loadMore successfully appends results and updates hasReachedMax', () {
      fakeAsync((async) {
        final firstPage = List.generate(20, (i) => _createManga(i));
        final secondPage = List.generate(5, (i) => _createManga(20 + i));

        int searchCallCount = 0;
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          searchCallCount++;
          if (offset == 0) {
            return Future.value(firstPage);
          } else {
            return Future.value(secondPage);
          }
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);
        
        // 1. Initial search
        notifier.onQueryChanged('Bleach');
        async.elapse(const Duration(milliseconds: 550));
        async.flushMicrotasks();

        var state = container.read(mangaSearchProvider);
        expect(state.mangas.length, 20);
        expect(state.hasReachedMax, false);

        // 2. Load more
        notifier.loadMore();
        
        state = container.read(mangaSearchProvider);
        expect(state.isLoadMore, true);

        async.flushMicrotasks();
        
        state = container.read(mangaSearchProvider);
        expect(state.isLoadMore, false);
        expect(state.mangas.length, 25);
        expect(state.mangas.sublist(0, 20), firstPage);
        expect(state.mangas.sublist(20), secondPage);
        expect(state.hasReachedMax, true);
        expect(searchCallCount, 2);
      });
    });

    test('loadMore does not execute if isLoading, isLoadMore, or hasReachedMax is true', () {
      fakeAsync((async) {
        int searchCallCount = 0;
        mockRepository.searchMangaHandler = ({required query, required limit, required offset}) {
          searchCallCount++;
          return Future.value([]);
        };

        final container = ProviderContainer(
          overrides: [
            mangaRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(mangaSearchProvider.notifier);

        // Case 1: isLoading is true (still waiting for initial search)
        notifier.onQueryChanged('Bleach');
        notifier.loadMore();
        expect(searchCallCount, 0);

        // Complete the initial search (hasReachedMax will become true since results = [])
        async.elapse(const Duration(milliseconds: 550));
        async.flushMicrotasks();
        expect(searchCallCount, 1);
        expect(container.read(mangaSearchProvider).hasReachedMax, true);

        // Case 2: hasReachedMax is true
        notifier.loadMore();
        expect(searchCallCount, 1);
      });
    });
  });
}
