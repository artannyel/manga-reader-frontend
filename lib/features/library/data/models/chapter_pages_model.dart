class ChapterPagesModel {
  final String chapterId;
  final String quality;
  final String hash;
  final List<String> pageFilenames;
  final String hostUrl;
  final List<String> pageUrls;

  ChapterPagesModel({
    required this.chapterId,
    required this.quality,
    required this.hash,
    required this.pageFilenames,
    required this.hostUrl,
    required this.pageUrls,
  });

  factory ChapterPagesModel.fromJson(Map<String, dynamic> json, {String? targetQuality}) {
    final rawPages = json['pages'] as List<dynamic>? ?? [];
    final pagesList = rawPages.map((e) => e.toString()).toList();
    
    final hash = json['hash'] as String? ?? '';
    final quality = json['quality'] as String? ?? targetQuality ?? 'data';
    final chapterId = json['chapter_id'] as String? ?? '';
    
    String hostUrl = json['host'] as String? ?? 
                     json['host_url'] as String? ?? 
                     json['hostUrl'] as String? ?? 
                     'https://uploads.mangadex.org';

    // Verify if the host URL returned by the backend is absolute
    final hostUri = Uri.tryParse(hostUrl);
    if (hostUri == null || !hostUri.isAbsolute) {
      hostUrl = 'https://uploads.mangadex.org';
    } else {
      hostUrl = hostUrl.endsWith('/') ? hostUrl.substring(0, hostUrl.length - 1) : hostUrl;
    }

    final pageFilenames = <String>[];
    
    for (final url in pagesList) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        try {
          final uri = Uri.parse(url);
          hostUrl = '${uri.scheme}://${uri.host}';
          pageFilenames.add(uri.pathSegments.last);
        } catch (_) {
          pageFilenames.add(url);
        }
      } else {
        try {
          final uri = Uri.parse(url);
          if (uri.pathSegments.isNotEmpty) {
            pageFilenames.add(uri.pathSegments.last);
          } else {
            pageFilenames.add(url);
          }
        } catch (_) {
          pageFilenames.add(url);
        }
      }
    }

    final constructedUrls = pageFilenames.map((filename) {
      final cleanQuality = quality.replaceAll(RegExp(r'^/+|/+$'), '');
      final cleanHash = hash.replaceAll(RegExp(r'^/+|/+$'), '');
      final cleanFilename = filename.replaceAll(RegExp(r'^/+|/+$'), '');

      if (cleanFilename.startsWith('http://') || cleanFilename.startsWith('https://')) {
        return cleanFilename;
      }

      return '$hostUrl/$cleanQuality/$cleanHash/$cleanFilename';
    }).toList();

    return ChapterPagesModel(
      chapterId: chapterId,
      quality: quality,
      hash: hash,
      pageFilenames: pageFilenames,
      hostUrl: hostUrl,
      pageUrls: constructedUrls,
    );
  }
}
