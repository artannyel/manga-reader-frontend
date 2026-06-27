import 'package:isar/isar.dart';

part 'manga_entity.g.dart';

@collection
class MangaEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mangaDexId;

  @Index()
  late String title;

  late String? description;
  late String coverUrl;
  String? localCoverPath;
  
  @Index()
  late bool isFavorite;

  late DateTime lastSyncedAt;
}
