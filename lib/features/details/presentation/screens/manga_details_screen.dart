import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../features/library/domain/entities/chapter.dart';
import '../providers/manga_details_provider.dart';
import '../../../../core/services/download_service.dart';

class MangaDetailsScreen extends ConsumerWidget {
  final String mangaId;

  const MangaDetailsScreen({
    super.key,
    required this.mangaId,
  });

  double _parseChapterNumber(String numberStr) {
    // Strip non-numeric suffixes if any, to try to get a clean double
    final cleanStr = numberStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanStr) ?? 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(mangaDetailsProvider(mangaId));

    if (detailsState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (detailsState.errorMessage != null || detailsState.details == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  detailsState.errorMessage ?? 'Ocorreu um erro ao carregar detalhes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(mangaDetailsProvider(mangaId).notifier)
                        .fetchDetails();
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final details = detailsState.details!;
    final manga = details.manga;

    // Get the current selectedLanguage from state
    final selectedLanguage = detailsState.selectedLanguage;

    // Filter chapters by selected language
    final filteredChapters = details.chapters.where((c) => c.language == selectedLanguage).toList();

    // Chronological sorting
    filteredChapters.sort((a, b) {
      final numA = _parseChapterNumber(a.chapterNumber);
      final numB = _parseChapterNumber(b.chapterNumber);
      final cmp = numA.compareTo(numB);
      return detailsState.isSortAscending ? cmp : -cmp;
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blurred Cover Header Section
            Stack(
              children: [
                // Blurred Background Cover Image
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(manga.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.65),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                // Header Content (Cover + Meta)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Cover Artwork Card
                      Hero(
                        tag: 'manga-cover-${manga.id}',
                        child: Container(
                          width: 110,
                          height: 165,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(manga.coverUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Meta Info (Title, Author, Status, Favorite)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              manga.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (manga.author != null &&
                                manga.author!.isNotEmpty) ...[
                              Text(
                                manga.author!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (manga.status != null &&
                                manga.status!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  manga.status!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Favorite toggle button
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(mangaDetailsProvider(mangaId).notifier)
                                    .toggleFavorite();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: manga.isFavorite
                                    ? Colors.red
                                    : Colors.white10,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: Icon(
                                manga.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                              ),
                              label: Text(
                                manga.isFavorite ? 'Favorito' : 'Favoritar',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glassmorphism Synopsis Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sinopse',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (selectedLanguage != null && details.descriptions.containsKey(selectedLanguage))
                                  ? details.descriptions[selectedLanguage]!
                                  : (manga.description ?? 'Sem sinopse disponível.'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chapters Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capítulos (${filteredChapters.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          detailsState.isSortAscending
                              ? Icons.sort_by_alpha
                              : Icons.sort_by_alpha_outlined,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Ordenar',
                        onPressed: () {
                          ref
                              .read(mangaDetailsProvider(mangaId).notifier)
                              .toggleSortOrder();
                        },
                      ),
                    ],
                  ),
                  const Divider(),

                  // Language dropdown
                  if (details.availableLanguages.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text(
                          'Idioma: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              dropdownColor: Colors.grey.shade900,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  ref
                                      .read(mangaDetailsProvider(mangaId).notifier)
                                      .changeLanguage(newValue);
                                }
                              },
                              items: details.availableLanguages
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value.toUpperCase()),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Chapter Feed List
                  if (filteredChapters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'Nenhum capítulo disponível.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filteredChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = filteredChapters[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.grey.shade900,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              chapter.title.isNotEmpty
                                  ? chapter.title
                                  : 'Capítulo ${chapter.chapterNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Capítulo ${chapter.chapterNumber} • ${chapter.pagesCount} pgs',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDownloadButton(ref, chapter),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.play_arrow,
                                  color: Colors.redAccent,
                                ),
                              ],
                            ),
                            onTap: () {
                              context.push(
                                '/manga/$mangaId/chapter/${chapter.id}?language=$selectedLanguage',
                              ).then((_) {
                                ref.read(mangaDetailsProvider(mangaId).notifier).fetchDetails();
                              });
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(WidgetRef ref, Chapter chapter) {
    final downloadState = ref.watch(downloadServiceProvider);
    final downloadStatus = downloadState.statuses[chapter.id] ?? chapter.downloadStatus;
    final progress = downloadState.progress[chapter.id] ?? 0.0;

    switch (downloadStatus) {
      case DownloadStatus.downloaded:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        );
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            color: Colors.redAccent,
          ),
        );
      case DownloadStatus.queued:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey,
          ),
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          onPressed: () {
            ref.read(downloadServiceProvider.notifier).downloadChapter(chapter);
          },
        );
      case DownloadStatus.notDownloaded:
      default:
        return IconButton(
          icon: const Icon(
            Icons.download,
            color: Colors.grey,
            size: 24,
          ),
          onPressed: () {
            ref.read(downloadServiceProvider.notifier).downloadChapter(chapter);
          },
        );
    }
  }
}
