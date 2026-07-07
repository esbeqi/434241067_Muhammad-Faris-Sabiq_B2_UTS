import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService service = TicketService();

  List<TicketModel> tickets = [];
  List<String> _globalHistory = [];
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
            debugPrint('Realtime: Ticket changed');
            _handleTicketChange(payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'comments',
          callback: (payload) {
            debugPrint('Realtime: Comment changed');
            _handleCommentChange(payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'histories',
          callback: (payload) {
            debugPrint('Realtime: New history added');
            _handleHistoryChange(payload);
          },
        )
        .subscribe();
  }

  Future<void> _handleTicketChange(PostgresChangePayload payload) async {
    final ticketId = payload.newRecord['id']?.toString() ?? payload.oldRecord['id']?.toString();
    if (ticketId != null) {
      await refreshTicket(ticketId);
    } else {
      await loadTickets();
    }
  }

  Future<void> _handleCommentChange(PostgresChangePayload payload) async {
    final ticketId = payload.newRecord['ticket_id']?.toString() ?? payload.oldRecord['ticket_id']?.toString();
    if (ticketId != null) {
      await refreshTicket(ticketId);
    }
  }

  Future<void> _handleHistoryChange(PostgresChangePayload payload) async {
    final ticketId = payload.newRecord['ticket_id']?.toString();
    if (ticketId != null) {
      await refreshTicket(ticketId);
    }

    _globalHistory = await service.fetchGlobalHistories();
    notifyListeners();
  }

  Future<void> loadTickets() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final newTickets = await service.fetchTickets();
      tickets = newTickets;
      _globalHistory = await service.fetchGlobalHistories();
    } catch (e) {
      debugPrint('Error loading tickets: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTicket(String ticketId) async {
    try {
      final updatedTicket = await service.fetchSingleTicket(ticketId);
      if (updatedTicket != null) {
        final index = tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          tickets[index] = updatedTicket;
          notifyListeners();
        } else {
          tickets.insert(0, updatedTicket);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing ticket: $e');
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

    final index = tickets.indexWhere((t) => t.id == ticketId);
    String? oldHelpdesk;
    String? oldStatus;
    
    if (index != -1) {
      oldHelpdesk = tickets[index].assignedHelpdesk;
      oldStatus = tickets[index].status;
      
      tickets[index].assignedHelpdesk = helpdeskName;
      tickets[index].status = 'IN_PROGRESS';
      notifyListeners();
    }

    try {
      await service.assignHelpdesk(ticketId, helpdeskName);
    } catch (e) {

      if (index != -1) {
        tickets[index].assignedHelpdesk = oldHelpdesk;
        tickets[index].status = oldStatus!;
        notifyListeners();
      }
      debugPrint('Error assigning helpdesk: $e');
    }
  }

  Future<void> finishTicket(String ticketId) async {

    final index = tickets.indexWhere((t) => t.id == ticketId);
    String? oldStatus;
    
    if (index != -1) {
      oldStatus = tickets[index].status;
      tickets[index].status = 'CLOSE';
      notifyListeners();
    }

    try {
      await service.finishTicket(ticketId);
    } catch (e) {

      if (index != -1) {
        tickets[index].status = oldStatus!;
        notifyListeners();
      }
      debugPrint('Error finishing ticket: $e');
    }
  }

  Future<void> updateStatus(TicketModel ticket, String status) async {

    final index = tickets.indexWhere((t) => t.id == ticket.id);
    String? oldStatus;
    
    if (index != -1) {
      oldStatus = tickets[index].status;
      tickets[index].status = status;
      notifyListeners();
    }

    try {
      await service.updateTicketStatus(ticket, status);
    } catch (e) {

      if (index != -1) {
        tickets[index].status = oldStatus!;
        notifyListeners();
      }
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> addComment(
    TicketModel ticket,
    String comment, {
    String author = 'User',
    String role = 'user',
  }) async {

    final index = tickets.indexWhere((t) => t.id == ticket.id);
    final tempComment = {
      "message": comment,
      "author": author,
      "role": role,
      "is_temp": "true",
    };

    if (index != -1) {
      tickets[index].comments.add(tempComment);
      notifyListeners();
    }

    try {
      await service.addComment(ticket, comment, author: author, role: role);
    } catch (e) {

      if (index != -1) {
        tickets[index].comments.removeWhere((c) => c["message"] == comment && c["is_temp"] == "true");
        notifyListeners();
      }
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

  List<String> getAllHistory() {
    return _globalHistory;
  }

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
