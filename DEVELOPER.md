# StudyAI - Developer Documentation

## Architecture Overview

StudyAI follows a clean, layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, UI Components)      │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│          Business Logic Layer           │
│      (Services, State Management)       │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│            Data Layer                   │
│  (Models, Local Storage, API Calls)     │
└─────────────────────────────────────────┘
```

## Project Structure

### Core Directories

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── services/                    # Business logic
├── screens/                     # UI screens
├── widgets/                     # Reusable components
└── utils/                       # Helper functions
```

## Key Components

### 1. Models (`lib/models/`)

**Purpose:** Define data structures for the application

#### Flashcard Model
- Fields: front, back, easiness, interval, repetitions, dueDate
- SRS metadata included for spaced repetition
- JSON serialization support
- Database mapping methods

#### Quiz Model
- Fields: question, type, options, correctAnswer, userAnswer
- Support for multiple question types
- Answer validation logic

#### StudyKit Model
- Container for study materials
- Tracks flashcard/quiz counts
- Stores AI-generated summaries

### 2. Services (`lib/services/`)

**Purpose:** Implement business logic and external integrations

#### OpenAI Service (`openai_service.dart`)
```dart
class OpenAIService {
  // Generate summary from text
  Future<String> summarizeText(String text)
  
  // Create flashcards from content
  Future<List<Map<String, String>>> generateFlashcards(String text)
  
  // Generate quiz questions
  Future<List<Map<String, dynamic>>> generateQuiz(String text)
}
```

**Key Features:**
- Direct REST API integration
- JSON response parsing
- Error handling with retries
- Configurable via environment variables

#### Local Storage Service (`local_storage_service.dart`)
```dart
class LocalStorageService {
  // Study Kits
  Future<int> insertStudyKit(StudyKit kit)
  Future<List<StudyKit>> getAllStudyKits()
  Future<StudyKit?> getStudyKit(int id)
  
  // Flashcards
  Future<int> insertFlashcard(Flashcard flashcard)
  Future<List<Flashcard>> getFlashcardsByKit(int kitId)
  Future<List<Flashcard>> getDueFlashcards()
  
  // Quizzes
  Future<int> insertQuiz(Quiz quiz)
  Future<List<Quiz>> getQuizzesByKit(int kitId)
}
```

**Key Features:**
- SQLite database with proper schema
- CRUD operations for all entities
- Foreign key relationships
- Efficient querying with indexes
- Statistics calculations

#### SRS Service (`srs_service.dart`)
```dart
class SRSService {
  // Calculate next review based on performance
  Flashcard calculateNextReview(Flashcard flashcard, int quality)
  
  // Get mastery level (0.0 - 1.0)
  double getMasteryLevel(Flashcard flashcard)
  
  // Calculate learning statistics
  Map<String, dynamic> calculateStats(List<Flashcard> flashcards)
}
```

**Key Features:**
- SM-2 algorithm implementation
- Quality ratings: 0 (Again) to 3 (Easy)
- Adaptive interval calculation
- Mastery tracking

### 3. Screens (`lib/screens/`)

**Purpose:** Implement user interface screens

#### Screen Flow
```
SplashScreen
    ↓
HomeScreen ←→ ImportScreen
    ↓            ↓
KitDetailScreen  ↓
    ↓            ↓
FlashcardViewer  QuizViewer
    ↓            ↓
StudySessionScreen
    ↓
ProgressScreen
```

Each screen follows this pattern:
```dart
class ScreenName extends ConsumerStatefulWidget {
  @override
  ConsumerState<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends ConsumerState<ScreenName> {
  // Services
  final ServiceName _service = ServiceName();
  
  // State
  bool _isLoading = true;
  List<Model> _data = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Load data from services
  }
  
  @override
  Widget build(BuildContext context) {
    // Build UI
  }
}
```

### 4. Widgets (`lib/widgets/`)

**Purpose:** Reusable UI components

#### CardWidget
- Consistent card design across app
- Configurable colors, padding, tap handlers
- Pastel color scheme

#### ProgressCircle
- Circular progress indicator
- Shows mastery levels
- Color-coded by progress

#### QuizCard
- Interactive quiz question display
- Multiple-choice UI
- Answer feedback

### 5. Utils (`lib/utils/`)

**Purpose:** Helper functions and utilities

#### API Helper
- Retry logic for failed requests
- Timeout handling
- Error message formatting

#### File Import Helper
- File picking (PDF, image, text)
- File reading and parsing
- Format validation

## Data Flow

### Creating a Study Kit

```
User → ImportScreen
  ↓
Pick file/paste text
  ↓
FileImportHelper.pickFile()
  ↓
OpenAIService.summarizeText()
OpenAIService.generateFlashcards()
OpenAIService.generateQuiz()
  ↓
LocalStorageService.insertStudyKit()
LocalStorageService.insertFlashcards()
LocalStorageService.insertQuizzes()
  ↓
Navigate to HomeScreen
```

### Studying Flashcards

```
User → KitDetailScreen
  ↓
Tap "Study"
  ↓
FlashcardViewer
  ↓
Show card → User rates → SRSService.calculateNextReview()
  ↓
LocalStorageService.updateFlashcard()
  ↓
Next card or completion
```

### Taking a Quiz

```
User → KitDetailScreen
  ↓
Tap "Take Quiz"
  ↓
QuizViewer
  ↓
Display question → User selects answer
  ↓
Check correctness → Show feedback
  ↓
LocalStorageService.updateQuiz()
  ↓
Next question or show results
```

## State Management

Uses **Riverpod** for state management:

```dart
// Provider example (can be extended)
final studyKitsProvider = FutureProvider<List<StudyKit>>((ref) async {
  final storage = LocalStorageService();
  return await storage.getAllStudyKits();
});
```

Current implementation uses `ConsumerStatefulWidget` with local state.
Can be extended to use providers for global state.

## Database Schema

### study_kits
```sql
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
```

### flashcards
```sql
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
```

### quizzes
```sql
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
```

## API Integration

### OpenAI API Calls

All API calls go through `OpenAIService`:

```dart
// Example request
POST https://api.openai.com/v1/chat/completions
Headers:
  Authorization: Bearer {API_KEY}
  Content-Type: application/json
Body:
  {
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "{prompt}"}],
    "temperature": 0.7,
    "max_tokens": 2000
  }
```

### Cost Optimization

- Cache all responses locally
- Single API call per study kit
- Batch operations where possible
- Estimated cost: $0.02-$0.05 per kit

## Testing Strategy

### Unit Tests
```dart
// Example test structure
test('SRS calculates correct intervals', () {
  final srs = SRSService();
  final card = Flashcard(...);
  final updated = srs.calculateNextReview(card, 3);
  expect(updated.interval, greaterThan(card.interval));
});
```

### Widget Tests
```dart
testWidgets('HomeScreen displays study kits', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('StudyAI'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Complete study flow', (tester) async {
  // Test full user journey
});
```

## Performance Considerations

### Optimization Strategies

1. **Database Indexing**
   - Index on `kit_id` for quick lookups
   - Index on `due_date` for SRS queries

2. **Lazy Loading**
   - Load data only when needed
   - Paginate large lists

3. **Caching**
   - Cache API responses
   - Store computed values

4. **UI Optimization**
   - Use `const` constructors
   - Implement `ListView.builder` for long lists
   - Minimize rebuilds with keys

## Security Best Practices

### API Key Protection
- Never commit `.env` file
- Use environment variables
- Validate on server side if possible

### Data Privacy
- All data stored locally
- No user data sent to servers (except OpenAI content)
- Clear data on uninstall

### Input Validation
- Sanitize user inputs
- Validate file types
- Check content length

## Extending the App

### Adding New Features

#### 1. New Screen
```dart
// 1. Create screen file
lib/screens/new_screen.dart

// 2. Add route in main.dart
routes: {
  '/new_screen': (context) => const NewScreen(),
}

// 3. Navigate from anywhere
Navigator.pushNamed(context, '/new_screen');
```

#### 2. New Model
```dart
// 1. Create model file
lib/models/new_model.dart

// 2. Add JSON serialization
@JsonSerializable()
class NewModel { ... }

// 3. Run code generation
flutter pub run build_runner build
```

#### 3. New Service
```dart
// 1. Create service file
lib/services/new_service.dart

// 2. Implement methods
class NewService {
  Future<void> doSomething() async { ... }
}

// 3. Use in screens
final _service = NewService();
```

### Customization Points

#### Change Colors
`lib/main.dart`:
```dart
theme: ThemeData(
  primaryColor: const Color(0xYOURCOLOR),
  // ...
)
```

#### Modify AI Prompts
`lib/services/openai_service.dart`:
```dart
final prompt = 'Your custom prompt: $text';
```

#### Adjust SRS Algorithm
`lib/services/srs_service.dart`:
```dart
// Modify interval calculations
if (repetitions == 1) {
  interval = YOUR_VALUE;
}
```

## Troubleshooting

### Common Developer Issues

**Build errors after adding dependencies**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

**Database schema changes**
```dart
// Increment version in local_storage_service.dart
static const int _databaseVersion = 2;

// Add migration logic
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE ...');
  }
}
```

**API changes not reflected**
```bash
# Clear app data
flutter clean

# Reinstall app
flutter run
```

## Best Practices

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Git Workflow
- Create feature branches
- Write descriptive commits
- Test before committing
- Update documentation

### Performance
- Profile with Flutter DevTools
- Optimize hot paths
- Use async/await properly
- Avoid blocking operations

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

**Happy coding! 🚀**
