// ============================================
// FILE: lib/screens/lesson_screen.dart
// ============================================
import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(
                widget.lesson.content.length,
                (index) => Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? Colors.purple
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Lesson content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForLesson(),
                        size: 80,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        widget.lesson.content[_currentPage],
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Page ${_currentPage + 1} of ${widget.lesson.content.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < widget.lesson.content.length - 1) {
                        setState(() {
                          _currentPage++;
                        });
                      } else {
                        // Go to quiz
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizScreen(lesson: widget.lesson),
                          ),
                        );
                      }
                    },
                    child: Text(
                      _currentPage < widget.lesson.content.length - 1
                          ? 'Next'
                          : 'Take Quiz',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLesson() {
    final title = widget.lesson.title.toLowerCase();
    if (title.contains('bold')) return Icons.format_bold;
    if (title.contains('italic')) return Icons.format_italic;
    if (title.contains('underline')) return Icons.format_underline;
    if (title.contains('align')) return Icons.format_align_left;
    if (title.contains('spacing')) return Icons.format_line_spacing;
    if (title.contains('indent')) return Icons.format_indent_increase;
    if (title.contains('highlight')) return Icons.highlight;
    if (title.contains('super') || title.contains('sub')) {
      return Icons.superscript;
    }
    if (title.contains('strike')) return Icons.strikethrough_s;
    if (title.contains('caps')) return Icons.text_fields;
    return Icons.article;
  }
}
