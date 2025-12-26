// ============================================
// FILE: lib/providers/progress_provider.dart
// ============================================
import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../models/quiz.dart';
import '../services/database_service.dart';

class ProgressProvider with ChangeNotifier {
  final DatabaseService _dbService;
  List<Lesson> _lessons = [];
  List<Progress> _userProgress = [];
  List<QuizQuestion> _currentQuiz = [];

  ProgressProvider(this._dbService);

  List<Lesson> get lessons => _lessons;
  List<Progress> get userProgress => _userProgress;
  List<QuizQuestion> get currentQuiz => _currentQuiz;

  Future<void> loadLessons() async {
    _lessons = await _dbService.getAllLessons();
    notifyListeners();
  }

  Future<void> loadUserProgress(int userId) async {
    _userProgress = await _dbService.getUserProgress(userId);
    notifyListeners();
  }

  Future<void> loadQuiz(int lessonId) async {
    _currentQuiz = await _dbService.getQuizQuestions(lessonId);
    notifyListeners();
  }

  bool isLessonCompleted(int lessonId) {
    return _userProgress.any((p) => p.lessonId == lessonId && p.completed);
  }

  int? getLessonQuizScore(int lessonId) {
    final progress = _userProgress.firstWhere(
      (p) => p.lessonId == lessonId,
      orElse: () => Progress(userId: 0, lessonId: lessonId),
    );
    return progress.quizScore;
  }

  Future<void> completeLesson(int userId, int lessonId, int quizScore) async {
    final progress = Progress(
      userId: userId,
      lessonId: lessonId,
      completed: true,
      quizScore: quizScore,
      completedAt: DateTime.now(),
    );

    await _dbService.saveProgress(progress);
    await loadUserProgress(userId);
    notifyListeners();
  }

  int getCompletedLessonsCount() {
    return _userProgress.where((p) => p.completed).length;
  }

  double getOverallProgress() {
    if (_lessons.isEmpty) return 0.0;
    return getCompletedLessonsCount() / _lessons.length;
  }

  int getTotalXPEarned() {
    int totalXP = 0;
    for (var progress in _userProgress) {
      if (progress.completed) {
        final lesson = _lessons.firstWhere(
          (l) => l.id == progress.lessonId,
          orElse: () => Lesson(
            id: 0,
            title: '',
            category: '',
            description: '',
            content: [],
            order: 0,
          ),
        );
        totalXP += lesson.xpReward;
      }
    }
    return totalXP;
  }

  Lesson? getNextLesson() {
    for (var lesson in _lessons) {
      if (!isLessonCompleted(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }

  bool areAllLessonsCompleted() {
    return getCompletedLessonsCount() == _lessons.length;
  }
}
