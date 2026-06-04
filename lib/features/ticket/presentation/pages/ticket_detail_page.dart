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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    // Ambil data tiket terbaru dari provider berdasarkan ID secara aman
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              currentTicket.imagePath!.split('/').isNotEmpty 
                                  ? currentTicket.imagePath!.split('/').last 
                                  : 'file_lampiran',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      if (role != 'user') ...[
                        Text('Update Status', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusButton(
                              text: 'Diproses',
                              onTap: () async {
                                await provider.updateStatus(currentTicket, 'Diproses');
                                showMessage(context, 'Status diubah ke Diproses');
                              },
                            ),
                            StatusButton(
                              text: 'Assigned',
                              onTap: () async {
                                await provider.updateStatus(currentTicket, 'Assigned');
                                showMessage(context, 'Status diubah ke Assigned');
                              },
                            ),
                            StatusButton(
                              text: 'Selesai',
                              onTap: () async {
                                await provider.updateStatus(currentTicket, 'Selesai');
                                showMessage(context, 'Status diubah ke Selesai');
                              },
                            ),
                          ],
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
