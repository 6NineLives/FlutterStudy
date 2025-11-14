import '../models/flashcard.dart';

/// Spaced Repetition System (SRS) service using SM-2 algorithm
/// Calculates next review intervals based on user performance
class SRSService {
  /// Rating enum for flashcard review quality
  /// Again = 0 (complete failure)
  /// Hard = 1 (incorrect but remembered)
  /// Good = 2 (correct with hesitation)
  /// Easy = 3 (correct immediately)
  
  /// Calculate the next review for a flashcard based on SM-2 algorithm
  /// 
  /// Parameters:
  /// - flashcard: The flashcard being reviewed
  /// - quality: User's performance rating (0-3)
  ///   - 0: Again (complete failure)
  ///   - 1: Hard (incorrect but remembered)
  ///   - 2: Good (correct with hesitation)
  ///   - 3: Easy (correct immediately)
  /// 
  /// Returns: Updated flashcard with new SRS values
  Flashcard calculateNextReview(Flashcard flashcard, int quality) {
    assert(quality >= 0 && quality <= 3, 'Quality must be between 0 and 3');

    double easiness = flashcard.easiness;
    int interval = flashcard.interval;
    int repetitions = flashcard.repetitions;

    // SM-2 algorithm implementation
    // Update easiness factor
    easiness = easiness + (0.1 - (3 - quality) * (0.08 + (3 - quality) * 0.02));

    // Ensure easiness doesn't go below 1.3
    if (easiness < 1.3) {
      easiness = 1.3;
    }

    // Update repetitions and interval based on quality
    if (quality < 2) {
      // Failed or hard - reset repetitions
      repetitions = 0;
      interval = 1; // Review again tomorrow
    } else {
      // Correct - increase repetitions
      repetitions += 1;

      if (repetitions == 1) {
        interval = 1; // First repetition - 1 day
      } else if (repetitions == 2) {
        interval = 6; // Second repetition - 6 days
      } else {
        // Subsequent repetitions - multiply by easiness factor
        interval = (interval * easiness).round();
      }
    }

    // Calculate next due date
    final dueDate = DateTime.now().add(Duration(days: interval));

    return flashcard.copyWith(
      easiness: easiness,
      interval: interval,
      repetitions: repetitions,
      dueDate: dueDate,
      updatedAt: DateTime.now(),
    );
  }

  /// Get the number of days until the next review
  int daysUntilDue(Flashcard flashcard) {
    if (flashcard.dueDate == null) return 0;
    
    final now = DateTime.now();
    final difference = flashcard.dueDate!.difference(now);
    return difference.inDays;
  }

  /// Check if a flashcard is overdue
  bool isOverdue(Flashcard flashcard) {
    if (flashcard.dueDate == null) return true;
    return DateTime.now().isAfter(flashcard.dueDate!);
  }

  /// Get the mastery level of a flashcard based on repetitions
  /// Returns a value between 0.0 and 1.0
  double getMasteryLevel(Flashcard flashcard) {
    // Consider mastered after 5+ successful repetitions
    const maxRepetitions = 5;
    return (flashcard.repetitions / maxRepetitions).clamp(0.0, 1.0);
  }

  /// Get a description of the flashcard's status
  String getStatusDescription(Flashcard flashcard) {
    if (flashcard.dueDate == null) {
      return 'New';
    }

    final daysUntil = daysUntilDue(flashcard);
    
    if (daysUntil < 0) {
      return 'Overdue (${-daysUntil} days)';
    } else if (daysUntil == 0) {
      return 'Due today';
    } else if (daysUntil == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysUntil days';
    }
  }

  /// Calculate statistics for a collection of flashcards
  Map<String, dynamic> calculateStats(List<Flashcard> flashcards) {
    if (flashcards.isEmpty) {
      return {
        'total': 0,
        'new': 0,
        'learning': 0,
        'mastered': 0,
        'due': 0,
        'averageMastery': 0.0,
      };
    }

    int newCards = 0;
    int learning = 0;
    int mastered = 0;
    int dueCards = 0;
    double totalMastery = 0.0;

    for (final card in flashcards) {
      if (card.repetitions == 0) {
        newCards++;
      } else if (card.repetitions < 5) {
        learning++;
      } else {
        mastered++;
      }

      if (isOverdue(card)) {
        dueCards++;
      }

      totalMastery += getMasteryLevel(card);
    }

    return {
      'total': flashcards.length,
      'new': newCards,
      'learning': learning,
      'mastered': mastered,
      'due': dueCards,
      'averageMastery': totalMastery / flashcards.length,
    };
  }

  /// Get recommended study duration based on number of due cards
  String getRecommendedStudyDuration(int dueCardCount) {
    if (dueCardCount == 0) {
      return 'No cards due';
    } else if (dueCardCount <= 5) {
      return '5 minutes';
    } else if (dueCardCount <= 10) {
      return '10 minutes';
    } else if (dueCardCount <= 20) {
      return '20 minutes';
    } else {
      return '30+ minutes';
    }
  }
}
