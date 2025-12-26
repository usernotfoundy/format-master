// ============================================
// FILE: lib/models/user.dart
// ============================================
class User {
  final int? id;
  final String username;
  final String avatarId;
  final int level;
  final int xp;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.avatarId,
    this.level = 1,
    this.xp = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatarId': avatarId,
      'level': level,
      'xp': xp,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      avatarId: map['avatarId'],
      level: map['level'],
      xp: map['xp'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? avatarId,
    int? level,
    int? xp,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      createdAt: createdAt,
    );
  }
}
