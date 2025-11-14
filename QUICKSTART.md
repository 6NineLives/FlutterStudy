# StudyAI - Quick Start Guide

Get started with StudyAI in just a few minutes!

## Prerequisites

Before you begin, ensure you have:
- ✅ Flutter SDK 3.0.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- ✅ Dart SDK 3.0.0 or higher (included with Flutter)
- ✅ Android Studio / Xcode (for mobile development)
- ✅ OpenAI API Key ([Get one here](https://platform.openai.com/api-keys))

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/6NineLives/FlutterStudy.git
cd FlutterStudy
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will download all required packages including:
- flutter_riverpod (state management)
- sqflite (local database)
- http (API calls)
- flutter_dotenv (environment variables)
- file_picker, image_picker (file imports)
- And more...

### 3. Configure OpenAI API Key

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` and add your OpenAI API key:

```
OPENAI_API_KEY=sk-your-actual-api-key-here
OPENAI_API_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-3.5-turbo
```

**Important:** Never commit your `.env` file to version control!

### 4. Verify Setup

Check that everything is configured correctly:

```bash
flutter doctor
```

All checkmarks should be green (or at least the platform you want to run on).

### 5. Run the App

Choose your platform:

#### Android
```bash
flutter run
```

#### iOS (Mac only)
```bash
flutter run
```

#### Web
```bash
flutter run -d chrome
```

#### Specific Device
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## First Use

### Creating Your First Study Kit

1. **Launch the app** - You'll see the splash screen, then the home screen
2. **Tap the "+" button** or "Import" card
3. **Choose your import method**:
   - 📄 PDF: Select a PDF document
   - 🖼️ Image: Take a photo or select from gallery
   - 📝 Text: Paste text directly
4. **Enter a title** for your study kit
5. **Tap "Generate Flashcards & Quizzes"**
6. **Wait for processing** (usually 10-30 seconds)
7. **Done!** Your study kit is ready

### Studying with Flashcards

1. **Select a study kit** from the home screen
2. **Tap "Study"** in the flashcards section
3. **Read the question** on the front of the card
4. **Tap "Show Answer"** to reveal the back
5. **Rate your recall**:
   - **Again**: Review again tomorrow
   - **Hard**: Review in 1 day
   - **Good**: Review in 6 days (or based on SRS)
   - **Easy**: Review later (longer interval)

The app uses spaced repetition to optimize your learning!

### Taking Quizzes

1. **Select a study kit**
2. **Tap "Take Quiz"**
3. **Select an answer** for each question
4. **Get instant feedback** (correct/incorrect)
5. **View your results** at the end

### Tracking Progress

Navigate to the **Progress** tab to see:
- 📊 Overall mastery percentage
- 📈 Learning statistics
- 📅 Due cards for today
- 🎯 Quiz accuracy

## Tips for Best Results

### Import Quality
- ✅ Use clear, well-formatted text
- ✅ Break large documents into smaller sections
- ✅ Ensure images are readable
- ✅ Use descriptive titles for study kits

### Studying Effectively
- 📅 Study daily for best results
- 🎯 Focus on due cards first
- 💡 Use honest ratings (don't always pick "Easy")
- 📊 Review your progress regularly
- 🔄 Retake quizzes to reinforce learning

### API Usage
- 💰 Each study kit import costs ~$0.02-$0.05
- 💾 All content is cached locally after generation
- 🔌 Study offline after importing
- 📉 No additional costs for reviewing

## Common Issues & Solutions

### "OpenAI API key not configured"
**Solution:** Make sure your `.env` file exists and contains a valid API key.

### "Failed to load flashcards"
**Solution:** Clear app data or reinstall. The database may be corrupted.

### Import takes too long
**Solution:** Break large documents into smaller chunks. Try using text paste instead of PDF for faster processing.

### PDF import not working
**Solution:** Some PDFs may be image-based. Try using an OCR tool first, or paste the text directly.

### App crashes on Android
**Solution:** Check permissions in Settings > Apps > StudyAI. Enable Storage and Camera permissions.

## Keyboard Shortcuts (Web)

When running on web, use these shortcuts:
- `Space` - Show/hide answer in flashcard viewer
- `1-4` - Rate flashcard (1=Again, 4=Easy)
- `Enter` - Submit quiz answer
- `Esc` - Go back

## Next Steps

### Explore Features
- ✨ Try different import methods
- 📚 Create multiple study kits
- 🎯 Challenge yourself with quizzes
- 📊 Track your progress over time

### Customize
- 🎨 Adjust colors in `lib/main.dart`
- 🤖 Modify AI prompts in `lib/services/openai_service.dart`
- ⚙️ Tune SRS algorithm in `lib/services/srs_service.dart`

### Contribute
- 🐛 Report bugs on GitHub
- 💡 Suggest features
- 🔧 Submit pull requests
- 📖 Improve documentation

## Getting Help

- 📖 Check the [full README](README.md)
- 🐛 [Report issues](https://github.com/6NineLives/FlutterStudy/issues)
- 💬 [Discussions](https://github.com/6NineLives/FlutterStudy/discussions)
- 📧 Contact the maintainer

## Updates

To update StudyAI to the latest version:

```bash
git pull origin main
flutter pub get
flutter run
```

## Uninstalling

To remove StudyAI:

```bash
# Clear app data
flutter clean

# Remove the app from your device
# (Use device settings or adb uninstall)

# Delete the repository folder
cd ..
rm -rf FlutterStudy
```

---

**Happy Studying! 📚✨**

May your learning be efficient and your retention be strong!
