class ChapterReaderState {
  final bool isLoading;
  final String? errorMessage;
  final List<String> pages;
  final int currentPageIndex;
  final bool isHorizontalLayout;
  final String title;

  const ChapterReaderState({
    this.isLoading = false,
    this.errorMessage,
    this.pages = const [],
    this.currentPageIndex = 0,
    this.isHorizontalLayout = true,
    this.title = '',
  });

  ChapterReaderState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? pages,
    int? currentPageIndex,
    bool? isHorizontalLayout,
    String? title,
  }) {
    return ChapterReaderState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isHorizontalLayout: isHorizontalLayout ?? this.isHorizontalLayout,
      title: title ?? this.title,
    );
  }

  ChapterReaderState clearError() {
    return ChapterReaderState(
      isLoading: isLoading,
      errorMessage: null,
      pages: pages,
      currentPageIndex: currentPageIndex,
      isHorizontalLayout: isHorizontalLayout,
      title: title,
    );
  }
}
