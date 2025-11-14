import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_kit.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../services/local_storage_service.dart';

/// Kit detail screen showing summary, flashcards, and quizzes for a study kit
class KitDetailScreen extends ConsumerStatefulWidget {
  final int kitId;

  const KitDetailScreen({Key? key, required this.kitId}) : super(key: key);

  @override
  ConsumerState<KitDetailScreen> createState() => _KitDetailScreenState();
}

class _KitDetailScreenState extends ConsumerState<KitDetailScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  
  StudyKit? _kit;
  List<Flashcard> _flashcards = [];
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final kit = await _storageService.getStudyKit(widget.kitId);
      final flashcards = await _storageService.getFlashcardsByKit(widget.kitId);
      final quizzes = await _storageService.getQuizzesByKit(widget.kitId);
      
      setState(() {
        _kit = kit;
        _flashcards = flashcards;
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: $e');
    }
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
        title: Text(_kit?.title ?? 'Study Kit'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Study Kit'),
                  content: const Text('Are you sure you want to delete this study kit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _storageService.deleteStudyKit(widget.kitId);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section
                  if (_kit?.summary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFFE8F5E9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.summarize, color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _kit!.summary!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Flashcards Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Flashcards',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _flashcards.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pushNamed(
                                        context,
                                        '/flashcard_viewer',
                                        arguments: widget.kitId,
                                      );
                                    },
                              child: const Text('Study'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        if (_flashcards.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No flashcards available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _flashcards.length,
                              itemBuilder: (context, index) {
                                final flashcard = _flashcards[index];
                                return Container(
                                  width: 200,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(
                                    color: const Color(0xFFE3F2FD),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            flashcard.front,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Text(
                                            flashcard.back,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quizzes Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quizzes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _quizzes.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pushNamed(
                                        context,
                                        '/quiz_viewer',
                                        arguments: widget.kitId,
                                      );
                                    },
                              child: const Text('Take Quiz'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        if (_quizzes.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No quizzes available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _quizzes.take(3).map((quiz) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.quiz,
                                    color: Color(0xFFE91E63),
                                  ),
                                  title: Text(
                                    quiz.question,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: quiz.isCorrect != null
                                      ? Icon(
                                          quiz.isCorrect!
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: quiz.isCorrect!
                                              ? Colors.green
                                              : Colors.red,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
