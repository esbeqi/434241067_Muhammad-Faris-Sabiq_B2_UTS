import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TicketProvider>();
    final notifications = provider.getAllHistory();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('Belum ada notifikasi.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = notifications[index];
                final iconConfig = _getIconConfig(activity);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconConfig.color.withOpacity(0.1),
                    child: Icon(iconConfig.icon, color: iconConfig.color, size: 20),
                  ),
                  title: Text(
                    activity,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Baru saja'), // Karena data history hanya String
                );
              },
            ),
    );
  }

  _IconConfig _getIconConfig(String activity) {
    if (activity.contains("Tiket dibuat")) {
      return _IconConfig(Icons.add_circle, Colors.green);
    } else if (activity.contains("Assigned")) {
      return _IconConfig(Icons.assignment_ind, Colors.blue);
    } else if (activity.contains("komentar")) {
      return _IconConfig(Icons.chat_bubble, Colors.orange);
    } else if (activity.contains("Status")) {
      return _IconConfig(Icons.sync, Colors.purple);
    } else if (activity.contains("Close") || activity.contains("Selesai")) {
      return _IconConfig(Icons.check_circle, Colors.green);
    }
    return _IconConfig(Icons.circle, Colors.grey);
  }
}

class _IconConfig {
  final IconData icon;
  final Color color;
  _IconConfig(this.icon, this.color);
}
