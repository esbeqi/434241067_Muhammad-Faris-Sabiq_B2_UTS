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

  Future<void> createTicket(TicketModel ticket) async {
    try {
      final response = await _supabase.from('tickets').insert({
        'title': ticket.title,
        'description': ticket.desc,
        'status': ticket.status,
        'image_url': ticket.imagePath,
      }).select();

      if (response != null && response is List && response.isNotEmpty) {
        final String ticketId = response[0]['id'].toString();
        await addHistory(ticketId, '[${ticket.title}] Tiket dibuat');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTicketStatus(TicketModel ticket, String status) async {
    try {
      await _supabase.from('tickets').update({'status': status}).eq('id', ticket.id!);
      await addHistory(ticket.id!, '[${ticket.title}] Status diubah ke $status');
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
      await addHistory(ticket.id!, '[${ticket.title}] $author menambahkan komentar');
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
