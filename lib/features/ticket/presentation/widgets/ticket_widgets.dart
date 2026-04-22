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
                  const SizedBox(height: 4),
                  Text(
                    ticket.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),

                  // COMMENT PREVIEW
                  if (ticket.comments.isNotEmpty &&
                      ticket.comments.last["message"] != null)
                    Text(
                      ticket.comments.last["message"]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
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
    final color = _getColor(context, status);

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

  Color _getColor(BuildContext context, String status) {
    final theme = Theme.of(context);

    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Assigned':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
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

/// HISTORY LIST
class HistoryList extends StatelessWidget {
  final List<String> history;

  const HistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: history
          .map(
            (h) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '• $h',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      )
          .toList(),
    );
  }
}

/// STATUS BUTTON
class StatusButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const StatusButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }
}