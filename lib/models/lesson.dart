// ============================================
// FILE: lib/models/lesson.dart
// ============================================
class Lesson {
  final int id;
  final String title;
  final String category;
  final String description;
  final List<String> content;
  final int xpReward;
  final int order;

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    this.xpReward = 10,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'content': content.join('|||'),
      'xpReward': xpReward,
      'orderNum': order,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      description: map['description'],
      content: (map['content'] as String).split('|||'),
      xpReward: map['xpReward'],
      order: map['order'] ?? map['orderNum'],
    );
  }
}
