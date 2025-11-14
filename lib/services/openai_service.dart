import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';

/// Service for interacting with OpenAI API
/// Handles text summarization, flashcard generation, and quiz creation
class OpenAIService {
  final String apiKey;
  final String apiUrl;
  final String model;

  OpenAIService({
    String? apiKey,
    String? apiUrl,
    String? model,
  })  : apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '',
        apiUrl = apiUrl ?? dotenv.env['OPENAI_API_URL'] ?? 'https://api.openai.com/v1',
        model = model ?? dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';

  /// Summarize text into key points using OpenAI
  Future<String> summarizeText(String text) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final prompt = 'Summarize the following text into 5 key points:\n\n$text';
    
    try {
      final response = await _makeRequest(prompt);
      return response;
    } catch (e) {
      throw Exception('Failed to summarize text: $e');
    }
  }

  /// Generate flashcards from text using OpenAI
  /// Returns a list of flashcards with front/back content
  Future<List<Map<String, String>>> generateFlashcards(String text) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final prompt = '''
Create flashcards from the following text. Return ONLY a JSON array with objects containing "front" and "back" fields. Do not include any other text or explanation.

Format: [{"front": "question", "back": "answer"}, ...]

Text:
$text
''';

    try {
      final response = await _makeRequest(prompt);
      
      // Parse JSON response
      final jsonStr = _extractJson(response);
      final List<dynamic> jsonData = json.decode(jsonStr);
      
      return jsonData.map((item) => {
        'front': item['front'] as String,
        'back': item['back'] as String,
      }).toList();
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }

  /// Generate quiz questions from text using OpenAI
  /// Returns a list of quiz questions with options and answers
  Future<List<Map<String, dynamic>>> generateQuiz(String text) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final prompt = '''
Generate 5 multiple-choice questions from the following text. Return ONLY a JSON array with objects containing "question", "options" (array of 4 strings), and "answer" (the correct option) fields. Do not include any other text or explanation.

Format: [{"question": "...", "options": ["A", "B", "C", "D"], "answer": "correct option"}, ...]

Text:
$text
''';

    try {
      final response = await _makeRequest(prompt);
      
      // Parse JSON response
      final jsonStr = _extractJson(response);
      final List<dynamic> jsonData = json.decode(jsonStr);
      
      return jsonData.map((item) => {
        'question': item['question'] as String,
        'options': (item['options'] as List<dynamic>).cast<String>(),
        'answer': item['answer'] as String,
      }).toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  /// Make an HTTP request to OpenAI API
  Future<String> _makeRequest(String prompt) async {
    final url = Uri.parse('$apiUrl/chat/completions');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = json.encode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.7,
      'max_tokens': 2000,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Extract JSON from response text (handles cases where model includes extra text)
  String _extractJson(String text) {
    // Try to find JSON array or object in the response
    final arrayMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
    if (arrayMatch != null) {
      return arrayMatch.group(0)!;
    }
    
    final objectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (objectMatch != null) {
      return objectMatch.group(0)!;
    }
    
    return text.trim();
  }
}
