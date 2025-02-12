class QuizImage {
  final String url;
  final String filename;
  final int size;

  QuizImage({
    required this.url,
    required this.filename,
    required this.size,
  });

  factory QuizImage.fromJson(Map<String, dynamic> json) {
    return QuizImage(
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

class QuizQuestion {
  final String id;
  final String text;
  final QuizImage? image;
  final List<QuizOption> options;
  final String type; // 'boolean' or 'multiple'

  QuizQuestion({
    required this.id,
    required this.text,
    this.image,
    required this.options,
    required this.type,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      image: json['image'] != null ? QuizImage.fromJson(json['image']) : null,
      options: (json['options'] as List? ?? [])
          .map((option) => QuizOption.fromJson(option))
          .toList(),
      type: json['type'] ?? 'multiple',
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String? description;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      questions: (json['questions'] as List? ?? [])
          .map((question) => QuizQuestion.fromJson(question))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}