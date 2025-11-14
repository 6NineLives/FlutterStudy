# StudyAI - AI-Powered Study Assistant

StudyAI is a comprehensive Flutter application that leverages OpenAI's GPT models to transform study materials into interactive flashcards, quizzes, and summaries. The app uses the SM-2 spaced repetition algorithm to optimize learning and retention.

## Features

### 🎯 Core Features
- **Smart Import**: Import study materials from PDFs, images, or text files
- **AI-Powered Generation**: Automatically generate:
  - Concise summaries of study materials
  - Flashcards with question/answer pairs
  - Multiple-choice quizzes
- **Spaced Repetition System (SRS)**: SM-2 algorithm for optimal review scheduling
- **Offline Support**: Local SQLite database for caching all content
- **Progress Tracking**: Comprehensive statistics and mastery levels
- **Modern UI**: Clean, pastel-themed, card-based design

### 📚 Study Tools
- **Flashcard Viewer**: Interactive front/back flashcard review with SRS rating
- **Quiz Mode**: Multiple-choice questions with instant feedback
- **Study Sessions**: Review due flashcards based on SRS schedule
- **Progress Dashboard**: Track learning statistics and mastery levels

## Project Structure

```
lib/
├── main.dart                          # App entry point and routing
├── models/                            # Data models
│   ├── flashcard.dart                 # Flashcard model with SRS fields
│   ├── quiz.dart                      # Quiz question model
│   └── study_kit.dart                 # Study kit container model
├── services/                          # Business logic services
│   ├── openai_service.dart           # OpenAI API integration
│   ├── local_storage_service.dart    # SQLite database operations
│   └── srs_service.dart              # SM-2 spaced repetition algorithm
├── screens/                           # UI screens
│   ├── splash_screen.dart            # App splash screen
│   ├── home_screen.dart              # Main dashboard
│   ├── import_screen.dart            # Material import interface
│   ├── kit_detail_screen.dart        # Study kit details
│   ├── study_session_screen.dart     # SRS review session
│   ├── flashcard_viewer.dart         # Flashcard study interface
│   ├── quiz_viewer.dart              # Quiz taking interface
│   └── progress_screen.dart          # Statistics and progress
├── widgets/                           # Reusable UI components
│   ├── card_widget.dart              # Custom card components
│   ├── progress_circle.dart          # Circular progress indicators
│   └── quiz_card.dart                # Quiz question card
└── utils/                             # Helper utilities
    ├── api_helper.dart               # API retry and error handling
    └── file_import_helper.dart       # File picking and reading
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/6NineLives/FlutterStudy.git
   cd FlutterStudy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and add your OpenAI API key:
     ```
     OPENAI_API_KEY=your_actual_api_key_here
     OPENAI_API_URL=https://api.openai.com/v1
     OPENAI_MODEL=gpt-3.5-turbo
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

### Core
- `flutter_riverpod` - State management
- `sqflite` - Local SQLite database
- `path_provider` - File system paths
- `http` - HTTP requests
- `flutter_dotenv` - Environment variable management

### File Handling
- `file_picker` - File selection
- `image_picker` - Image/camera access
- `flutter_pdfview` - PDF viewing

### UI Components
- `flutter_slidable` - Swipeable list items
- `intl` - Internationalization and formatting

## Usage

### Importing Study Materials

1. Tap the **Import** button or the floating action button on the home screen
2. Choose your input method:
   - **PDF**: Select a PDF file from your device
   - **Image**: Take a photo or select from gallery
   - **Text**: Paste text directly or select a text file
3. Enter a title for your study kit
4. Tap **Generate Flashcards & Quizzes**
5. Wait for AI processing to complete

### Studying with Flashcards

1. Select a study kit from the home screen
2. Tap **Study** in the flashcards section
3. Read the question and tap **Show Answer**
4. Rate your recall:
   - **Again**: Didn't remember (review soon)
   - **Hard**: Remembered with difficulty
   - **Good**: Remembered correctly
   - **Easy**: Remembered easily

### Taking Quizzes

1. Select a study kit
2. Tap **Take Quiz** in the quizzes section
3. Select your answer for each question
4. View results and accuracy at the end

### Tracking Progress

1. Navigate to the **Progress** tab
2. View:
   - Overall mastery percentage
   - New, learning, and mastered card counts
   - Due cards for today
   - Quiz accuracy statistics

## SRS Algorithm (SM-2)

The app uses the SuperMemo 2 (SM-2) algorithm for spaced repetition:

- **New cards**: Review after 1 day
- **First repetition**: Review after 1 day
- **Second repetition**: Review after 6 days
- **Subsequent repetitions**: Interval multiplied by easiness factor (1.3-2.5)
- **Failed cards**: Reset to day 1

Rating affects easiness factor and next review interval:
- **Again (0)**: Resets progress
- **Hard (1)**: Reduces easiness slightly
- **Good (2)**: Maintains easiness
- **Easy (3)**: Increases easiness

## Offline Support

All AI-generated content is cached locally in SQLite:
- Summaries are saved with study kits
- Flashcards persist with SRS metadata
- Quiz questions and answers are stored
- Progress statistics are calculated from local data

This allows you to:
- Study without internet connection
- Minimize API costs
- Access materials instantly

## Customization

### Adjusting AI Prompts
Edit `lib/services/openai_service.dart` to customize:
- Summary generation prompts
- Flashcard creation format
- Quiz question types and difficulty

### Changing UI Colors
The pastel color scheme can be adjusted in:
- `lib/main.dart` - Theme colors
- Individual screen files - Component colors

### Modifying SRS Parameters
Edit `lib/services/srs_service.dart` to adjust:
- Initial intervals
- Easiness factor calculations
- Mastery thresholds

## API Costs

The app makes OpenAI API calls for:
- **Summarization**: ~500-1000 tokens per request
- **Flashcard generation**: ~1000-2000 tokens per request
- **Quiz generation**: ~1000-2000 tokens per request

Average cost per study kit: $0.02-$0.05 (using gpt-3.5-turbo)

All content is cached locally, so each study kit only incurs API costs once during import.

## Troubleshooting

### Common Issues

**App crashes on startup**
- Ensure `.env` file exists (create from `.env.example`)
- Check Flutter SDK version: `flutter --version`

**"OpenAI API key not configured" error**
- Verify `.env` file contains valid API key
- Restart the app after editing `.env`

**PDF import not working**
- Check file permissions in AndroidManifest.xml / Info.plist
- Ensure PDF file is not corrupted

**Database errors**
- Clear app data and restart
- Run: `flutter clean && flutter pub get`

## Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

### Code Generation
If you modify models with `@JsonSerializable`:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is open source and available under the MIT License.

## Credits

- OpenAI API for AI-powered content generation
- Flutter framework and community packages
- SM-2 algorithm by Piotr Woźniak

## Contact

For questions or support, please open an issue on GitHub.

---

**Made with ❤️ for better learning**