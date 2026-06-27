import '../../domain/entities/manga.dart';

class MangaFeedState {
  final List<Manga> mangas;
  final bool isLoading;
  final bool isLoadMore;
  final String? errorMessage;
  final bool hasReachedMax;

  MangaFeedState({
    required this.mangas,
    required this.isLoading,
    required this.isLoadMore,
    this.errorMessage,
    required this.hasReachedMax,
  });

  factory MangaFeedState.initial() => MangaFeedState(
        mangas: [],
        isLoading: true,
        isLoadMore: false,
        errorMessage: null,
        hasReachedMax: false,
      );

  MangaFeedState copyWith({
    List<Manga>? mangas,
    bool? isLoading,
    bool? isLoadMore,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return MangaFeedState(
      mangas: mangas ?? this.mangas,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
