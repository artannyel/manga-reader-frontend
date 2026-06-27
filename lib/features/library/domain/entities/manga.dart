class Manga {
  final String id;
  final String title;
  final String? description;
  final String coverUrl;
  final bool isFavorite;
  final String? author;
  final String? status;

  const Manga({
    required this.id,
    required this.title,
    this.description,
    required this.coverUrl,
    required this.isFavorite,
    this.author,
    this.status,
  });

  Manga copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    bool? isFavorite,
    String? author,
    String? status,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      author: author ?? this.author,
      status: status ?? this.status,
    );
  }
}
