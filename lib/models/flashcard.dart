import 'package:json_annotation/json_annotation.dart';

part 'flashcard.g.dart';

/// Flashcard model representing a single flashcard with SRS metadata
@JsonSerializable()
class Flashcard {
  final int? id;
  final int kitId;
  final String front;
  final String back;
  
  // SRS (SM-2) algorithm fields
  final double easiness; // Easiness factor (default 2.5)
  final int interval; // Days until next review
  final int repetitions; // Number of successful repetitions
  final DateTime? dueDate; // Next review date
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    this.id,
    required this.kitId,
    required this.front,
    required this.back,
    this.easiness = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardToJson(this);

  /// Create a copy of this flashcard with updated fields
  Flashcard copyWith({
    int? id,
    int? kitId,
    String? front,
    String? back,
    double? easiness,
    int? interval,
    int? repetitions,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      kitId: kitId ?? this.kitId,
      front: front ?? this.front,
      back: back ?? this.back,
      easiness: easiness ?? this.easiness,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kit_id': kitId,
      'front': front,
      'back': back,
      'easiness': easiness,
      'interval': interval,
      'repetitions': repetitions,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as int?,
      kitId: map['kit_id'] as int,
      front: map['front'] as String,
      back: map['back'] as String,
      easiness: map['easiness'] as double,
      interval: map['interval'] as int,
      repetitions: map['repetitions'] as int,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Check if this flashcard is due for review
  bool get isDue {
    if (dueDate == null) return true;
    return DateTime.now().isAfter(dueDate!);
  }
}
