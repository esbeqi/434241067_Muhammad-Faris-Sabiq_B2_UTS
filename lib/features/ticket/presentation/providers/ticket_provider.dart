import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService service = TicketService();

  List<TicketModel> tickets = [];
  bool isLoading = false;

  Future<void> loadTickets() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final newTickets = await service.fetchTickets();
      tickets = newTickets;
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
      await loadTickets();
    } catch (e) {
      debugPrint('Error adding ticket: $e');
    }
  }

  Future<void> updateStatus(TicketModel ticket, String status) async {
    try {
      await service.updateTicketStatus(ticket, status);
      await loadTickets();
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
      await loadTickets();
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

  List<String> getAllHistory() {
    if (tickets.isEmpty) return [];
    
    final List<String> allHistory = [];
    for (final t in tickets) {
      if (t.history.isNotEmpty) {
        allHistory.addAll(t.history);
      }
    }

    if (allHistory.isEmpty) return [];
    // Menggunakan toList() sebelum reversed untuk keamanan ekstra
    return allHistory.toList().reversed.toList();
  }

  List<String> getRecentActivities({int limit = 5}) {
    final all = getAllHistory();
    if (all.isEmpty) return [];
    return all.take(limit).toList();
  }
}
