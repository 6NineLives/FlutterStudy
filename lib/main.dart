import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/import_screen.dart';
import 'screens/kit_detail_screen.dart';
import 'screens/study_session_screen.dart';
import 'screens/flashcard_viewer.dart';
import 'screens/quiz_viewer.dart';
import 'screens/progress_screen.dart';

/// Main entry point for the StudyAI application
/// Initializes environment variables, database, and providers
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (handle missing .env gracefully)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Using default configuration.');
    print('Please create a .env file with your OpenAI API key.');
  }
  
  runApp(
    const ProviderScope(
      child: StudyAIApp(),
    ),
  );
}

/// Root widget for StudyAI application
class StudyAIApp extends StatelessWidget {
  const StudyAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/import': (context) => const ImportScreen(),
        '/study_session': (context) => const StudySessionScreen(),
        '/progress': (context) => const ProgressScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/kit_detail') {
          final kitId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => KitDetailScreen(kitId: kitId),
          );
        }
        if (settings.name == '/flashcard_viewer') {
          final kitId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => FlashcardViewer(kitId: kitId),
          );
        }
        if (settings.name == '/quiz_viewer') {
          final kitId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => QuizViewer(kitId: kitId),
          );
        }
        return null;
      },
    );
  }
}
