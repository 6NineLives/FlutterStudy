import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_kit.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../services/openai_service.dart';
import '../services/local_storage_service.dart';
import '../utils/file_import_helper.dart';

/// Import screen for adding new study materials
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final FileImportHelper _fileHelper = FileImportHelper();
  final LocalStorageService _storageService = LocalStorageService();
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  File? _selectedFile;
  String? _sourceType;
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String _processingStatus = '';

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      File? file;
      
      switch (type) {
        case 'pdf':
          file = await _fileHelper.pickPDFFile();
          break;
        case 'image':
          file = await _fileHelper.pickImageFile();
          break;
        case 'text':
          file = await _fileHelper.pickTextFile();
          break;
      }

      if (file != null) {
        setState(() {
          _selectedFile = file;
          _sourceType = type;
          _titleController.text = _fileHelper.getFileName(file.path);
        });
        
        // Load text content if it's a text file
        if (type == 'text') {
          final content = await _fileHelper.readTextFromFile(file);
          setState(() {
            _textController.text = content;
          });
        }
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _processAndSave() async {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }

    if (_textController.text.isEmpty && _selectedFile == null) {
      _showError('Please provide study material');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingProgress = 0.0;
      _processingStatus = 'Preparing content...';
    });

    try {
      // Get text content
      String content = _textController.text;
      if (_selectedFile != null && _sourceType == 'text') {
        content = await _fileHelper.readTextFromFile(_selectedFile!);
      }

      if (content.isEmpty) {
        throw Exception('No content to process');
      }

      // Create study kit
      setState(() {
        _processingProgress = 0.2;
        _processingStatus = 'Creating study kit...';
      });

      final kit = StudyKit(
        title: _titleController.text,
        sourceType: _sourceType ?? 'text',
        filePath: _selectedFile?.path,
        content: content,
      );

      final kitId = await _storageService.insertStudyKit(kit);

      // Generate summary
      setState(() {
        _processingProgress = 0.3;
        _processingStatus = 'Generating summary...';
      });

      String? summary;
      try {
        summary = await _openAIService.summarizeText(content);
      } catch (e) {
        print('Failed to generate summary: $e');
        summary = 'Summary generation failed. Please check your API key.';
      }

      // Generate flashcards
      setState(() {
        _processingProgress = 0.5;
        _processingStatus = 'Creating flashcards...';
      });

      List<Flashcard> flashcards = [];
      try {
        final flashcardData = await _openAIService.generateFlashcards(content);
        flashcards = flashcardData
            .map((data) => Flashcard(
                  kitId: kitId,
                  front: data['front']!,
                  back: data['back']!,
                ))
            .toList();
        
        if (flashcards.isNotEmpty) {
          await _storageService.insertFlashcards(flashcards);
        }
      } catch (e) {
        print('Failed to generate flashcards: $e');
      }

      // Generate quizzes
      setState(() {
        _processingProgress = 0.7;
        _processingStatus = 'Creating quizzes...';
      });

      List<Quiz> quizzes = [];
      try {
        final quizData = await _openAIService.generateQuiz(content);
        quizzes = quizData
            .map((data) => Quiz(
                  kitId: kitId,
                  question: data['question'] as String,
                  type: QuestionType.multipleChoice,
                  options: data['options'] as List<String>,
                  correctAnswer: data['answer'] as String,
                ))
            .toList();
        
        if (quizzes.isNotEmpty) {
          await _storageService.insertQuizzes(quizzes);
        }
      } catch (e) {
        print('Failed to generate quizzes: $e');
      }

      // Update study kit with counts and summary
      setState(() {
        _processingProgress = 0.9;
        _processingStatus = 'Finalizing...';
      });

      final updatedKit = kit.copyWith(
        id: kitId,
        summary: summary,
        flashcardCount: flashcards.length,
        quizCount: quizzes.length,
      );
      await _storageService.updateStudyKit(updatedKit);

      setState(() {
        _processingProgress = 1.0;
        _processingStatus = 'Complete!';
      });

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Study kit created! '
              '${flashcards.length} flashcards, ${quizzes.length} quizzes',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to process: $e');
    } finally {
      setState(() => _isProcessing = false);
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
        title: const Text('Import Study Material'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title input
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Import options
                  const Text(
                    'Import from:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildImportOption(
                          icon: Icons.picture_as_pdf,
                          label: 'PDF',
                          color: const Color(0xFFE57373),
                          onTap: () => _pickFile('pdf'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImportOption(
                          icon: Icons.image,
                          label: 'Image',
                          color: const Color(0xFF64B5F6),
                          onTap: () => _pickFile('image'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImportOption(
                          icon: Icons.text_snippet,
                          label: 'Text',
                          color: const Color(0xFF81C784),
                          onTap: () => _pickFile('text'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Selected file display
                  if (_selectedFile != null) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.attach_file),
                        title: Text(_fileHelper.getFileName(_selectedFile!.path)),
                        subtitle: Text(_fileHelper.getFileSizeString(_selectedFile!)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _sourceType = null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Text input
                  const Text(
                    'Or paste text:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _textController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Paste your study material here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Process button
                  ElevatedButton(
                    onPressed: _processAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate Flashcards & Quizzes',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _processingProgress,
              strokeWidth: 6,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 24),
            Text(
              _processingStatus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_processingProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
