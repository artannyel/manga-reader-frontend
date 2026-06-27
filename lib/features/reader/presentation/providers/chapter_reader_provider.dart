import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'chapter_reader_state.dart';

final chapterReaderProvider = StateNotifierProvider.family<ChapterReaderNotifier, ChapterReaderState, String>((ref, chapterId) {
  final repository = ref.watch(mangaRepositoryProvider);
  return ChapterReaderNotifier(repository, chapterId);
});

class ChapterReaderNotifier extends StateNotifier<ChapterReaderState> {
  final MangaRepository _repository;
  final String _chapterId;
  Timer? _progressSyncTimer;

  ChapterReaderNotifier(this._repository, this._chapterId) : super(const ChapterReaderState()) {
    loadPages();
  }

  Future<void> loadPages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final chapter = await _repository.fetchChapter(_chapterId);
      final title = chapter?.title ?? 'Capítulo';
      final initialPage = chapter?.lastReadPage ?? 0;

      final pages = await _repository.fetchChapterPages(_chapterId);

      state = state.copyWith(
        isLoading: false,
        pages: pages,
        currentPageIndex: initialPage.clamp(0, pages.isEmpty ? 0 : pages.length - 1),
        title: title,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Falha ao carregar as páginas do capítulo: $e",
      );
    }
  }

  void setPage(int pageIndex) {
    if (state.pages.isEmpty) return;
    final clampedIndex = pageIndex.clamp(0, state.pages.length - 1);
    
    if (state.currentPageIndex == clampedIndex) return;

    state = state.copyWith(currentPageIndex: clampedIndex);

    // Cancel the previous timer to debounce the backend/local DB write
    _progressSyncTimer?.cancel();

    // Debounce/Throttle progress saving by 1.5 seconds to prevent scroll lag
    _progressSyncTimer = Timer(const Duration(milliseconds: 1500), () {
      _repository.updateReadingProgress(_chapterId, clampedIndex);
    });
  }

  void toggleLayoutMode() {
    state = state.copyWith(isHorizontalLayout: !state.isHorizontalLayout);
  }

  @override
  void dispose() {
    if (_progressSyncTimer != null && _progressSyncTimer!.isActive) {
      _repository.updateReadingProgress(_chapterId, state.currentPageIndex);
      _progressSyncTimer!.cancel();
    }
    super.dispose();
  }
}
