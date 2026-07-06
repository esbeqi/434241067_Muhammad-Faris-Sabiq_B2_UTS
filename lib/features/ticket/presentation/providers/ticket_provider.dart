import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService service = TicketService();

  List<TicketModel> tickets = [];
  List<String> _globalHistory = []; // Simpan history global di sini
  bool isLoading = false;
  RealtimeChannel? _realtimeChannel;

  TicketProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    final client = Supabase.instance.client;
    _realtimeChannel = client.channel('public-db-changes');

    _realtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tickets',
          callback: (payload) {
            debugPrint('Realtime: Tickets changed');
            loadTickets();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'histories',
          callback: (payload) {
            debugPrint('Realtime: New history added');
            loadTickets();
          },
        )
        .subscribe();
  }

  Future<void> loadTickets() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch tickets
      final newTickets = await service.fetchTickets();
      tickets = newTickets;

      // 2. Fetch global history (Latest first)
      _globalHistory = await service.fetchGlobalHistories();
      
    } catch (e) {
      debugPrint('Error loading tickets: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTicket(TicketModel ticket) async {
    try {
      await service.createTicket(ticket);
    } catch (e) {
      debugPrint('Error adding ticket: $e');
    }
  }

  Future<void> assignHelpdesk(String ticketId, String helpdeskName) async {
    try {
      await service.assignHelpdesk(ticketId, helpdeskName);
    } catch (e) {
      debugPrint('Error assigning helpdesk: $e');
    }
  }

  Future<void> finishTicket(String ticketId) async {
    try {
      await service.finishTicket(ticketId);
    } catch (e) {
      debugPrint('Error finishing ticket: $e');
    }
  }

  Future<void> updateStatus(TicketModel ticket, String status) async {
    try {
      await service.updateTicketStatus(ticket, status);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> addComment(
    TicketModel ticket,
    String comment, {
    String author = 'User',
    String role = 'user',
  }) async {
    try {
      await service.addComment(ticket, comment, author: author, role: role);
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  int get total => tickets.length;

  int countByStatus(String status) {
    if (tickets.isEmpty) return 0;
    return tickets.where((t) => t.status == status).length;
  }

  int get countAssigned {
    return tickets.where((t) => t.assignedHelpdesk != null).length;
  }

  // Memberikan history global (Terbaru -> Lama) untuk Dashboard & Notification
  List<String> getAllHistory() {
    return _globalHistory;
  }

  // Mengambil limit untuk dashboard
  List<String> getRecentActivities({int limit = 5}) {
    if (_globalHistory.isEmpty) return [];
    return _globalHistory.take(limit).toList();
  }

  @override
  void dispose() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }
}
