import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/manga.dart';
import '../../domain/entities/manga_details.dart';
import '../../domain/repositories/manga_repository.dart';
import '../datasources/manga_local_data_source.dart';
import '../datasources/manga_remote_data_source.dart';
import '../models/chapter_entity.dart';
import '../models/chapter_model.dart';
import '../models/manga_entity.dart';
import '../models/manga_model.dart';

final mangaRepositoryImplProvider = Provider<MangaRepository>((ref) {
  final remote = ref.watch(mangaRemoteDataSourceProvider);
  final local = ref.watch(mangaLocalDataSourceProvider);
  return MangaRepositoryImpl(remote, local);
});

class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource _remoteDataSource;
  final MangaLocalDataSource _localDataSource;

  MangaRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<Manga>> fetchFeed({required int limit, required int offset}) async {
    try {
      final remoteModels = await _remoteDataSource.fetchFeed(limit: limit, offset: offset);
      final list = <Manga>[];
      for (final model in remoteModels) {
        final isFav = await _localDataSource.isFavorite(model.id);
        
        final localManga = await _localDataSource.getManga(model.id);
        final entity = MangaEntity()
          ..mangaDexId = model.id
          ..title = model.title
          ..description = model.description
          ..coverUrl = model.coverUrl
          ..isFavorite = localManga?.isFavorite ?? isFav
          ..lastSyncedAt = DateTime.now();
        await _localDataSource.saveManga(entity);

        list.add(Manga(
          id: model.id,
          title: model.title,
          description: model.description,
          coverUrl: model.coverUrl,
          isFavorite: localManga?.isFavorite ?? isFav,
          author: model.author,
          status: model.status,
        ));
      }
      return list;
    } catch (_) {
      final localFavorites = await _localDataSource.getFavoriteMangas();
      return localFavorites.map((entity) => Manga(
        id: entity.mangaDexId,
        title: entity.title,
        description: entity.description,
        coverUrl: entity.coverUrl,
        isFavorite: entity.isFavorite,
      )).toList();
    }
  }

  @override
  Future<List<Manga>> searchManga({required String query, required int limit, required int offset}) async {
    try {
      final remoteModels = await _remoteDataSource.searchManga(query: query, limit: limit, offset: offset);
      final list = <Manga>[];
      for (final model in remoteModels) {
        final isFav = await _localDataSource.isFavorite(model.id);
        list.add(Manga(
          id: model.id,
          title: model.title,
          description: model.description,
          coverUrl: model.coverUrl,
          isFavorite: isFav,
          author: model.author,
          status: model.status,
        ));
      }
      return list;
    } catch (_) {
      if (query.isEmpty) {
        final favorites = await _localDataSource.getFavoriteMangas();
        return favorites.map((entity) => Manga(
          id: entity.mangaDexId,
          title: entity.title,
          description: entity.description,
          coverUrl: entity.coverUrl,
          isFavorite: entity.isFavorite,
        )).toList();
      }
      final favorites = await _localDataSource.getFavoriteMangas();
      return favorites
          .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
          .map((entity) => Manga(
            id: entity.mangaDexId,
            title: entity.title,
            description: entity.description,
            coverUrl: entity.coverUrl,
            isFavorite: entity.isFavorite,
          ))
          .toList();
    }
  }

  @override
  Future<MangaDetails> fetchMangaDetails(String id) async {
    try {
      final json = await _remoteDataSource.fetchMangaDetails(id);
      
      final mangaModel = MangaModel.fromJson(json);
      final isFav = await _localDataSource.isFavorite(id);
      final manga = Manga(
        id: mangaModel.id,
        title: mangaModel.title,
        description: mangaModel.description,
        coverUrl: mangaModel.coverUrl,
        isFavorite: isFav,
        author: mangaModel.author,
        status: mangaModel.status,
      );

      final localManga = await _localDataSource.getManga(id);
      final mangaEntity = MangaEntity()
        ..mangaDexId = mangaModel.id
        ..title = mangaModel.title
        ..description = mangaModel.description
        ..coverUrl = mangaModel.coverUrl
        ..isFavorite = localManga?.isFavorite ?? isFav
        ..lastSyncedAt = DateTime.now();
      await _localDataSource.saveManga(mangaEntity);

      final chaptersList = json['chapters'] as List<dynamic>;
      final List<Chapter> chapters = [];
      final List<ChapterEntity> chapterEntities = [];

      for (final chapJson in chaptersList) {
        final localChap = await _localDataSource.getChapter(chapJson['id'] as String);
        
        final chapterModel = ChapterModel.fromJson(
          chapJson as Map<String, dynamic>,
          id,
          downloadStatus: localChap?.downloadStatus ?? DownloadStatus.notDownloaded,
          localPagePaths: localChap?.localPagePaths,
          lastReadPage: localChap?.lastReadPage ?? 0,
          readPercentage: localChap?.readPercentage ?? 0.0,
          lastReadAt: localChap?.lastReadAt,
        );

        chapters.add(chapterModel);

        final chapterEntity = ChapterEntity()
          ..mangaDexId = chapterModel.id
          ..mangaId = id
          ..chapterNumber = chapterModel.chapterNumber
          ..title = chapterModel.title
          ..pagesCount = chapterModel.pagesCount
          ..downloadStatus = chapterModel.downloadStatus
          ..localPagePaths = chapterModel.localPagePaths
          ..lastReadPage = chapterModel.lastReadPage
          ..readPercentage = chapterModel.readPercentage
          ..lastReadAt = chapterModel.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        chapterEntities.add(chapterEntity);
      }

      await _localDataSource.saveChapters(chapterEntities);

      return MangaDetails(manga: manga, chapters: chapters);
    } catch (_) {
      final localManga = await _localDataSource.getManga(id);
      if (localManga == null) {
        throw Exception("Mangá não encontrado offline");
      }
      
      final manga = Manga(
        id: localManga.mangaDexId,
        title: localManga.title,
        description: localManga.description,
        coverUrl: localManga.coverUrl,
        isFavorite: localManga.isFavorite,
      );

      final localChapters = await _localDataSource.getChaptersForManga(id);
      final chapters = localChapters.map((c) => Chapter(
        id: c.mangaDexId,
        mangaId: c.mangaId,
        chapterNumber: c.chapterNumber,
        title: c.title,
        pagesCount: c.pagesCount,
        downloadStatus: c.downloadStatus,
        localPagePaths: c.localPagePaths,
        lastReadPage: c.lastReadPage,
        readPercentage: c.readPercentage,
        lastReadAt: c.lastReadAt,
      )).toList();

      return MangaDetails(manga: manga, chapters: chapters);
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _localDataSource.toggleFavorite(id);
  }

  @override
  Future<bool> isFavorite(String id) async {
    return await _localDataSource.isFavorite(id);
  }
}
