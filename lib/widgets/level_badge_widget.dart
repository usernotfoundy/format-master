// ============================================
// FILE: lib/widgets/level_badge_widget.dart
// ============================================
import 'package:flutter/material.dart';

class LevelBadgeWidget extends StatelessWidget {
  final int level;
  final int xp;

  const LevelBadgeWidget({
    Key? key,
    required this.level,
    required this.xp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLevelXP = (level - 1) * 100;
    final xpInCurrentLevel = xp - currentLevelXP;
    final xpForNextLevel = 100;
    final progress = xpInCurrentLevel / xpForNextLevel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade700, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Level $level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xpInCurrentLevel/$xpForNextLevel XP',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
