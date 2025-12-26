// ============================================
// FILE: lib/models/quiz.dart
// ============================================
class QuizQuestion {
  final int id;
  final int lessonId;
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'options': options.join('|||'),
      'correctAnswer': correctAnswer,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      lessonId: map['lessonId'],
      question: map['question'],
      options: (map['options'] as String).split('|||'),
      correctAnswer: map['correctAnswer'],
    );
  }
}
