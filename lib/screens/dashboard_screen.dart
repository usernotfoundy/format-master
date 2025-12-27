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
import 'profile_selection_screen.dart';

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

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('Reset Progress'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reset all your progress?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('• Reset your XP to 0'),
            Text('• Reset your level to 1'),
            Text('• Clear all completed lessons'),
            Text('• Clear all quiz scores'),
            SizedBox(height: 15),
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    await userProvider.resetProgress();
    await progressProvider.loadUserProgress(userProvider.currentUser!.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress has been reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('📝', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Text('FormatMaster'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learn text formatting through interactive lessons, '
              'quizzes, and practice exercises. Complete all lessons '
              'to unlock the final exam!',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.code, size: 20, color: Colors.purple.shade400),
                const SizedBox(width: 8),
                const Text(
                  'Developer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.only(left: 28),
              child: Text(
                'Marc Stephen Angngasing',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Profile',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSelectionScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'reset') {
                _showResetConfirmation();
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Reset Progress'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('About'),
                  ],
                ),
              ),
            ],
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
