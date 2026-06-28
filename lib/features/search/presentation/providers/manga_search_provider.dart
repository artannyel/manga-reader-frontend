import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'manga_search_state.dart';

final mangaSearchProvider = StateNotifierProvider<MangaSearchNotifier, MangaSearchState>((ref) {
  final repository = ref.watch(mangaRepositoryProvider);
  return MangaSearchNotifier(repository);
});

class MangaSearchNotifier extends StateNotifier<MangaSearchState> {
  final MangaRepository _repository;
  Timer? _debounceTimer;
  static const int _limit = 20;

  MangaSearchNotifier(this._repository) : super(MangaSearchState.initial());

  void onQueryChanged(String query) {
    if (query == state.query) return;

    state = state.copyWith(query: query, hasReachedMax: false, isLoading: true);

    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(mangas: [], isLoading: false, hasReachedMax: false, errorMessage: null);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await _repository.searchManga(query: query, limit: _limit, offset: 0);
      if (state.query == query) {
        state = state.copyWith(
          isLoading: false,
          mangas: results,
          hasReachedMax: results.length < _limit,
        );
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Erro ao buscar mangás: $e",
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadMore || state.hasReachedMax) return;

    final query = state.query;
    state = state.copyWith(isLoadMore: true, errorMessage: null);
    try {
      final results = await _repository.searchManga(
        query: query,
        limit: _limit,
        offset: state.mangas.length,
      );
      if (state.query == query) {
        state = state.copyWith(
          isLoadMore: false,
          mangas: [...state.mangas, ...results],
          hasReachedMax: results.length < _limit,
        );
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(
          isLoadMore: false,
          errorMessage: "Erro ao buscar mangás: $e",
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
