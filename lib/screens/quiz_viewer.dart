import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../services/local_storage_service.dart';
import '../widgets/quiz_card.dart';

/// Quiz viewer screen for taking quizzes from a specific kit
class QuizViewer extends ConsumerStatefulWidget {
  final int kitId;

  const QuizViewer({Key? key, required this.kitId}) : super(key: key);

  @override
  ConsumerState<QuizViewer> createState() => _QuizViewerState();
}

class _QuizViewerState extends ConsumerState<QuizViewer> {
  final LocalStorageService _storageService = LocalStorageService();
  final PageController _pageController = PageController();
  
  List<Quiz> _quizzes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showResults = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    
    try {
      final quizzes = await _storageService.getQuizzesByKit(widget.kitId);
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load quizzes: $e');
    }
  }

  Future<void> _submitAnswer(String answer) async {
    if (_currentIndex >= _quizzes.length) return;

    final currentQuiz = _quizzes[_currentIndex];
    final isCorrect = answer == currentQuiz.correctAnswer;
    
    final updatedQuiz = currentQuiz.copyWith(
      userAnswer: answer,
      isCorrect: isCorrect,
    );
    
    try {
      await _storageService.updateQuiz(updatedQuiz);
      
      // Update local list
      setState(() {
        _quizzes[_currentIndex] = updatedQuiz;
        if (isCorrect) _correctCount++;
      });
      
      // Wait a moment then move to next
      await Future.delayed(const Duration(seconds: 2));
      
      if (_currentIndex < _quizzes.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _showResults = true);
      }
    } catch (e) {
      _showError('Failed to submit answer: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _retakeQuiz() {
    setState(() {
      _currentIndex = 0;
      _showResults = false;
      _correctCount = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color(0xFFE91E63),
        actions: [
          if (!_showResults && _quizzes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${_quizzes.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No quizzes available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _showResults
                  ? _buildResultsView()
                  : Column(
                      children: [
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (_currentIndex + 1) / _quizzes.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE91E63),
                          ),
                        ),
                        
                        // Quiz PageView
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _quizzes.length,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: QuizCard(
                                  quiz: _quizzes[index],
                                  onAnswerSelected: _submitAnswer,
                                  showResult: _quizzes[index].userAnswer != null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildResultsView() {
    final percentage = (_correctCount / _quizzes.length * 100).round();
    final passed = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.refresh,
              size: 100,
              color: passed ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Congratulations!' : 'Keep practicing!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount out of ${_quizzes.length} correct',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            
            // Review breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Quiz Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle,
                          label: 'Correct',
                          value: _correctCount.toString(),
                          color: Colors.green,
                        ),
                        _buildStatItem(
                          icon: Icons.cancel,
                          label: 'Incorrect',
                          value: (_quizzes.length - _correctCount).toString(),
                          color: Colors.red,
                        ),
                        _buildStatItem(
                          icon: Icons.percent,
                          label: 'Score',
                          value: '$percentage%',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retakeQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Retake Quiz'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
