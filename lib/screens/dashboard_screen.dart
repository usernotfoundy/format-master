// ============================================
// FILE: lib/screens/dashboard_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/level_badge_widget.dart';
import '../widgets/lesson_card_widget.dart';
import 'lesson_screen.dart';
import 'exam_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    await progressProvider.loadLessons();
    if (userProvider.currentUser != null) {
      await progressProvider.loadUserProgress(userProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text('Text Formatting Master\n\n'
                      'Learn text formatting through interactive lessons, '
                      'quizzes, and practice exercises. Complete all lessons '
                      'to unlock the final exam!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, ProgressProvider>(
        builder: (context, userProvider, progressProvider, child) {
          final user = userProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.shade100,
                      ),
                      child: Center(
                        child: Text(
                          user.avatarId,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          LevelBadgeWidget(
                            level: user.level,
                            xp: user.xp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Progress Section
                ProgressBarWidget(
                  current: progressProvider.getCompletedLessonsCount(),
                  total: progressProvider.lessons.length,
                ),
                const SizedBox(height: 30),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Lessons',
                      '${progressProvider.getCompletedLessonsCount()}/${progressProvider.lessons.length}',
                      Icons.book,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'XP Earned',
                      '${user.xp}',
                      Icons.stars,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Level',
                      '${user.level}',
                      Icons.emoji_events,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Final Exam Button (if all lessons completed)
                if (progressProvider.areAllLessonsCompleted())
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.orange.shade400],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.emoji_events,
                            size: 50, color: Colors.white),
                        const SizedBox(height: 10),
                        const Text(
                          'Ready for Final Exam!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExamScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text('Take Exam'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                const Text(
                  'Lessons',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Lessons List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: progressProvider.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = progressProvider.lessons[index];
                    final isCompleted =
                        progressProvider.isLessonCompleted(lesson.id);

                    return LessonCardWidget(
                      lesson: lesson,
                      isCompleted: isCompleted,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonScreen(lesson: lesson),
                          ),
                        ).then((_) => _loadData());
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
