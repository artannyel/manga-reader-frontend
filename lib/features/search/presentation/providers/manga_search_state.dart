import 'package:manga_reader/features/library/domain/entities/manga.dart';

class MangaSearchState {
  final String query;
  final List<Manga> mangas;
  final bool isLoading;
  final String? errorMessage;

  MangaSearchState({
    required this.query,
    required this.mangas,
    required this.isLoading,
    this.errorMessage,
  });

  factory MangaSearchState.initial() => MangaSearchState(
        query: '',
        mangas: [],
        isLoading: false,
        errorMessage: null,
      );

  MangaSearchState copyWith({
    String? query,
    List<Manga>? mangas,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MangaSearchState(
      query: query ?? this.query,
      mangas: mangas ?? this.mangas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
