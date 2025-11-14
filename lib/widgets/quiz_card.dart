import 'package:flutter/material.dart';
import '../models/quiz.dart';

/// Quiz card widget for displaying and answering quiz questions
class QuizCard extends StatefulWidget {
  final Quiz quiz;
  final Function(String answer)? onAnswerSelected;
  final bool showResult;

  const QuizCard({
    Key? key,
    required this.quiz,
    this.onAnswerSelected,
    this.showResult = false,
  }) : super(key: key);

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    selectedAnswer = widget.quiz.userAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type badge
            _buildQuestionTypeBadge(),
            const SizedBox(height: 16),
            
            // Question text
            Text(
              widget.quiz.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Answer options
            ...widget.quiz.options.map((option) => _buildOption(option)),
            
            // Result indicator
            if (widget.showResult && selectedAnswer != null) ...[
              const SizedBox(height: 16),
              _buildResultIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeBadge() {
    IconData icon;
    String label;
    Color color;

    switch (widget.quiz.type) {
      case QuestionType.multipleChoice:
        icon = Icons.radio_button_checked;
        label = 'Multiple Choice';
        color = const Color(0xFF2196F3);
        break;
      case QuestionType.trueFalse:
        icon = Icons.check_circle;
        label = 'True/False';
        color = const Color(0xFF4CAF50);
        break;
      case QuestionType.shortAnswer:
        icon = Icons.edit;
        label = 'Short Answer';
        color = const Color(0xFF9C27B0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = selectedAnswer == option;
    final isCorrect = option == widget.quiz.correctAnswer;
    final showCorrect = widget.showResult && isCorrect;
    final showIncorrect = widget.showResult && isSelected && !isCorrect;

    Color borderColor;
    Color backgroundColor;

    if (showCorrect) {
      borderColor = const Color(0xFF4CAF50);
      backgroundColor = const Color(0xFFE8F5E9);
    } else if (showIncorrect) {
      borderColor = const Color(0xFFE57373);
      backgroundColor = const Color(0xFFFFEBEE);
    } else if (isSelected) {
      borderColor = const Color(0xFF2196F3);
      backgroundColor = const Color(0xFFE3F2FD);
    } else {
      borderColor = Colors.grey[300]!;
      backgroundColor = Colors.white;
    }

    return GestureDetector(
      onTap: widget.showResult
          ? null
          : () {
              setState(() {
                selectedAnswer = option;
              });
              if (widget.onAnswerSelected != null) {
                widget.onAnswerSelected!(option);
              }
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio button or checkmark
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                color: isSelected ? borderColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Option text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            
            // Result icon
            if (showCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
            else if (showIncorrect)
              const Icon(Icons.cancel, color: Color(0xFFE57373)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultIndicator() {
    final isCorrect = selectedAnswer == widget.quiz.correctAnswer;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE57373),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCorrect
                  ? 'Correct! Well done!'
                  : 'Incorrect. The correct answer is: ${widget.quiz.correctAnswer}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCorrect
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
