// ============================================
// FILE: lib/models/progress.dart
// ============================================
class Progress {
  final int? id;
  final int userId;
  final int lessonId;
  final bool completed;
  final int? quizScore;
  final DateTime? completedAt;

  Progress({
    this.id,
    required this.userId,
    required this.lessonId,
    this.completed = false,
    this.quizScore,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'completed': completed ? 1 : 0,
      'quizScore': quizScore,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      userId: map['userId'],
      lessonId: map['lessonId'],
      completed: map['completed'] == 1,
      quizScore: map['quizScore'],
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}
