import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_widgets.dart';
import 'ticket_comment_page.dart';

class TicketDetailPage extends StatelessWidget {
  final TicketModel ticket;
  final String role;

  const TicketDetailPage({
    super.key,
    required this.ticket,
    required this.role,
  });

  void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _confirmAction(BuildContext context, String title, String message, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, TicketProvider provider, TicketModel ticket) {
    String selectedHelpdesk = 'Helpdesk 1';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign Helpdesk'),
          content: DropdownButton<String>(
            value: selectedHelpdesk,
            isExpanded: true,
            items: ['Helpdesk 1', 'Helpdesk 2', 'Helpdesk 3']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => selectedHelpdesk = val!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.assignHelpdesk(ticket.id!, selectedHelpdesk);
                Navigator.pop(context);
                showMessage(context, 'Berhasil menugaskan $selectedHelpdesk');
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    TicketModel currentTicket = ticket;
    try {
      if (provider.tickets.isNotEmpty) {
        currentTicket = provider.tickets.firstWhere(
          (t) => t.id == ticket.id,
          orElse: () => ticket,
        );
      }
    } catch (_) {
      currentTicket = ticket;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#TKT-${currentTicket.id ?? '0000'}',
                            style: theme.textTheme.titleMedium,
                          ),
                          StatusBadge(status: currentTicket.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentTicket.title,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Helpdesk: ${currentTicket.assignedHelpdesk ?? "Belum ditugaskan"}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentTicket.desc,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      if (currentTicket.imagePath != null && currentTicket.imagePath!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lampiran', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(currentTicket.imagePath!),
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentTicket.imagePath!.contains('/') 
                                  ? currentTicket.imagePath!.split('/').last 
                                  : 'file_lampiran',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      
                      if (role == 'admin' && currentTicket.status == 'OPEN') ...[
                        Text('Tindakan Admin', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showAssignDialog(context, provider, currentTicket),
                            child: const Text('Assign Helpdesk'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else if (role == 'helpdesk' && currentTicket.status == 'IN_PROGRESS') ...[
                        Text('Tindakan Helpdesk', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            onPressed: () {
                              _confirmAction(
                                context, 
                                'Konfirmasi', 
                                'Apakah Anda yakin ingin menyelesaikan tiket ini?', 
                                () async {
                                  await provider.finishTicket(currentTicket.id!);
                                  if (context.mounted) showMessage(context, 'Tiket diselesaikan');
                                }
                              );
                            },
                            child: const Text('Finish Ticket'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Text('Riwayat', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      HistoryList(history: currentTicket.history),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketCommentPage(
                        ticket: currentTicket,
                        role: role,
                      ),
                    ),
                  );
                },
                child: Text('Lihat Komentar (${currentTicket.comments.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
