// ============================================
// FILE: lib/screens/exam_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../providers/progress_provider.dart';
import '../providers/user_provider.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<QuizQuestion> _allQuestions = [];
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    // Load questions from all lessons
    for (var lesson in progressProvider.lessons) {
      await progressProvider.loadQuiz(lesson.id);
      _allQuestions.addAll(progressProvider.currentQuiz);
    }

    // Shuffle and limit to 20 questions
    _allQuestions.shuffle();
    _allQuestions = _allQuestions.take(20).toList();

    setState(() {
      _loading = false;
    });
  }

  void _answerQuestion(int answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _allQuestions[_currentQuestion].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _allQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _finishExam();
    }
  }

  Future<void> _finishExam() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final percentage = (_score / _allQuestions.length * 100).round();

    // Award bonus XP for completing exam
    if (percentage >= 80) {
      await userProvider.addXP(100); // Excellent!
    } else if (percentage >= 70) {
      await userProvider.addXP(50); // Good job!
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Exam Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                percentage >= 80
                    ? Icons.emoji_events
                    : percentage >= 70
                        ? Icons.thumb_up
                        : Icons.replay,
                size: 80,
                color: percentage >= 80
                    ? Colors.amber
                    : percentage >= 70
                        ? Colors.green
                        : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                'Final Score',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              Text(
                '$_score/${_allQuestions.length}',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              if (percentage >= 80)
                const Text(
                  '🎉 Outstanding! You\'re a Text Formatting Master!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              else if (percentage >= 70)
                const Text(
                  'Good job! Keep practicing to master all skills.',
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  'Review the lessons and try again!',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            if (percentage < 70)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentQuestion = 0;
                    _score = 0;
                    _selectedAnswer = null;
                    _answered = false;
                    _allQuestions.shuffle();
                  });
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _allQuestions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Exam'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.amber.shade100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1}/${_allQuestions.length}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / _allQuestions.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...List.generate(question.options.length, (index) {
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = index == question.correctAnswer;

                    Color? buttonColor;
                    if (_answered) {
                      if (isCorrect) {
                        buttonColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        buttonColor = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _answered ? null : () => _answerQuestion(index),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            backgroundColor: buttonColor ?? Colors.white,
                            foregroundColor: buttonColor != null
                                ? Colors.white
                                : Colors.black,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            question.options[index],
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.amber,
                  ),
                  child: Text(
                    _currentQuestion < _allQuestions.length - 1
                        ? 'Next Question'
                        : 'Finish Exam',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
