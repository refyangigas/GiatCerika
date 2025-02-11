class Video {
  final String id;
  final String judul;
  final String youtube_url;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.judul,
    required this.youtube_url,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'] ?? '',
      judul: json['judul'] ?? '',
      youtube_url: json['youtube_url'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'judul': judul,
      'youtube_url': youtube_url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}