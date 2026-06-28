import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'chapter_reader_state.dart';

class ChapterReaderParam {
  final String chapterId;
  final String? language;

  const ChapterReaderParam({
    required this.chapterId,
    this.language,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterReaderParam &&
          runtimeType == other.runtimeType &&
          chapterId == other.chapterId &&
          language == other.language;

  @override
  int get hashCode => chapterId.hashCode ^ language.hashCode;
}

final chapterReaderProvider = StateNotifierProvider.family<ChapterReaderNotifier, ChapterReaderState, ChapterReaderParam>((ref, param) {
  final repository = ref.watch(mangaRepositoryProvider);
  return ChapterReaderNotifier(repository, param);
});

class ChapterReaderNotifier extends StateNotifier<ChapterReaderState> {
  final MangaRepository _repository;
  final ChapterReaderParam _param;
  Timer? _progressSyncTimer;

  ChapterReaderNotifier(this._repository, this._param) : super(const ChapterReaderState()) {
    loadPages();
  }

  Future<void> loadPages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final chapter = await _repository.fetchChapter(_param.chapterId);
      final title = chapter?.title ?? 'Capítulo';
      final initialPage = chapter?.lastReadPage ?? 0;

      final pages = await _repository.fetchChapterPages(_param.chapterId, language: _param.language);

      state = state.copyWith(
        isLoading: false,
        pages: pages,
        currentPageIndex: initialPage.clamp(0, pages.isEmpty ? 0 : pages.length - 1),
        title: title,
      );
    } catch (e) {
      String errorMsg = "Falha ao carregar as páginas do capítulo: $e";
      if (e is DioException) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData.containsKey('message')) {
          final msg = responseData['message'];
          if (msg is String) {
            errorMsg = msg;
          }
        }
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
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
      _repository.updateReadingProgress(_param.chapterId, clampedIndex);
    });
  }

  void toggleLayoutMode() {
    state = state.copyWith(isHorizontalLayout: !state.isHorizontalLayout);
  }

  @override
  void dispose() {
    if (_progressSyncTimer != null && _progressSyncTimer!.isActive) {
      _repository.updateReadingProgress(_param.chapterId, state.currentPageIndex);
      _progressSyncTimer!.cancel();
    }
    super.dispose();
  }
}
