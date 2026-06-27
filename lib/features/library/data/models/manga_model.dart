import '../../domain/entities/manga.dart';

class MangaModel extends Manga {
  const MangaModel({
    required super.id,
    required super.title,
    super.description,
    required super.coverUrl,
    required super.isFavorite,
    super.author,
    super.status,
  });

  factory MangaModel.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return MangaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String? ?? '',
      isFavorite: isFavorite,
      author: json['author'] as String?,
      status: json['status_translated'] as String? ?? json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'author': author,
      'status': status,
    };
  }
}
