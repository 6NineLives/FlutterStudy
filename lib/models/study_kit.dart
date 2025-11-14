import 'package:json_annotation/json_annotation.dart';

part 'study_kit.g.dart';

/// Study kit model representing a collection of study materials
@JsonSerializable()
class StudyKit {
  final int? id;
  final String title;
  final String? description;
  final String? summary; // AI-generated summary
  final String sourceType; // 'pdf', 'image', 'text'
  final String? filePath; // Local file path if applicable
  final String? content; // Raw text content
  final int flashcardCount;
  final int quizCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyKit({
    this.id,
    required this.title,
    this.description,
    this.summary,
    required this.sourceType,
    this.filePath,
    this.content,
    this.flashcardCount = 0,
    this.quizCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory StudyKit.fromJson(Map<String, dynamic> json) =>
      _$StudyKitFromJson(json);

  Map<String, dynamic> toJson() => _$StudyKitToJson(this);

  /// Create a copy with updated fields
  StudyKit copyWith({
    int? id,
    String? title,
    String? description,
    String? summary,
    String? sourceType,
    String? filePath,
    String? content,
    int? flashcardCount,
    int? quizCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyKit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      sourceType: sourceType ?? this.sourceType,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      quizCount: quizCount ?? this.quizCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'summary': summary,
      'source_type': sourceType,
      'file_path': filePath,
      'content': content,
      'flashcard_count': flashcardCount,
      'quiz_count': quizCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory StudyKit.fromMap(Map<String, dynamic> map) {
    return StudyKit(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      summary: map['summary'] as String?,
      sourceType: map['source_type'] as String,
      filePath: map['file_path'] as String?,
      content: map['content'] as String?,
      flashcardCount: map['flashcard_count'] as int? ?? 0,
      quizCount: map['quiz_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
