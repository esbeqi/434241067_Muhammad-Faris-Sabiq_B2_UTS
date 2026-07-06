import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';

/// TICKET CARD
class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ambil pesan terakhir secara aman tanpa .last langsung
    String? lastComment;
    if (ticket.comments.isNotEmpty) {
      try {
        lastComment = ticket.comments[ticket.comments.length - 1]["message"];
      } catch (_) {
        lastComment = null;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.confirmation_number,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Helpdesk: ${ticket.assignedHelpdesk ?? "Belum ditugaskan"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  if (lastComment != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      lastComment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // STATUS
            StatusBadge(status: ticket.status),
          ],
        ),
      ),
    );
  }
}

/// STATUS BADGE
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'CLOSE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// COMMENT LIST
class CommentList extends StatelessWidget {
  final List<Map<String, String>> comments;

  const CommentList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (comments.isEmpty) {
      return Text(
        'Belum ada komentar',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments.map((c) {
        final author = c["author"] ?? "-";
        final role = c["role"] ?? "-";
        final message = c["message"] ?? "";

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$author ($role)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// TRACKING TIMELINE (Update Sprint 3B)
class HistoryList extends StatelessWidget {
  final List<String> history;

  const HistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Belum ada aktivitas.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(history.length, (index) {
        final activity = history[index];
        final isLast = index == history.length - 1;
        
        final config = _getTimelineConfig(activity);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIMELINE LINE & ICON
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.icon,
                      size: 16,
                      color: config.color,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Text(
                    activity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  _TimelineConfig _getTimelineConfig(String activity) {
    // Prioritaskan status Close/Selesai
    if (activity.contains("Close") || activity.contains("Selesai")) {
      return _TimelineConfig(Icons.check_circle, Colors.green);
    } else if (activity.contains("Tiket dibuat")) {
      return _TimelineConfig(Icons.add_circle, Colors.green);
    } else if (activity.contains("Assigned")) {
      return _TimelineConfig(Icons.assignment_ind, Colors.blue);
    } else if (activity.contains("komentar")) {
      return _TimelineConfig(Icons.chat_bubble, Colors.orange);
    } else if (activity.contains("Status")) {
      return _TimelineConfig(Icons.sync, Colors.purple);
    }
    return _TimelineConfig(Icons.circle, Colors.grey);
  }
}

class _TimelineConfig {
  final IconData icon;
  final Color color;
  _TimelineConfig(this.icon, this.color);
}

/// STATUS BUTTON
class StatusButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const StatusButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }
}
