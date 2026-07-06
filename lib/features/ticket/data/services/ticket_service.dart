import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final _supabase = Supabase.instance.client;

  Future<List<TicketModel>> fetchTickets() async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .order('created_at', ascending: false);

      final List<TicketModel> tickets = (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();

      for (var ticket in tickets) {
        if (ticket.id != null) {
          ticket.comments = await fetchComments(ticket.id!);
          ticket.history = await fetchHistories(ticket.id!);
        }
      }
      return tickets;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchComments(String ticketId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);
      
      return (response as List).map((item) => {
        "message": item['message']?.toString() ?? '',
        "author": item['author']?.toString() ?? '',
        "role": item['role']?.toString() ?? '',
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Khusus untuk Timeline Detail Ticket: Tetap ASC (Kronologis)
  Future<List<String>> fetchHistories(String ticketId) async {
    try {
      final response = await _supabase
          .from('histories')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);
      
      return (response as List).map((item) => item['activity']?.toString() ?? '').toList();
    } catch (e) {
      return [];
    }
  }

  // Baru: Untuk Dashboard & Notification: Global DESC (Terbaru di atas)
  Future<List<String>> fetchGlobalHistories() async {
    try {
      final response = await _supabase
          .from('histories')
          .select('activity')
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => item['activity']?.toString() ?? '').toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createTicket(TicketModel ticket) async {
    try {
      final response = await _supabase.from('tickets').insert({
        'title': ticket.title,
        'description': ticket.desc,
        'status': 'OPEN',
        'image_url': ticket.imagePath,
      }).select();

      if (response != null && response.isNotEmpty) {
        final String? newId = response[0]['id']?.toString();
        if (newId != null) {
          await addHistory(newId, '[${ticket.title}] Tiket dibuat (Status: OPEN)');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> assignHelpdesk(String ticketId, String helpdeskName) async {
    try {
      await _supabase.from('tickets').update({
        'assigned_helpdesk': helpdeskName,
        'status': 'IN_PROGRESS',
      }).eq('id', ticketId);
      
      await addHistory(ticketId, 'Helpdesk $helpdeskName ditugaskan (Status: IN_PROGRESS)');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> finishTicket(String ticketId) async {
    try {
      await _supabase.from('tickets').update({
        'status': 'CLOSE',
      }).eq('id', ticketId);
      
      await addHistory(ticketId, 'Tiket telah diselesaikan (Status: CLOSE)');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTicketStatus(TicketModel ticket, String status) async {
    try {
      await _supabase.from('tickets').update({'status': status}).eq('id', ticket.id!);
      await addHistory(ticket.id!, 'Status diubah ke $status');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(TicketModel ticket, String comment, {String author = 'User Demo', String role = 'user'}) async {
    try {
      await _supabase.from('comments').insert({
        'ticket_id': ticket.id,
        'author': author,
        'role': role,
        'message': comment,
      });
      await addHistory(ticket.id!, '$author menambahkan komentar');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addHistory(String ticketId, String activity) async {
    try {
      await _supabase.from('histories').insert({
        'ticket_id': ticketId,
        'activity': activity,
      });
    } catch (e) {
      // ignore
    }
  }
}
