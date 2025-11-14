import 'package:json_annotation/json_annotation.dart';

part 'quiz.g.dart';

/// Quiz question types
enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
}

/// Quiz model representing a single quiz question
@JsonSerializable()
class Quiz {
  final int? id;
  final int kitId;
  final String question;
  final QuestionType type;
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final String? userAnswer;
  final bool? isCorrect;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    this.id,
    required this.kitId,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);

  /// Create a copy with updated fields
  Quiz copyWith({
    int? id,
    int? kitId,
    String? question,
    QuestionType? type,
    List<String>? options,
    String? correctAnswer,
    String? userAnswer,
    bool? isCorrect,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      kitId: kitId ?? this.kitId,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kit_id': kitId,
      'question': question,
      'type': type.toString(),
      'options': options.join('|||'), // Join with delimiter for storage
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'is_correct': isCorrect == null ? null : (isCorrect! ? 1 : 0),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as int?,
      kitId: map['kit_id'] as int,
      question: map['question'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: (map['options'] as String).split('|||'),
      correctAnswer: map['correct_answer'] as String,
      userAnswer: map['user_answer'] as String?,
      isCorrect: map['is_correct'] == null
          ? null
          : (map['is_correct'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
