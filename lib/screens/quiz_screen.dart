// ============================================
// FILE: lib/screens/quiz_screen.dart
// ============================================
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  
  // Store shuffled options and correct answer index for each question
  List<List<String>> _shuffledOptions = [];
  List<int> _shuffledCorrectAnswers = [];
  
  // Confetti controller for celebration
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    await progressProvider.loadQuiz(widget.lesson.id);
    
    final questions = progressProvider.currentQuiz;
    
    // Shuffle options for each question
    final random = Random();
    for (var question in questions) {
      // Create a list of indices and shuffle them
      final indices = List.generate(question.options.length, (i) => i);
      indices.shuffle(random);
      
      // Create shuffled options list
      final shuffledOpts = indices.map((i) => question.options[i]).toList();
      _shuffledOptions.add(shuffledOpts);
      
      // Find where the correct answer ended up after shuffling
      final newCorrectIndex = indices.indexOf(question.correctAnswer);
      _shuffledCorrectAnswers.add(newCorrectIndex);
    }
    
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  void _answerQuestion(int answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _shuffledCorrectAnswers[_currentQuestion]) {
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

    // Start confetti celebration!
    _confettiController.play();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Stack(
          children: [
            // Confetti from top center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.purple,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                ],
                numberOfParticles: 30,
                gravity: 0.2,
                emissionFrequency: 0.05,
              ),
            ),
            // The dialog
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉 '),
                  const Text('Quiz Complete!'),
                  const Text(' 🎉'),
                ],
              ).animate().shimmer(duration: 1.seconds),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated trophy or icon
                  Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.lightbulb,
                    size: 80,
                    color: percentage >= 70 ? Colors.amber : Colors.orange,
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shake(hz: 2, duration: 500.ms),
                  const SizedBox(height: 10),
                  // Party poppers
                  const Text(
                    '🎊 🎉 🥳 🎉 🎊',
                    style: TextStyle(fontSize: 30),
                  ).animate().fadeIn().scale(delay: 300.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Score: $_score/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 20,
                      color: percentage >= 70 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${widget.lesson.xpReward} XP',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .scale(delay: 600.ms)
                      .then()
                      .shimmer(duration: 1.seconds),
                  const SizedBox(height: 20),
                  Text(
                    percentage >= 70
                        ? '🌟 Great job! You passed! 🌟'
                        : '💪 Keep practicing! Try reviewing the lesson.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _confettiController.stop();
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 18),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms),
                ),
              ],
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

                  // Options (shuffled)
                  ...List.generate(_shuffledOptions[_currentQuestion].length, (index) {
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = index == _shuffledCorrectAnswers[_currentQuestion];

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
                            _shuffledOptions[_currentQuestion][index],
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
