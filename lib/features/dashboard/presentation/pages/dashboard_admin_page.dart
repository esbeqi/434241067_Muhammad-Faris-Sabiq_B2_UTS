import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  Future<void> _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
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
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    if (ticketProvider.isLoading || authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = ticketProvider.total;
    final open = ticketProvider.countByStatus('OPEN');
    final assigned = ticketProvider.countAssigned;
    final inProgress = ticketProvider.countByStatus('IN_PROGRESS');
    final close = ticketProvider.countByStatus('CLOSE');

    final activities = ticketProvider.getRecentActivities();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ticketProvider.loadTickets,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage(role: 'admin')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halo,', style: TextStyle(fontSize: 16)),
                Text(
                  authProvider.fullName ?? 'Admin',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  (authProvider.role ?? 'Admin').toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(title: 'Total', value: total.toString(), icon: Icons.list),
                DashboardCard(title: 'Open', value: open.toString(), icon: Icons.lock_open),
                DashboardCard(title: 'Assigned', value: assigned.toString(), icon: Icons.assignment_ind),
                DashboardCard(title: 'In Progress', value: inProgress.toString(), icon: Icons.sync),
                DashboardCard(title: 'Close', value: close.toString(), icon: Icons.lock),
              ],
            ),
            const SizedBox(height: 30),
            DashboardButton(
              text: 'Kelola Tiket',
              icon: Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketListPage(role: 'admin')),
                ).then((_) {
                  ticketProvider.loadTickets();
                });
              },
            ),
            const SizedBox(height: 30),
            Text('Aktivitas Terbaru', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            if (activities.isEmpty)
              Text('Belum ada aktivitas', style: theme.textTheme.bodyMedium)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activities.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $e', style: theme.textTheme.bodyMedium),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
