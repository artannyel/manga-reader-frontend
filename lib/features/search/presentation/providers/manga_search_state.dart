import 'package:manga_reader/features/library/domain/entities/manga.dart';

class MangaSearchState {
  final String query;
  final List<Manga> mangas;
  final bool isLoading;
  final bool isLoadMore;
  final bool hasReachedMax;
  final String? errorMessage;

  MangaSearchState({
    required this.query,
    required this.mangas,
    required this.isLoading,
    required this.isLoadMore,
    required this.hasReachedMax,
    this.errorMessage,
  });

  factory MangaSearchState.initial() => MangaSearchState(
        query: '',
        mangas: [],
        isLoading: false,
        isLoadMore: false,
        hasReachedMax: false,
        errorMessage: null,
      );

  MangaSearchState copyWith({
    String? query,
    List<Manga>? mangas,
    bool? isLoading,
    bool? isLoadMore,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return MangaSearchState(
      query: query ?? this.query,
      mangas: mangas ?? this.mangas,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }
}
