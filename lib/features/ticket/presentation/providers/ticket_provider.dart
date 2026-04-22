import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService service = TicketService();

  List<TicketModel> tickets = [];
  bool isLoading = false;

  // LOAD DATA
  Future<void> loadTickets() async {
    isLoading = true;
    notifyListeners();

    tickets = await service.fetchTickets();

    isLoading = false;
    notifyListeners();
  }

  // TAMBAH TIKET
  Future<void> addTicket(TicketModel ticket) async {
    await service.createTicket(ticket);
    await loadTickets();
  }

  //  UPDATE STATUS
  Future<void> updateStatus(
      TicketModel ticket, String status) async {
    await service.updateTicketStatus(ticket, status);
    notifyListeners();
  }

  // COMMENT
  Future<void> addComment(
      TicketModel ticket,
      String comment, {
        String author = 'User',
        String role = 'user',
      }) async {
    await service.addComment(
      ticket,
      comment,
      author: author,
      role: role,
    );

    notifyListeners();
  }

  // DASHBOARD
  int get total => tickets.length;

  int countByStatus(String status) {
    return tickets.where((t) => t.status == status).length;
  }

  // GLOBAL HISTORY (BONUS FITUR)
  List<String> getAllHistory() {
    List<String> allHistory = [];

    for (var t in tickets) {
      allHistory.addAll(t.history);
    }

    // urutkan terbaru di atas
    return allHistory.reversed.toList();
  }

  // AMBIL BEBERAPA AKTIVITAS TERBARU
  List<String> getRecentActivities({int limit = 5}) {
    final all = getAllHistory();
    return all.take(limit).toList();
  }
}