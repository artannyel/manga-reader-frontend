import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../features/library/domain/entities/chapter.dart';
import '../providers/manga_details_provider.dart';

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

    // Chronological sorting
    final chapters = List<Chapter>.from(details.chapters);
    chapters.sort((a, b) {
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
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              manga.description ?? 'Sem sinopse disponível.',
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
                        'Capítulos (${chapters.length})',
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

                  // Chapter Feed List
                  if (chapters.isEmpty)
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
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
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
                            trailing: const Icon(
                              Icons.play_arrow,
                              color: Colors.redAccent,
                            ),
                            onTap: () {
                              context.push(
                                '/manga/$mangaId/chapter/${chapter.id}',
                              );
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
}
