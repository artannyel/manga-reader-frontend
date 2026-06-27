enum DownloadStatus {
  notDownloaded,
  queued,
  downloading,
  downloaded,
  failed
}

class Chapter {
  final String id;
  final String mangaId;
  final String chapterNumber;
  final String title;
  final int pagesCount;
  final DownloadStatus downloadStatus;
  final List<String>? localPagePaths;
  final int lastReadPage;
  final double readPercentage;
  final DateTime? lastReadAt;

  const Chapter({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.title,
    required this.pagesCount,
    required this.downloadStatus,
    this.localPagePaths,
    required this.lastReadPage,
    required this.readPercentage,
    this.lastReadAt,
  });

  Chapter copyWith({
    String? id,
    String? mangaId,
    String? chapterNumber,
    String? title,
    int? pagesCount,
    DownloadStatus? downloadStatus,
    List<String>? localPagePaths,
    int? lastReadPage,
    double? readPercentage,
    DateTime? lastReadAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      pagesCount: pagesCount ?? this.pagesCount,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      localPagePaths: localPagePaths ?? this.localPagePaths,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      readPercentage: readPercentage ?? this.readPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}
