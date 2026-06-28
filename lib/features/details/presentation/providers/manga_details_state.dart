import 'package:manga_reader/features/library/domain/entities/manga_details.dart';

class MangaDetailsState {
  final MangaDetails? details;
  final bool isLoading;
  final String? errorMessage;
  final bool isSortAscending;
  final String? selectedLanguage;

  MangaDetailsState({
    this.details,
    required this.isLoading,
    this.errorMessage,
    required this.isSortAscending,
    this.selectedLanguage,
  });

  factory MangaDetailsState.initial() => MangaDetailsState(
        details: null,
        isLoading: true,
        errorMessage: null,
        isSortAscending: true,
        selectedLanguage: null,
      );

  MangaDetailsState copyWith({
    MangaDetails? details,
    bool? isLoading,
    String? errorMessage,
    bool? isSortAscending,
    String? selectedLanguage,
  }) {
    return MangaDetailsState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSortAscending: isSortAscending ?? this.isSortAscending,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
