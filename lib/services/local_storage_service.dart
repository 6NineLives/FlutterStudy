import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../models/study_kit.dart';

/// Service for managing local SQLite database
/// Handles storage and retrieval of study kits, flashcards, and quizzes
class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'study_ai.db';
  static const int _databaseVersion = 1;

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Study Kits table
    await db.execute('''
      CREATE TABLE study_kits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        summary TEXT,
        source_type TEXT NOT NULL,
        file_path TEXT,
        content TEXT,
        flashcard_count INTEGER DEFAULT 0,
        quiz_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Flashcards table
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kit_id INTEGER NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        easiness REAL DEFAULT 2.5,
        interval INTEGER DEFAULT 0,
        repetitions INTEGER DEFAULT 0,
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (kit_id) REFERENCES study_kits (id) ON DELETE CASCADE
      )
    ''');

    // Quizzes table
    await db.execute('''
      CREATE TABLE quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kit_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        type TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        user_answer TEXT,
        is_correct INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (kit_id) REFERENCES study_kits (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_flashcards_kit_id ON flashcards(kit_id)');
    await db.execute('CREATE INDEX idx_flashcards_due_date ON flashcards(due_date)');
    await db.execute('CREATE INDEX idx_quizzes_kit_id ON quizzes(kit_id)');
  }

  // ==================== Study Kit Operations ====================

  /// Insert a new study kit
  Future<int> insertStudyKit(StudyKit kit) async {
    final db = await database;
    return await db.insert('study_kits', kit.toMap());
  }

  /// Get all study kits
  Future<List<StudyKit>> getAllStudyKits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_kits',
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => StudyKit.fromMap(map)).toList();
  }

  /// Get a single study kit by ID
  Future<StudyKit?> getStudyKit(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_kits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StudyKit.fromMap(maps.first);
  }

  /// Update a study kit
  Future<int> updateStudyKit(StudyKit kit) async {
    final db = await database;
    return await db.update(
      'study_kits',
      kit.toMap(),
      where: 'id = ?',
      whereArgs: [kit.id],
    );
  }

  /// Delete a study kit
  Future<int> deleteStudyKit(int id) async {
    final db = await database;
    return await db.delete(
      'study_kits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Flashcard Operations ====================

  /// Insert a new flashcard
  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcards', flashcard.toMap());
  }

  /// Insert multiple flashcards
  Future<void> insertFlashcards(List<Flashcard> flashcards) async {
    final db = await database;
    final batch = db.batch();
    for (final flashcard in flashcards) {
      batch.insert('flashcards', flashcard.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Get all flashcards for a study kit
  Future<List<Flashcard>> getFlashcardsByKit(int kitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      where: 'kit_id = ?',
      whereArgs: [kitId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Flashcard.fromMap(map)).toList();
  }

  /// Get due flashcards (for SRS review)
  Future<List<Flashcard>> getDueFlashcards() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      where: 'due_date IS NULL OR due_date <= ?',
      whereArgs: [now],
      orderBy: 'due_date ASC',
    );
    return maps.map((map) => Flashcard.fromMap(map)).toList();
  }

  /// Update a flashcard (e.g., after SRS review)
  Future<int> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }

  /// Delete a flashcard
  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Quiz Operations ====================

  /// Insert a new quiz
  Future<int> insertQuiz(Quiz quiz) async {
    final db = await database;
    return await db.insert('quizzes', quiz.toMap());
  }

  /// Insert multiple quizzes
  Future<void> insertQuizzes(List<Quiz> quizzes) async {
    final db = await database;
    final batch = db.batch();
    for (final quiz in quizzes) {
      batch.insert('quizzes', quiz.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Get all quizzes for a study kit
  Future<List<Quiz>> getQuizzesByKit(int kitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quizzes',
      where: 'kit_id = ?',
      whereArgs: [kitId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// Update a quiz (e.g., after answering)
  Future<int> updateQuiz(Quiz quiz) async {
    final db = await database;
    return await db.update(
      'quizzes',
      quiz.toMap(),
      where: 'id = ?',
      whereArgs: [quiz.id],
    );
  }

  /// Delete a quiz
  Future<int> deleteQuiz(int id) async {
    final db = await database;
    return await db.delete(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Statistics Operations ====================

  /// Get total number of flashcards across all kits
  Future<int> getTotalFlashcardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM flashcards');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get number of due flashcards
  Future<int> getDueFlashcardCount() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flashcards WHERE due_date IS NULL OR due_date <= ?',
      [now],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get quiz statistics
  Future<Map<String, int>> getQuizStats() async {
    final db = await database;
    final total = await db.rawQuery('SELECT COUNT(*) as count FROM quizzes');
    final correct = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quizzes WHERE is_correct = 1',
    );
    
    return {
      'total': Sqflite.firstIntValue(total) ?? 0,
      'correct': Sqflite.firstIntValue(correct) ?? 0,
    };
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
