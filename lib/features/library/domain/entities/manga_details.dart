import 'manga.dart';
import 'chapter.dart';

class MangaDetails {
  final Manga manga;
  final List<Chapter> chapters;
  final List<String> availableLanguages;
  final Map<String, String> descriptions;

  const MangaDetails({
    required this.manga,
    required this.chapters,
    required this.availableLanguages,
    required this.descriptions,
  });
}
