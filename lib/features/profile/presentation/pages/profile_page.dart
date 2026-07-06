import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required String role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: authProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // AVATAR DEFAULT
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // NAMA & EMAIL
                  Text(
                    authProvider.fullName ?? 'Memuat...',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '-',
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // ROLE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (authProvider.role ?? 'User').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // CARD SETTINGS (Style Card Dashboard)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        // NOTIFICATION SETTING
                        ListTile(
                          leading: Icon(Icons.notifications_active, color: theme.colorScheme.primary),
                          title: const Text('Notifikasi Tiket'),
                          subtitle: const Text('Dapatkan update status tiket'),
                          trailing: Switch(
                            value: authProvider.notificationEnabled,
                            onChanged: (val) {
                              authProvider.updateNotification(val);
                            },
                          ),
                        ),
                        
                        Divider(indent: 16, endIndent: 16, color: theme.dividerColor.withOpacity(0.1)),
                        
                        // DARK MODE SETTING
                        ListTile(
                          leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.orange),
                          title: const Text('Mode Gelap'),
                          subtitle: Text(isDark ? 'Tema Gelap Aktif' : 'Tema Terang Aktif'),
                          trailing: Switch(
                            value: isDark,
                            onChanged: (val) {
                              MyApp.toggleTheme(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar dari Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
