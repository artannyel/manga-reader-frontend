import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/library/data/models/manga_entity.dart';
import '../../features/library/data/models/chapter_entity.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('isarServiceProvider was not overridden in ProviderScope');
});

class IsarService {
  final Isar isar;

  IsarService(this.isar);

  static Future<IsarService> init() async {
    final dir = await getApplicationSupportDirectory();
    final isarInstance = await Isar.open(
      [
        MangaEntitySchema,
        ChapterEntitySchema,
      ],
      directory: dir.path,
    );
    return IsarService(isarInstance);
  }
}
