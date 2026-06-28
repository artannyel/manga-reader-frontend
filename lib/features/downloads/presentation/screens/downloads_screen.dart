import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../../../library/data/models/chapter_entity.dart';
import '../../../library/data/models/manga_entity.dart';
import '../../../library/domain/entities/chapter.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  List<MangaEntity> _downloadedMangas = [];
  Map<String, List<ChapterEntity>> _downloadedChapters = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() {
      _isLoading = true;
    });

    final isarService = ref.read(isarServiceProvider);
    final chapters = await isarService.isar.chapterEntitys
        .filter()
        .downloadStatusEqualTo(DownloadStatus.downloaded)
        .findAll();

    final Map<String, List<ChapterEntity>> chaptersByManga = {};
    for (var chap in chapters) {
      chaptersByManga.putIfAbsent(chap.mangaId, () => []).add(chap);
    }

    final List<MangaEntity> mangas = [];
    for (var mangaId in chaptersByManga.keys) {
      final manga = await isarService.isar.mangaEntitys
          .filter()
          .mangaDexIdEqualTo(mangaId)
          .findFirst();
      if (manga != null) {
        mangas.add(manga);
      }
    }

    setState(() {
      _downloadedMangas = mangas;
      _downloadedChapters = chaptersByManga;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Downloads'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _downloadedMangas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.download_for_offline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum download encontrado',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Baixe capítulos para lê-los offline.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDownloads,
                  color: Colors.red,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _downloadedMangas.length,
                    itemBuilder: (context, index) {
                      final manga = _downloadedMangas[index];
                      final chapters = _downloadedChapters[manga.mangaDexId] ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: manga.coverUrl,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.book),
                            ),
                          ),
                          title: Text(
                            manga.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${chapters.length} capítulo(s) baixado(s)',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          children: chapters.map((chapter) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              title: Text('Capítulo ${chapter.chapterNumber}'),
                              subtitle: Text(
                                chapter.title.isEmpty ? 'Sem título' : chapter.title,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chrome_reader_mode, color: Colors.red),
                              onTap: () {
                                context.push('/manga/${manga.mangaDexId}/chapter/${chapter.mangaDexId}');
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

