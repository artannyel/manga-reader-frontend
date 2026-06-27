import 'manga.dart';
import 'chapter.dart';

class MangaDetails {
  final Manga manga;
  final List<Chapter> chapters;

  const MangaDetails({
    required this.manga,
    required this.chapters,
  });
}
