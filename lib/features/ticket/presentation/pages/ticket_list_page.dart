import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_widgets.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';

class TicketListPage extends StatefulWidget {
  final String role;

  const TicketListPage({
    super.key,
    required this.role,
  });

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  String search = '';
  String selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TicketProvider>().loadTickets();
    });
  }

  Future<void> goToCreatePage() async {
    final provider = context.read<TicketProvider>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateTicketPage(),
      ),
    );

    if (!mounted) return;

    provider.loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('List Tiket (${widget.role})'),
      ),

      floatingActionButton: widget.role == 'user'
          ? FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: goToCreatePage,
        child: const Icon(Icons.add),
      )
          : null,

      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<TicketModel> tickets = provider.tickets;

          // SEARCH
          if (search.isNotEmpty) {
            tickets = tickets.where((t) {
              return t.title
                  .toLowerCase()
                  .contains(search.toLowerCase());
            }).toList();
          }

          // FILTER STATUS
          if (selectedStatus != 'Semua') {
            tickets = tickets
                .where((t) => t.status == selectedStatus)
                .toList();
          }

          // FILTER ROLE
          if (widget.role == 'helpdesk') {
            tickets = tickets
                .where((t) => t.status == 'Diproses')
                .toList();
          } else if (widget.role == 'admin') {
            tickets = tickets
                .where((t) => t.status != 'Diproses')
                .toList();
          }

          if (tickets.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada tiket',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return Column(
            children: [
              // SEARCH + FILTER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari tiket...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() => search = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        'Semua',
                        'Diproses',
                        'Assigned',
                        'Selesai'
                      ]
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedStatus = value);
                      },
                      decoration: const InputDecoration(),
                    ),
                  ],
                ),
              ),

              // LIST
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];

                    return TicketCard(
                      ticket: ticket,
                      onTap: () async {
                        final provider =
                        context.read<TicketProvider>();

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketDetailPage(
                              ticket: ticket,
                              role: widget.role,
                            ),
                          ),
                        );

                        if (!mounted) return;

                        provider.loadTickets();
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}