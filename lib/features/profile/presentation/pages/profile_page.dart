import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../main.dart';

class ProfilePage extends StatelessWidget {
  final String role;

  const ProfilePage({
    super.key,
    required this.role,
  });

  String getName() {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'helpdesk':
        return 'Helpdesk';
      default:
        return 'User';
    }
  }

  String getEmail() {
    switch (role) {
      case 'admin':
        return 'admin@email.com';
      case 'helpdesk':
        return 'helpdesk@email.com';
      default:
        return 'user@email.com';
    }
  }

  String getPhone() {
    switch (role) {
      case 'admin':
        return '081111111111';
      case 'helpdesk':
        return '082222222222';
      default:
        return '083333333333';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Nama
            Text(
              getName(),
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 6),

            // Role
            Text(
              role.toUpperCase(),
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Email: ${getEmail()}\nNo HP: ${getPhone()}',
                style: theme.textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 20),

            // Toggle Theme
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  MyApp.toggleTheme(context);
                },
                icon: const Icon(Icons.dark_mode),
                label: const Text('Toggle Dark / Light'),
              ),
            ),

            const Spacer(),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}