# Changelog

All notable changes to the StudyAI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-14

### Added
- Initial release of StudyAI
- OpenAI integration for content generation
  - Text summarization
  - Flashcard generation
  - Quiz creation
- Local SQLite database for offline storage
- Spaced Repetition System (SRS) with SM-2 algorithm
- Study material import
  - PDF file support
  - Image file support
  - Text file support
  - Direct text paste
- Interactive flashcard viewer
  - Front/back card display
  - SRS rating system (Again, Hard, Good, Easy)
  - Progress tracking
  - Mastery levels
- Quiz system
  - Multiple-choice questions
  - Instant feedback
  - Score tracking
  - Result analytics
- Progress dashboard
  - Overall mastery percentage
  - Card statistics (new, learning, mastered)
  - Due cards tracking
  - Quiz accuracy metrics
- Home screen with study kit management
- Modern pastel UI theme
- Comprehensive error handling
- API retry logic
- Offline caching

### Features
- 📚 Study kit creation and management
- 🤖 AI-powered content generation
- 📝 Flashcard creation and review
- 🎯 Quiz generation and testing
- 📊 Progress tracking and statistics
- 🔄 Spaced repetition scheduling
- 💾 Offline support
- 🎨 Clean, modern UI

### Technical
- Flutter 3.0+ support
- Riverpod state management
- SQLite local storage
- OpenAI API integration
- Material Design 3
- Comprehensive documentation
- Example .env configuration
- Android and iOS platform support

### Documentation
- Detailed README with setup instructions
- API documentation
- Code comments throughout
- Contributing guidelines
- MIT License

## Future Enhancements (Planned)

### [1.1.0] - Planned
- [ ] OCR support for image text extraction
- [ ] Voice recording for study notes
- [ ] Dark mode theme
- [ ] Cloud sync functionality
- [ ] Study groups and sharing
- [ ] Custom flashcard templates
- [ ] Export/import study kits
- [ ] Study statistics graphs
- [ ] Gamification elements
- [ ] Multiple language support

### [1.2.0] - Planned
- [ ] Web platform support
- [ ] Desktop platform support
- [ ] Advanced quiz types (fill-in-blank, matching)
- [ ] Study reminders and notifications
- [ ] Calendar integration
- [ ] Performance analytics
- [ ] Custom SRS algorithm parameters
- [ ] Batch processing for multiple files

---

For more details, see the [GitHub releases](https://github.com/6NineLives/FlutterStudy/releases).
