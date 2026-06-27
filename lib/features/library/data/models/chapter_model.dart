import '../../domain/entities/chapter.dart';

class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.mangaId,
    required super.chapterNumber,
    required super.title,
    required super.pagesCount,
    required super.downloadStatus,
    super.localPagePaths,
    required super.lastReadPage,
    required super.readPercentage,
    super.lastReadAt,
  });

  factory ChapterModel.fromJson(
    Map<String, dynamic> json,
    String mangaId, {
    DownloadStatus downloadStatus = DownloadStatus.notDownloaded,
    List<String>? localPagePaths,
    int lastReadPage = 0,
    double readPercentage = 0.0,
    DateTime? lastReadAt,
  }) {
    return ChapterModel(
      id: json['id'] as String,
      mangaId: mangaId,
      chapterNumber: json['chapter_number'] as String? ?? '',
      title: json['title'] as String? ?? 'Capítulo ${json['chapter_number'] ?? ""}',
      pagesCount: json['pages_count'] as int? ?? 0,
      downloadStatus: downloadStatus,
      localPagePaths: localPagePaths,
      lastReadPage: lastReadPage,
      readPercentage: readPercentage,
      lastReadAt: lastReadAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'title': title,
      'pages_count': pagesCount,
    };
  }
}
