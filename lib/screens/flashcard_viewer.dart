import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../services/local_storage_service.dart';
import '../services/srs_service.dart';

/// Flashcard viewer screen for studying flashcards from a specific kit
class FlashcardViewer extends ConsumerStatefulWidget {
  final int kitId;

  const FlashcardViewer({Key? key, required this.kitId}) : super(key: key);

  @override
  ConsumerState<FlashcardViewer> createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends ConsumerState<FlashcardViewer> {
  final LocalStorageService _storageService = LocalStorageService();
  final SRSService _srsService = SRSService();
  final PageController _pageController = PageController();
  
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() => _isLoading = true);
    
    try {
      final cards = await _storageService.getFlashcardsByKit(widget.kitId);
      setState(() {
        _flashcards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load flashcards: $e');
    }
  }

  Future<void> _rateCard(int quality) async {
    if (_currentIndex >= _flashcards.length) return;

    final currentCard = _flashcards[_currentIndex];
    final updatedCard = _srsService.calculateNextReview(currentCard, quality);
    
    try {
      await _storageService.updateFlashcard(updatedCard);
      
      // Update local list
      setState(() {
        _flashcards[_currentIndex] = updatedCard;
      });
      
      // Move to next card
      if (_currentIndex < _flashcards.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showCompletionDialog();
      }
    } catch (e) {
      _showError('Failed to update flashcard: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great job!'),
        content: const Text('You\'ve completed all flashcards in this kit.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          if (_flashcards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${_flashcards.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flashcards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No flashcards available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _flashcards.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                    
                    // Flashcard PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _flashcards.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                            _showAnswer = false;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _showAnswer = !_showAnswer);
                                },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _buildFlashcard(
                                    _flashcards[index],
                                    _showAnswer,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // SRS Status
                    if (_flashcards.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          color: const Color(0xFFFFF9C4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${_srsService.getStatusDescription(_flashcards[_currentIndex])}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Mastery: ${(_srsService.getMasteryLevel(_flashcards[_currentIndex]) * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    
                    // Action buttons
                    if (_showAnswer)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'How well did you know this?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRatingButton(
                                    label: 'Again',
                                    color: const Color(0xFFE57373),
                                    quality: 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildRatingButton(
                                    label: 'Hard',
                                    color: const Color(0xFFFFB74D),
                                    quality: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildRatingButton(
                                    label: 'Good',
                                    color: const Color(0xFF81C784),
                                    quality: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildRatingButton(
                                    label: 'Easy',
                                    color: const Color(0xFF4CAF50),
                                    quality: 3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _showAnswer = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Show Answer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildFlashcard(Flashcard card, bool showAnswer) {
    return Card(
      key: ValueKey(showAnswer),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: showAnswer
                ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]
                : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showAnswer ? Icons.lightbulb : Icons.help_outline,
              size: 40,
              color: showAnswer
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            Text(
              showAnswer ? 'Answer' : 'Question',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    showAnswer ? card.back : card.front,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (!showAnswer) ...[
              const SizedBox(height: 16),
              Text(
                'Tap to reveal answer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required int quality,
  }) {
    return ElevatedButton(
      onPressed: () => _rateCard(quality),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
