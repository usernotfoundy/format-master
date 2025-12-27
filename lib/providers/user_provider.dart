// ============================================
// FILE: lib/providers/user_provider.dart
// ============================================
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _dbService;
  User? _currentUser;

  UserProvider(this._dbService);

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> createUser(String username, String avatarId) async {
    final user = User(username: username, avatarId: avatarId);
    final id = await _dbService.createUser(user);
    _currentUser = user.copyWith(id: id);
    notifyListeners();
  }

  Future<void> loadUser(int userId) async {
    _currentUser = await _dbService.getUser(userId);
    notifyListeners();
  }

  Future<List<User>> getAllUsers() async {
    return await _dbService.getAllUsers();
  }

  Future<void> addXP(int xp) async {
    if (_currentUser == null) return;

    final newXP = _currentUser!.xp + xp;
    final newLevel = _calculateLevel(newXP);

    _currentUser = _currentUser!.copyWith(xp: newXP, level: newLevel);
    await _dbService.updateUser(_currentUser!);
    notifyListeners();
  }

  int _calculateLevel(int xp) {
    // Level up every 100 XP
    return (xp ~/ 100) + 1;
  }

  int getXPForNextLevel() {
    if (_currentUser == null) return 100;
    return _currentUser!.level * 100;
  }

  double getProgressToNextLevel() {
    if (_currentUser == null) return 0.0;
    final currentLevelXP = (_currentUser!.level - 1) * 100;
    final xpInCurrentLevel = _currentUser!.xp - currentLevelXP;
    return xpInCurrentLevel / 100;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Reset user progress (XP and level back to default)
  Future<void> resetProgress() async {
    if (_currentUser == null) return;

    // Reset XP and level to defaults
    _currentUser = _currentUser!.copyWith(xp: 0, level: 1);
    await _dbService.updateUser(_currentUser!);
    
    // Reset all lesson progress
    await _dbService.resetUserProgress(_currentUser!.id!);
    
    notifyListeners();
  }

  // Delete a user profile
  Future<void> deleteUser(int userId) async {
    await _dbService.deleteUser(userId);
    
    // If the deleted user is the current user, log them out
    if (_currentUser?.id == userId) {
      _currentUser = null;
    }
    
    notifyListeners();
  }

  // Rename user profile
  Future<void> renameUser(int userId, String newUsername) async {
    final user = await _dbService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(username: newUsername);
      await _dbService.updateUser(updatedUser);
      
      // Update current user if it's the same
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }
      
      notifyListeners();
    }
  }
}
