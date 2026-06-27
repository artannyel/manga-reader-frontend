import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/library/presentation/providers/manga_feed_provider.dart';

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
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data'}) {
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

  group('MangaFeedNotifier Tests -', () {
    test('loads feed data on initialization', () async {
      final mockMangas = List.generate(12, (index) => _createManga(index));
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        expect(limit, 12);
        expect(offset, 0);
        return Future.value(mockMangas);
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation of provider and notifier constructor
      container.read(mangaFeedProvider);
      
      // Initially, the state should be initial (loading)
      expect(container.read(mangaFeedProvider).isLoading, true);

      // Wait for fetchFeed to complete
      await pumpEventQueue();

      final state = container.read(mangaFeedProvider);
      expect(state.isLoading, false);
      expect(state.mangas, mockMangas);
      expect(state.hasReachedMax, false);
    });

    test('handles error on initialization', () async {
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        return Future.error('Error fetching feed');
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation
      container.read(mangaFeedProvider);

      await pumpEventQueue();

      final state = container.read(mangaFeedProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('Não foi possível carregar a biblioteca: Error fetching feed'));
      expect(state.mangas, isEmpty);
    });

    test('loads more data (pagination limit/offsets) successfully', () async {
      final initialFeed = List.generate(12, (index) => _createManga(index));
      final nextPageFeed = List.generate(5, (index) => _createManga(index + 12));

      int callCount = 0;
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        callCount++;
        if (callCount == 1) {
          expect(offset, 0);
          return Future.value(initialFeed);
        } else {
          expect(offset, 12);
          expect(limit, 12);
          return Future.value(nextPageFeed);
        }
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation
      container.read(mangaFeedProvider);

      await pumpEventQueue(); // Wait for initial load

      final notifier = container.read(mangaFeedProvider.notifier);
      final loadMoreFuture = notifier.loadMore();

      // Check loading more state
      expect(container.read(mangaFeedProvider).isLoadMore, true);

      await loadMoreFuture;

      final state = container.read(mangaFeedProvider);
      expect(state.isLoadMore, false);
      expect(state.mangas.length, 17);
      expect(state.mangas.sublist(0, 12), initialFeed);
      expect(state.mangas.sublist(12), nextPageFeed);
      expect(state.hasReachedMax, true); // 5 elements < 12
    });

    test('does not load more if hasReachedMax is true', () async {
      final initialFeed = List.generate(5, (index) => _createManga(index)); // Less than 12, so hasReachedMax = true
      int callCount = 0;
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        callCount++;
        return Future.value(initialFeed);
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation
      container.read(mangaFeedProvider);

      await pumpEventQueue();

      expect(container.read(mangaFeedProvider).hasReachedMax, true);
      expect(callCount, 1);

      final notifier = container.read(mangaFeedProvider.notifier);
      await notifier.loadMore();

      // callCount should still be 1, because hasReachedMax is true
      expect(callCount, 1);
    });

    test('supports refreshing feed data', () async {
      final initialFeed = List.generate(12, (index) => _createManga(index));
      final refreshedFeed = List.generate(12, (index) => _createManga(index + 100));

      int callCount = 0;
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        callCount++;
        if (callCount == 1) {
          return Future.value(initialFeed);
        } else {
          expect(offset, 0);
          return Future.value(refreshedFeed);
        }
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger lazy instantiation
      container.read(mangaFeedProvider);

      await pumpEventQueue(); // Wait for initial load
      expect(container.read(mangaFeedProvider).mangas, initialFeed);

      final notifier = container.read(mangaFeedProvider.notifier);
      await notifier.refresh();

      final state = container.read(mangaFeedProvider);
      expect(state.mangas, refreshedFeed);
      expect(state.hasReachedMax, false);
    });
  });
}
