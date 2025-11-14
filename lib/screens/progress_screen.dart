import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../services/local_storage_service.dart';
import '../services/srs_service.dart';
import '../widgets/progress_circle.dart';

/// Progress screen showing learning statistics and SRS schedule
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  final SRSService _srsService = SRSService();
  
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Flashcard> _allFlashcards = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all flashcards
      final kits = await _storageService.getAllStudyKits();
      final List<Flashcard> allCards = [];
      
      for (final kit in kits) {
        final cards = await _storageService.getFlashcardsByKit(kit.id!);
        allCards.addAll(cards);
      }
      
      // Calculate statistics
      final stats = _srsService.calculateStats(allCards);
      final quizStats = await _storageService.getQuizStats();
      
      setState(() {
        _allFlashcards = allCards;
        _stats = {
          ...stats,
          'totalQuizzes': quizStats['total'],
          'correctQuizzes': quizStats['correct'],
          'quizAccuracy': quizStats['total']! > 0
              ? (quizStats['correct']! / quizStats['total']! * 100).round()
              : 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load progress: $e');
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
        title: const Text('Progress'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Progress Card
                    Card(
                      color: const Color(0xFFE8F5E9),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Overall Mastery',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ProgressCircle(
                              progress: (_stats['averageMastery'] as double?) ?? 0.0,
                              size: 150,
                              strokeWidth: 12,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${((_stats['averageMastery'] as double?) * 100 ?? 0).toInt()}% mastered',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Flashcard Statistics
                    const Text(
                      'Flashcard Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.style,
                            label: 'Total',
                            value: _stats['total']?.toString() ?? '0',
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.new_releases,
                            label: 'New',
                            value: _stats['new']?.toString() ?? '0',
                            color: const Color(0xFFFFB74D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.school,
                            label: 'Learning',
                            value: _stats['learning']?.toString() ?? '0',
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            label: 'Mastered',
                            value: _stats['mastered']?.toString() ?? '0',
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStatCard(
                      icon: Icons.today,
                      label: 'Due Today',
                      value: _stats['due']?.toString() ?? '0',
                      color: const Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 20),
                    
                    // Quiz Statistics
                    const Text(
                      'Quiz Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuizStat(
                                  icon: Icons.quiz,
                                  label: 'Total',
                                  value: _stats['totalQuizzes']?.toString() ?? '0',
                                  color: const Color(0xFF2196F3),
                                ),
                                _buildQuizStat(
                                  icon: Icons.check,
                                  label: 'Correct',
                                  value: _stats['correctQuizzes']?.toString() ?? '0',
                                  color: const Color(0xFF4CAF50),
                                ),
                                _buildQuizStat(
                                  icon: Icons.percent,
                                  label: 'Accuracy',
                                  value: '${_stats['quizAccuracy']}%',
                                  color: const Color(0xFFE91E63),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Study Recommendation
                    if ((_stats['due'] as int?) ?? 0 > 0) ...[
                      const Text(
                        'Study Recommendation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Card(
                        color: const Color(0xFFFFF9C4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                size: 40,
                                color: Color(0xFFF57C00),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Time to study!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Recommended: ${_srsService.getRecommendedStudyDuration(_stats['due'] as int)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/study_session')
                                      .then((_) => _loadProgress());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF57C00),
                                ),
                                child: const Text('Study Now'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildQuizStat({
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
