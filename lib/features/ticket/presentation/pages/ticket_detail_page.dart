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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // MAIN CARD
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
                      // HEADER
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#TKT-0001',
                            style: theme.textTheme.titleMedium,
                          ),
                          StatusBadge(status: ticket.status),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TITLE
                      Text(
                        ticket.title,
                        style: theme.textTheme.titleLarge,
                      ),

                      const SizedBox(height: 8),

                      // DESC
                      Text(
                        ticket.desc,
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 16),

                      // IMAGE
                      if (ticket.imagePath != null &&
                          ticket.imagePath!.isNotEmpty)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lampiran',
                              style:
                              theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10),
                              child: Image.file(
                                File(ticket.imagePath!),
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ticket.imagePath!
                                  .split('/')
                                  .last,
                              style:
                              theme.textTheme.bodySmall,
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // STATUS ACTION
                      if (role != 'user') ...[
                        Text(
                          'Update Status',
                          style:
                          theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusButton(
                              text: 'Diproses',
                              onTap: () async {
                                await provider.updateStatus(
                                    ticket, 'Diproses');
                                showMessage(context,
                                    'Status diubah ke Diproses');
                              },
                            ),
                            StatusButton(
                              text: 'Assigned',
                              onTap: () async {
                                await provider.updateStatus(
                                    ticket, 'Assigned');
                                showMessage(context,
                                    'Status diubah ke Assigned');
                              },
                            ),
                            StatusButton(
                              text: 'Selesai',
                              onTap: () async {
                                await provider.updateStatus(
                                    ticket, 'Selesai');
                                showMessage(context,
                                    'Status diubah ke Selesai');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // HISTORY
                      Text(
                        'Riwayat',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      HistoryList(history: ticket.history),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BUTTON KE KOMENTAR
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketCommentPage(
                        ticket: ticket,
                        role: role,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Lihat Komentar (${ticket.comments.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}