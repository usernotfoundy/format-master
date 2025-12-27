// ============================================
// FILE: lib/screens/quiz_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../providers/user_provider.dart';
import '../providers/progress_provider.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    await progressProvider.loadQuiz(widget.lesson.id);
    setState(() {
      _questions = progressProvider.currentQuiz;
      _loading = false;
    });
  }

  void _answerQuestion(int answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _questions[_currentQuestion].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    final percentage = (_score / _questions.length * 100).round();

    // Save progress
    await progressProvider.completeLesson(
      userProvider.currentUser!.id!,
      widget.lesson.id,
      percentage,
    );

    // Award XP
    await userProvider.addXP(widget.lesson.xpReward);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.lightbulb,
                size: 80,
                color: percentage >= 70 ? Colors.amber : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $_score/${_questions.length}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('$percentage%'),
              const SizedBox(height: 10),
              Text(
                '+${widget.lesson.xpReward} XP',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                percentage >= 70
                    ? 'Great job! You passed!'
                    : 'Keep practicing! Try reviewing the lesson.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to dashboard
              },
              child: const Text('Continue'),
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

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No quiz questions available.'),
        ),
      );
    }

    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.lesson.title}'),
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1}/${_questions.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.purple),
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
                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Options
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
                                  ? Colors.purple
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

          // Next button
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    _currentQuestion < _questions.length - 1
                        ? 'Next Question'
                        : 'Finish Quiz',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
