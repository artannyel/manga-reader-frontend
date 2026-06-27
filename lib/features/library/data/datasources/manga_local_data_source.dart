import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../models/manga_entity.dart';
import '../models/chapter_entity.dart';
import '../../domain/entities/chapter.dart';

final mangaLocalDataSourceProvider = Provider<MangaLocalDataSource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return MangaLocalDataSource(isarService.isar);
});

class MangaLocalDataSource {
  final Isar _isar;

  MangaLocalDataSource(this._isar);

  Future<void> saveManga(MangaEntity manga) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.mangaEntitys.filter().mangaDexIdEqualTo(manga.mangaDexId).findFirst();
      if (existing != null) {
        manga.id = existing.id;
        if (manga.localCoverPath == null) {
          manga.localCoverPath = existing.localCoverPath;
        }
      }
      await _isar.mangaEntitys.put(manga);
    });
  }

  Future<void> saveChapters(List<ChapterEntity> chapters) async {
    await _isar.writeTxn(() async {
      for (final chapter in chapters) {
        final existing = await _isar.chapterEntitys.filter().mangaDexIdEqualTo(chapter.mangaDexId).findFirst();
        if (existing != null) {
          chapter.id = existing.id;
          if (chapter.localPagePaths == null) {
            chapter.localPagePaths = existing.localPagePaths;
          }
          if (chapter.downloadStatus == DownloadStatus.notDownloaded) {
            chapter.downloadStatus = existing.downloadStatus;
          }
          if (chapter.downloadedAt == null) {
            chapter.downloadedAt = existing.downloadedAt;
          }
          chapter.lastReadPage = existing.lastReadPage;
          chapter.readPercentage = existing.readPercentage;
        }
        await _isar.chapterEntitys.put(chapter);
      }
    });
  }

  Future<MangaEntity?> getManga(String mangaDexId) async {
    return await _isar.mangaEntitys.filter().mangaDexIdEqualTo(mangaDexId).findFirst();
  }

  Future<List<ChapterEntity>> getChaptersForManga(String mangaId) async {
    return await _isar.chapterEntitys.filter().mangaIdEqualTo(mangaId).findAll();
  }

  Future<void> toggleFavorite(String mangaDexId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.mangaEntitys.filter().mangaDexIdEqualTo(mangaDexId).findFirst();
      if (existing != null) {
        existing.isFavorite = !existing.isFavorite;
        await _isar.mangaEntitys.put(existing);
      }
    });
  }

  Future<bool> isFavorite(String mangaDexId) async {
    final manga = await getManga(mangaDexId);
    return manga?.isFavorite ?? false;
  }

  Future<List<MangaEntity>> getFavoriteMangas() async {
    return await _isar.mangaEntitys.filter().isFavoriteEqualTo(true).findAll();
  }

  Future<ChapterEntity?> getChapter(String chapterDexId) async {
    return await _isar.chapterEntitys.filter().mangaDexIdEqualTo(chapterDexId).findFirst();
  }

  Future<void> saveChapter(ChapterEntity chapter) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.chapterEntitys.filter().mangaDexIdEqualTo(chapter.mangaDexId).findFirst();
      if (existing != null) {
        chapter.id = existing.id;
      }
      await _isar.chapterEntitys.put(chapter);
    });
  }

  Future<void> updateChapterProgress(String chapterId, int pageIndex, double percentage) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.chapterEntitys.filter().mangaDexIdEqualTo(chapterId).findFirst();
      if (existing != null) {
        existing.lastReadPage = pageIndex;
        existing.readPercentage = percentage;
        existing.lastReadAt = DateTime.now();
        await _isar.chapterEntitys.put(existing);
      }
    });
  }
}
