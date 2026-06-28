import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/library/presentation/providers/manga_feed_provider.dart';
import 'manga_details_state.dart';

final mangaDetailsProvider = StateNotifierProvider.family<MangaDetailsNotifier, MangaDetailsState, String>((ref, mangaId) {
  final repository = ref.watch(mangaRepositoryProvider);
  return MangaDetailsNotifier(repository, mangaId, ref);
});

class MangaDetailsNotifier extends StateNotifier<MangaDetailsState> {
  final MangaRepository _repository;
  final String _mangaId;
  final Ref _ref;

  MangaDetailsNotifier(this._repository, this._mangaId, this._ref) : super(MangaDetailsState.initial()) {
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final details = await _repository.fetchMangaDetails(_mangaId);
      String? defaultLang;
      if (details.availableLanguages.isNotEmpty) {
        if (details.availableLanguages.contains('pt-br')) {
          defaultLang = 'pt-br';
        } else if (details.availableLanguages.contains('pt')) {
          defaultLang = 'pt';
        } else if (details.availableLanguages.contains('en')) {
          defaultLang = 'en';
        } else {
          defaultLang = details.availableLanguages.first;
        }
      }
      state = state.copyWith(
        isLoading: false,
        details: details,
        selectedLanguage: defaultLang,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Falha ao carregar detalhes do mangá: $e",
      );
    }
  }

  Future<void> toggleFavorite() async {
    final details = state.details;
    if (details == null) return;

    try {
      await _repository.toggleFavorite(_mangaId);
      final isFav = await _repository.isFavorite(_mangaId);
      
      final updatedManga = details.manga.copyWith(isFavorite: isFav);
      final updatedDetails = MangaDetails(
        manga: updatedManga,
        chapters: details.chapters,
        availableLanguages: details.availableLanguages,
        descriptions: details.descriptions,
      );
      
      state = state.copyWith(details: updatedDetails);
      _ref.invalidate(mangaFeedProvider);
    } catch (_) {
      // Ignore or handle
    }
  }

  void toggleSortOrder() {
    state = state.copyWith(isSortAscending: !state.isSortAscending);
  }

  void changeLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }
}
