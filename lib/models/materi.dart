class Materi {
  final String id;
  final String judul;
  final String konten;
  final String thumbnail;
  final DateTime createdAt;

  Materi({
    required this.id,
    required this.judul,
    required this.konten,
    required this.thumbnail,
    required this.createdAt,
  });

  factory Materi.fromJson(Map<String, dynamic> json) {
    return Materi(
      id: json['_id'] ?? '',
      judul: json['judul'] ?? '',
      konten: json['konten'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    );
  }
}