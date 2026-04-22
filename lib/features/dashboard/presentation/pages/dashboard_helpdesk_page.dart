import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ticket/presentation/pages/ticket_list_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardHelpdeskPage extends StatelessWidget {
  const DashboardHelpdeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TicketProvider>(context);
    final theme = Theme.of(context);

    final total = provider.total;
    final diproses = provider.countByStatus('Diproses');
    final assigned = provider.countByStatus('Assigned');

    final activities = provider.getRecentActivities();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Dashboard Helpdesk'),
        actions: [
          // REFRESH
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadTickets,
          ),

          // PROFILE (BARU)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ProfilePage(role: 'helpdesk'),
                ),
              );
            },
          ),

          // LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Helpdesk Panel',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 20),

            // CARD GRID
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
              ],
            ),

            const SizedBox(height: 30),

            // BUTTON
            DashboardButton(
              text: 'Assign Tiket',
              icon: Icons.assignment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const TicketListPage(role: 'helpdesk'),
                  ),
                ).then((_) {
                  provider.loadTickets();
                });
              },
            ),

            const SizedBox(height: 30),

            // AKTIVITAS TERBARU
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