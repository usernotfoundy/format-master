// ============================================
// FILE: lib/screens/welcome_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'character_selection_screen.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkExistingUsers();
  }

  Future<void> _checkExistingUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final users = await userProvider.getAllUsers();

    if (users.isNotEmpty && mounted) {
      // Auto-load last user
      await userProvider.loadUser(users.first.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.text_fields,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'FormatMaster',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn. Practice. Master.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.isLoggedIn) {
                      return Column(
                        children: [
                          Text(
                            'Welcome back, ${userProvider.currentUser!.username}!',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 20,
                              ),
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            child: const Text('Continue Learning'),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              userProvider.logout();
                            },
                            child: const Text(
                              'Switch User',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }

                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CharacterSelectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Start Learning'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
