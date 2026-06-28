import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:manga_reader/core/services/download_service.dart';
import 'package:manga_reader/core/services/isar_service.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/library/data/models/chapter_entity.dart';
import 'package:manga_reader/features/library/data/models/manga_entity.dart';

// --- Manual Mock for MangaRepository ---

class MockMangaRepository implements MangaRepository {
  Future<List<String>> Function(String chapterId, {String quality})? fetchChapterPagesHandler;
  Future<MangaDetails> Function(String id)? fetchMangaDetailsHandler;

  @override
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data'}) async {
    if (fetchChapterPagesHandler != null) {
      return fetchChapterPagesHandler!(chapterId, quality: quality);
    }
    return [];
  }

  @override
  Future<MangaDetails> fetchMangaDetails(String id) async {
    if (fetchMangaDetailsHandler != null) {
      return fetchMangaDetailsHandler!(id);
    }
    throw UnimplementedError('fetchMangaDetails not mocked');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// --- Manual Mock for PathProvider ---

class FakePathProviderPlatform extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String supportPath;
  FakePathProviderPlatform(this.supportPath);

  @override
  Future<String?> getApplicationSupportPath() async {
    return supportPath;
  }
}

// --- Manual Mock for Dio HttpClientAdapter ---

class MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late IsarService mockIsarService;
  late MockMangaRepository mockMangaRepository;
  late Directory tempDir;
  late Dio dio;
  final List<MethodCall> notificationCalls = [];

  setUpAll(() async {
    // Download and load native binaries
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // Force target platform to Android in tests to enable Android local notifications initialize/show
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    // Setup clean temporary directory for Isar and downloads
    tempDir = Directory.systemTemp.createTempSync('download_test');
    
    // Open a real local database instance in the temp directory
    isar = await Isar.open(
      [MangaEntitySchema, ChapterEntitySchema],
      directory: tempDir.path,
    );
    mockIsarService = IsarService(isar);
    mockMangaRepository = MockMangaRepository();

    // Initialize the real Android plugin platform instance to avoid LateInitializationError
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();

    // Intercept native method channel calls for local notifications
    notificationCalls.clear();
    const notificationChannel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      notificationChannel,
      (MethodCall methodCall) async {
        notificationCalls.add(methodCall);
        if (methodCall.method == 'initialize') {
          return true;
        }
        return null;
      },
    );

    // Register path provider platform mock
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    // Set up custom mocked Dio client
    dio = Dio();
    dio.httpClientAdapter = MockHttpClientAdapter();
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await isar.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    const notificationChannel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      notificationChannel,
      null,
    );
  });

  test('DownloadNotifier sets chapter download status to queued immediately, downloads pages, updates Isar database, and triggers notification', () async {
    const chapterId = 'chapter_123';
    const mangaId = 'manga_456';

    final chapter = const Chapter(
      id: chapterId,
      mangaId: mangaId,
      chapterNumber: '1',
      title: 'Capítulo 1',
      pagesCount: 2,
      downloadStatus: DownloadStatus.notDownloaded,
      lastReadPage: 0,
      readPercentage: 0.0,
    );

    final chapterEntity = ChapterEntity()
      ..mangaDexId = chapterId
      ..mangaId = mangaId
      ..chapterNumber = '1'
      ..title = 'Capítulo 1'
      ..pagesCount = 2
      ..downloadStatus = DownloadStatus.notDownloaded
      ..lastReadPage = 0
      ..readPercentage = 0.0
      ..lastReadAt = DateTime.now();

    // Store the initial chapter in the database
    await isar.writeTxn(() async {
      await isar.chapterEntitys.put(chapterEntity);
    });

    // Stub repository handlers
    mockMangaRepository.fetchChapterPagesHandler = (id, {String quality = 'data'}) async {
      expect(id, chapterId);
      return [
        'http://example.com/page0.jpg',
        'http://example.com/page1.jpg',
      ];
    };

    mockMangaRepository.fetchMangaDetailsHandler = (id) async {
      expect(id, mangaId);
      return const MangaDetails(
        manga: Manga(
          id: mangaId,
          title: 'Test Manga',
          coverUrl: 'http://example.com/cover.jpg',
          isFavorite: false,
        ),
        chapters: [],
      );
    };

    // Set up Riverpod ProviderContainer
    final container = ProviderContainer(
      overrides: [
        isarServiceProvider.overrideWithValue(mockIsarService),
        mangaRepositoryProvider.overrideWithValue(mockMangaRepository),
        downloadServiceProvider.overrideWith((ref) => DownloadNotifier(ref, dio: dio)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(downloadServiceProvider.notifier);

    // List to collect state history of the provider
    final List<DownloadState> stateHistory = [];
    container.listen<DownloadState>(downloadServiceProvider, (previous, next) {
      stateHistory.add(next);
    }, fireImmediately: true);

    // 1. Trigger the download of the chapter
    await notifier.downloadChapter(chapter);

    // Verify status was set to queued in the notifier state history
    final hasQueuedState = stateHistory.any((s) => s.statuses[chapterId] == DownloadStatus.queued);
    expect(hasQueuedState, isTrue);

    // Verify status was updated in the Isar database (it could be queued, downloading, or downloaded by now)
    final dbChapterAfterQueue = await isar.chapterEntitys.filter().mangaDexIdEqualTo(chapterId).findFirst();
    expect(dbChapterAfterQueue, isNotNull);
    expect(
      dbChapterAfterQueue!.downloadStatus,
      anyOf(DownloadStatus.queued, DownloadStatus.downloading, DownloadStatus.downloaded),
    );

    // 2. Wait for the background queue processing to finish (downloads pages sequentially)
    while (container.read(downloadServiceProvider).statuses[chapterId] != DownloadStatus.downloaded) {
      await pumpEventQueue();
    }

    // Verify status is set to downloaded in the notifier state
    expect(
      container.read(downloadServiceProvider).statuses[chapterId],
      DownloadStatus.downloaded,
    );

    // 3. Verify the database updates the status and stores local file paths
    final savedChapter = await isar.chapterEntitys.filter().mangaDexIdEqualTo(chapterId).findFirst();
    expect(savedChapter, isNotNull);
    expect(savedChapter!.downloadStatus, DownloadStatus.downloaded);
    expect(savedChapter.localPagePaths, isNotNull);
    expect(savedChapter.localPagePaths!.length, 2);
    expect(savedChapter.localPagePaths![0], contains('/downloads/chapter_123/0.jpg'));
    expect(savedChapter.localPagePaths![1], contains('/downloads/chapter_123/1.jpg'));

    // Check that parent manga is added to the database since it didn't exist
    final savedManga = await isar.mangaEntitys.filter().mangaDexIdEqualTo(mangaId).findFirst();
    expect(savedManga, isNotNull);
    expect(savedManga!.title, 'Test Manga');

    // 4. Verify native local notification completion is triggered
    final initializeCalls = notificationCalls.where((call) => call.method == 'initialize').toList();
    expect(initializeCalls, isNotEmpty);

    final showCalls = notificationCalls.where((call) => call.method == 'show').toList();
    expect(showCalls, isNotEmpty);
    
    // The last call should be the completion notification
    final completionCall = showCalls.last;
    expect(completionCall.arguments['title'], 'Download concluído');
    expect(completionCall.arguments['body'], contains('Capítulo 1 foi baixado com sucesso!'));
  });
}
