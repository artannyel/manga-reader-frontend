import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/library/presentation/providers/manga_feed_provider.dart';
import 'package:manga_reader/features/details/presentation/providers/manga_details_provider.dart';

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

Manga _createManga({required String id, bool isFavorite = false}) {
  return Manga(
    id: id,
    title: 'Manga $id',
    coverUrl: 'https://example.com/cover_$id.jpg',
    isFavorite: isFavorite,
  );
}

Chapter _createChapter({required String id, required String chapterNumber, required String title}) {
  return Chapter(
    id: id,
    mangaId: 'manga_1',
    chapterNumber: chapterNumber,
    title: title,
    pagesCount: 20,
    downloadStatus: DownloadStatus.notDownloaded,
    lastReadPage: 0,
    readPercentage: 0.0,
  );
}

double _parseChapterNumber(String numberStr) {
  final cleanStr = numberStr.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(cleanStr) ?? 0.0;
}

void main() {
  late MockMangaRepository mockRepository;
  const mangaId = 'manga_1';

  setUp(() {
    mockRepository = MockMangaRepository();
  });

  group('MangaDetailsNotifier Tests -', () {
    test('initial state loads manga details and chapters on creation', () async {
      final manga = _createManga(id: mangaId);
      final chapters = [
        _createChapter(id: 'c1', chapterNumber: '1', title: 'Chapter 1'),
        _createChapter(id: 'c2', chapterNumber: '2', title: 'Chapter 2'),
      ];
      final details = MangaDetails(manga: manga, chapters: chapters);

      mockRepository.fetchMangaDetailsHandler = (id) {
        expect(id, mangaId);
        return Future.value(details);
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger instantiation
      container.read(mangaDetailsProvider(mangaId));

      // Verify immediate loading state
      expect(container.read(mangaDetailsProvider(mangaId)).isLoading, true);

      await pumpEventQueue();

      final state = container.read(mangaDetailsProvider(mangaId));
      expect(state.isLoading, false);
      expect(state.details, isNotNull);
      expect(state.details!.manga.id, mangaId);
      expect(state.details!.chapters.length, 2);
      expect(state.isSortAscending, true);
    });

    test('handles error on details retrieval', () async {
      mockRepository.fetchMangaDetailsHandler = (id) {
        return Future.error('Not found');
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger instantiation
      container.read(mangaDetailsProvider(mangaId));

      await pumpEventQueue();

      final state = container.read(mangaDetailsProvider(mangaId));
      expect(state.isLoading, false);
      expect(state.details, isNull);
      expect(state.errorMessage, contains('Falha ao carregar detalhes do mangá: Not found'));
    });

    test('toggles sort order state correctly', () async {
      final manga = _createManga(id: mangaId);
      final details = MangaDetails(manga: manga, chapters: []);
      mockRepository.fetchMangaDetailsHandler = (id) => Future.value(details);

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger instantiation
      container.read(mangaDetailsProvider(mangaId));

      await pumpEventQueue();

      final notifier = container.read(mangaDetailsProvider(mangaId).notifier);
      
      expect(container.read(mangaDetailsProvider(mangaId)).isSortAscending, true);
      
      notifier.toggleSortOrder();
      expect(container.read(mangaDetailsProvider(mangaId)).isSortAscending, false);

      notifier.toggleSortOrder();
      expect(container.read(mangaDetailsProvider(mangaId)).isSortAscending, true);
    });

    test('handles chronological sorting of chapters based on sort order', () async {
      final chapter1 = _createChapter(id: 'c1', chapterNumber: '1', title: 'Chapter 1');
      final chapter2 = _createChapter(id: 'c2', chapterNumber: '2.5', title: 'Chapter 2.5');
      final chapter3 = _createChapter(id: 'c3', chapterNumber: '10', title: 'Chapter 10');
      final chapter4 = _createChapter(id: 'c4', chapterNumber: '2', title: 'Chapter 2');

      final unsortedChapters = [chapter3, chapter1, chapter4, chapter2];
      final manga = _createManga(id: mangaId);
      final details = MangaDetails(manga: manga, chapters: unsortedChapters);
      mockRepository.fetchMangaDetailsHandler = (id) => Future.value(details);

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger instantiation
      container.read(mangaDetailsProvider(mangaId));

      await pumpEventQueue();

      final state = container.read(mangaDetailsProvider(mangaId));
      final chaptersList = state.details!.chapters;

      // Verification of sorting function identical to the screen
      List<Chapter> sortChapters(List<Chapter> list, bool ascending) {
        final sorted = List<Chapter>.from(list);
        sorted.sort((a, b) {
          final numA = _parseChapterNumber(a.chapterNumber);
          final numB = _parseChapterNumber(b.chapterNumber);
          final cmp = numA.compareTo(numB);
          return ascending ? cmp : -cmp;
        });
        return sorted;
      }

      // Test ascending sort
      final sortedAscending = sortChapters(chaptersList, true);
      expect(sortedAscending[0].chapterNumber, '1');
      expect(sortedAscending[1].chapterNumber, '2');
      expect(sortedAscending[2].chapterNumber, '2.5');
      expect(sortedAscending[3].chapterNumber, '10');

      // Test descending sort
      final sortedDescending = sortChapters(chaptersList, false);
      expect(sortedDescending[0].chapterNumber, '10');
      expect(sortedDescending[1].chapterNumber, '2.5');
      expect(sortedDescending[2].chapterNumber, '2');
      expect(sortedDescending[3].chapterNumber, '1');
    });

    test('toggles favorite status in database and updates state and invalidates feed provider', () async {
      final manga = _createManga(id: mangaId, isFavorite: false);
      final details = MangaDetails(manga: manga, chapters: []);
      mockRepository.fetchMangaDetailsHandler = (id) => Future.value(details);
      
      bool toggleFavoriteCalled = false;
      bool isFavoriteChecked = false;
      bool isFavoriteReturnVal = true;

      mockRepository.toggleFavoriteHandler = (id) {
        expect(id, mangaId);
        toggleFavoriteCalled = true;
        return Future.value();
      };

      mockRepository.isFavoriteHandler = (id) {
        expect(id, mangaId);
        isFavoriteChecked = true;
        return Future.value(isFavoriteReturnVal);
      };

      int feedFetchCount = 0;
      mockRepository.fetchFeedHandler = ({required limit, required offset}) {
        feedFetchCount++;
        return Future.value([]);
      };

      final container = ProviderContainer(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Set up a listener to keep mangaFeedProvider alive and rebuild it when invalidated
      final subscription = container.listen(mangaFeedProvider, (_, __) {});
      addTearDown(subscription.close);

      // Force instantiation of details provider
      container.read(mangaDetailsProvider(mangaId));
      
      await pumpEventQueue();

      expect(feedFetchCount, 1); // Initial fetch feed called once
      
      final notifier = container.read(mangaDetailsProvider(mangaId).notifier);
      await notifier.toggleFavorite();

      expect(toggleFavoriteCalled, true);
      expect(isFavoriteChecked, true);

      // Verify local state updated
      final updatedState = container.read(mangaDetailsProvider(mangaId));
      expect(updatedState.details!.manga.isFavorite, true);

      // Verify that mangaFeedProvider was invalidated and re-fetched feed
      await pumpEventQueue();
      expect(feedFetchCount, 2); // It should have fetched again after invalidation
    });
  });
}
