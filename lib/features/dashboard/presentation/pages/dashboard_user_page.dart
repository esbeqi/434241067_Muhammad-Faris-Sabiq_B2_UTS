import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../../ticket/presentation/pages/create_ticket_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TicketProvider>(context);
    final theme = Theme.of(context);

    final total = provider.total;
    final diproses = provider.countByStatus('Diproses');
    final assigned = provider.countByStatus('Assigned');
    final selesai = provider.countByStatus('Selesai');

    final activities = provider.getRecentActivities();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Dashboard User'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.primary,
            ),
            onPressed: provider.loadTickets,
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(role: 'user'),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: theme.colorScheme.primary,
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
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, User',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  title: 'Total',
                  value: total.toString(),
                  icon: Icons.list,
                ),
                DashboardCard(
                  title: 'Diproses',
                  value: diproses.toString(),
                  icon: Icons.timelapse,
                ),
                DashboardCard(
                  title: 'Assigned',
                  value: assigned.toString(),
                  icon: Icons.assignment,
                ),
                DashboardCard(
                  title: 'Selesai',
                  value: selesai.toString(),
                  icon: Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 30),

            DashboardButton(
              text: 'Lihat Tiket',
              icon: Icons.list,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const TicketListPage(role: 'user'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            DashboardButton(
              text: 'Buat Tiket',
              icon: Icons.add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CreateTicketPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Text(
              'Aktivitas Terbaru',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            if (activities.isEmpty)
              Text(
                'Belum ada aktivitas',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activities.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $e',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}