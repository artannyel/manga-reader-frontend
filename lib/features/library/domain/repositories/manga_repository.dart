import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/chapter.dart';
import '../entities/manga.dart';
import '../entities/manga_details.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) => throw UnimplementedError());

abstract class MangaRepository {
  Future<List<Manga>> fetchFeed({required int limit, required int offset});
  Future<List<Manga>> searchManga({required String query, required int limit, required int offset});
  Future<MangaDetails> fetchMangaDetails(String id);
  Future<void> toggleFavorite(String id);
  Future<bool> isFavorite(String id);
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data', String? language});
  Future<void> updateReadingProgress(String chapterId, int pageIndex);
  Future<Chapter?> fetchChapter(String chapterId);
}
