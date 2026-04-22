import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';

class TicketCommentPage extends StatefulWidget {
  final TicketModel ticket;
  final String role;

  const TicketCommentPage({
    super.key,
    required this.ticket,
    required this.role,
  });

  @override
  State<TicketCommentPage> createState() =>
      _TicketCommentPageState();
}

class _TicketCommentPageState
    extends State<TicketCommentPage> {
  final TextEditingController controller =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  String getAuthor() {
    switch (widget.role) {
      case 'admin':
        return 'Admin';
      case 'helpdesk':
        return 'Helpdesk';
      default:
        return 'User';
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendComment() async {
    if (controller.text.isEmpty) return;

    final provider = context.read<TicketProvider>();

    await provider.addComment(
      widget.ticket,
      controller.text,
      author: getAuthor(),
      role: widget.role,
    );

    controller.clear();

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // WATCH PROVIDER (BIAR AUTO UPDATE)
    final provider = context.watch<TicketProvider>();

    // ambil ticket terbaru dari provider
    final ticket = provider.tickets.firstWhere(
          (t) => t == widget.ticket,
    );

    final comments = ticket.comments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar Tiket'),
      ),
      body: Column(
        children: [
          // LIST CHAT
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];

                final isMe =
                    c["role"] == widget.role;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                    const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints:
                    const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.colorScheme.primary
                          : theme.cardColor,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          c["author"] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c["message"] ?? '',
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar...',
                      ),
                      onSubmitted: (_) => sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendComment,
                    icon: Icon(
                      Icons.send,
                      color:
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}