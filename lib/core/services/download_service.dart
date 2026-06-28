import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import '../../features/library/data/models/chapter_entity.dart';
import '../../features/library/data/models/manga_entity.dart';
import '../../features/library/domain/entities/chapter.dart';
import '../../features/library/domain/repositories/manga_repository.dart';
import './isar_service.dart';

class DownloadState {
  final Map<String, DownloadStatus> statuses;
  final Map<String, double> progress; // Chapter ID -> percentage (0.0 to 1.0)

  DownloadState({
    required this.statuses,
    required this.progress,
  });

  DownloadState.initial() : statuses = {}, progress = {};

  DownloadState copyWith({
    Map<String, DownloadStatus>? statuses,
    Map<String, double>? progress,
  }) {
    return DownloadState(
      statuses: statuses ?? this.statuses,
      progress: progress ?? this.progress,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref _ref;
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final List<String> _queue = [];
  bool _isProcessing = false;

  DownloadNotifier(this._ref, {Dio? dio})
      : _dio = dio ?? Dio(),
        super(DownloadState.initial()) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    if (_isInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Request permission for Android 13+ (API 33+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<void> downloadChapter(Chapter chapter) async {
    final chapterId = chapter.id;

    // Check if already downloaded or in queue
    if (state.statuses[chapterId] == DownloadStatus.downloaded ||
        state.statuses[chapterId] == DownloadStatus.queued ||
        state.statuses[chapterId] == DownloadStatus.downloading) {
      return;
    }

    // Set status to queued
    state = state.copyWith(
      statuses: {...state.statuses, chapterId: DownloadStatus.queued},
      progress: {...state.progress, chapterId: 0.0},
    );

    // Update status in Isar database
    final isarService = _ref.read(isarServiceProvider);
    await isarService.isar.writeTxn(() async {
      final existing = await isarService.isar.chapterEntitys
          .filter()
          .mangaDexIdEqualTo(chapterId)
          .findFirst();
      if (existing != null) {
        existing.downloadStatus = DownloadStatus.queued;
        await isarService.isar.chapterEntitys.put(existing);
      }
    });

    _queue.add(chapterId);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final chapterId = _queue.removeAt(0);
      try {
        await _downloadChapterTask(chapterId);
      } catch (e) {
        debugPrint('Failed downloading chapter $chapterId: $e');
        _updateChapterStatus(chapterId, DownloadStatus.failed);
      }
    }

    _isProcessing = false;
  }

  Future<void> _downloadChapterTask(String chapterId) async {
    _updateChapterStatus(chapterId, DownloadStatus.downloading);

    final isarService = _ref.read(isarServiceProvider);
    final repo = _ref.read(mangaRepositoryProvider);

    // Get chapter entity
    final chapterEntity = await isarService.isar.chapterEntitys
        .filter()
        .mangaDexIdEqualTo(chapterId)
        .findFirst();
    if (chapterEntity == null) {
      throw Exception('Capítulo não encontrado no banco local');
    }

    // Fetch page URLs
    final pages = await repo.fetchChapterPages(chapterId);
    if (pages.isEmpty) {
      throw Exception('Nenhuma página encontrada para o capítulo');
    }

    // Setup local download directory
    final supportDir = await getApplicationSupportDirectory();
    final downloadsDir = Directory('${supportDir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Write .nomedia file to bypass gallery indexing
    final nomediaFile = File('${downloadsDir.path}/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.writeAsString('');
    }

    final chapterDir = Directory('${downloadsDir.path}/$chapterId');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }

    final List<String> localPaths = [];
    final totalPages = pages.length;

    // Show initial notification
    await _showProgressNotification(chapterId, chapterEntity.title, 0, totalPages);

    DateTime lastNotificationTime = DateTime.now();
    int lastNotifiedPage = 0;

    for (int i = 0; i < totalPages; i++) {
      final pageUrl = pages[i];
      final fileExtension = pageUrl.split('?').first.split('.').last;
      final localPath = '${chapterDir.path}/$i.$fileExtension';

      // Download page
      await _dio.download(pageUrl, localPath);
      localPaths.add(localPath);

      final currentProgress = (i + 1) / totalPages;
      state = state.copyWith(
        progress: {...state.progress, chapterId: currentProgress},
      );

      // Throttle notification updates (limit to 1 notification per second or every 5 pages)
      final now = DateTime.now();
      if (now.difference(lastNotificationTime).inSeconds >= 1 || i - lastNotifiedPage >= 5 || i == totalPages - 1) {
        await _showProgressNotification(chapterId, chapterEntity.title, i + 1, totalPages);
        lastNotificationTime = now;
        lastNotifiedPage = i;
      }
    }

    // Update status to downloaded in local database
    await isarService.isar.writeTxn(() async {
      final existing = await isarService.isar.chapterEntitys
          .filter()
          .mangaDexIdEqualTo(chapterId)
          .findFirst();
      if (existing != null) {
        existing.downloadStatus = DownloadStatus.downloaded;
        existing.localPagePaths = localPaths;
        existing.downloadedAt = DateTime.now();
        await isarService.isar.chapterEntitys.put(existing);

        // Make sure parent manga is also saved/favored in Isar for offline view
        final manga = await isarService.isar.mangaEntitys
            .filter()
            .mangaDexIdEqualTo(existing.mangaId)
            .findFirst();
        if (manga == null) {
          final mangaDetails = await repo.fetchMangaDetails(existing.mangaId);
          final newManga = MangaEntity()
            ..mangaDexId = mangaDetails.manga.id
            ..title = mangaDetails.manga.title
            ..description = mangaDetails.manga.description
            ..coverUrl = mangaDetails.manga.coverUrl
            ..isFavorite = false
            ..lastSyncedAt = DateTime.now();
          await isarService.isar.mangaEntitys.put(newManga);
        }
      }
    });

    state = state.copyWith(
      statuses: {...state.statuses, chapterId: DownloadStatus.downloaded},
    );

    // Show completion notification
    await _showCompletionNotification(chapterId, chapterEntity.title);
  }

  Future<void> _showProgressNotification(
    String chapterId,
    String chapterTitle,
    int current,
    int total,
  ) async {
    if (!_isInitialized) return;
    final int progressPercent = ((current / total) * 100).toInt();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Progresso de downloads de capítulos de mangás',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: total,
      progress: current,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: chapterId.hashCode,
      title: 'Baixando capítulo',
      body: '$chapterTitle: $progressPercent% ($current de $total páginas)',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _showCompletionNotification(String chapterId, String chapterTitle) async {
    if (!_isInitialized) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Progresso de downloads de capítulos de mangás',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: chapterId.hashCode,
      title: 'Download concluído',
      body: '$chapterTitle foi baixado com sucesso!',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _updateChapterStatus(String chapterId, DownloadStatus status) async {
    state = state.copyWith(
      statuses: {...state.statuses, chapterId: status},
    );

    final isarService = _ref.read(isarServiceProvider);
    await isarService.isar.writeTxn(() async {
      final existing = await isarService.isar.chapterEntitys
          .filter()
          .mangaDexIdEqualTo(chapterId)
          .findFirst();
      if (existing != null) {
        existing.downloadStatus = status;
        await isarService.isar.chapterEntitys.put(existing);
      }
    });
  }
}

final downloadServiceProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier(ref);
});
