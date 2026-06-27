import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/manga_repository.dart';
import 'manga_feed_state.dart';

final mangaFeedProvider = StateNotifierProvider<MangaFeedNotifier, MangaFeedState>((ref) {
  final repository = ref.watch(mangaRepositoryProvider);
  return MangaFeedNotifier(repository);
});

class MangaFeedNotifier extends StateNotifier<MangaFeedState> {
  final MangaRepository _repository;
  static const int _limit = 12;

  MangaFeedNotifier(this._repository) : super(MangaFeedState.initial()) {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null, hasReachedMax: false);
    try {
      final feed = await _repository.fetchFeed(limit: _limit, offset: 0);
      state = state.copyWith(
        isLoading: false,
        mangas: feed,
        hasReachedMax: feed.length < _limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Não foi possível carregar a biblioteca: $e",
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadMore || state.hasReachedMax) return;
    state = state.copyWith(isLoadMore: true);
    try {
      final feed = await _repository.fetchFeed(limit: _limit, offset: state.mangas.length);
      state = state.copyWith(
        isLoadMore: false,
        mangas: [...state.mangas, ...feed],
        hasReachedMax: feed.length < _limit,
      );
    } catch (_) {
      state = state.copyWith(isLoadMore: false);
    }
  }

  Future<void> refresh() async {
    try {
      final feed = await _repository.fetchFeed(limit: _limit, offset: 0);
      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        mangas: feed,
        errorMessage: null,
        hasReachedMax: feed.length < _limit,
      );
    } catch (_) {
      // Keep old state
    }
  }
}
