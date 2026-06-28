import 'package:isar/isar.dart';
import '../../domain/entities/chapter.dart';

part 'chapter_entity.g.dart';


@collection
class ChapterEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mangaDexId;

  @Index()
  late String mangaId; // Points to MangaEntity.mangaDexId

  late String chapterNumber;
  late String title;
  late String language;
  late int pagesCount;
  
  // Local disk paths for the downloaded images
  List<String>? localPagePaths;

  @enumerated
  late DownloadStatus downloadStatus;

  DateTime? downloadedAt;
  
  // Reader Progress Tracking
  late int lastReadPage;
  late double readPercentage;
  
  @Index()
  late DateTime lastReadAt;
}
