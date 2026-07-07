import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import 'package:flutter/foundation.dart';

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

      if (tickets.isEmpty) return [];

      final ticketIds = tickets.map((t) => t.id).whereType<String>().toList();

      // OPTIMASI: Ambil semua comments dan histories dalam satu batch (mengurangi N+1 query)
      final results = await Future.wait([
        _supabase.from('comments').select().inFilter('ticket_id', ticketIds).order('created_at', ascending: true),
        _supabase.from('histories').select().inFilter('ticket_id', ticketIds).order('created_at', ascending: true),
      ]);

      final allComments = results[0] as List;
      final allHistories = results[1] as List;

      for (var ticket in tickets) {
        ticket.comments = allComments
            .where((c) => c['ticket_id'].toString() == ticket.id)
            .map((item) => {
                  "message": item['message']?.toString() ?? '',
                  "author": item['author']?.toString() ?? '',
                  "role": item['role']?.toString() ?? '',
                })
            .toList();
        ticket.history = allHistories
            .where((h) => h['ticket_id'].toString() == ticket.id)
            .map((item) => item['activity']?.toString() ?? '')
            .toList();
      }
      return tickets;
    } catch (e) {
      debugPrint('Error fetchTickets: $e');
      return [];
    }
  }

  // Baru: Fetch satu tiket saja untuk efisiensi realtime
  Future<TicketModel?> fetchSingleTicket(String ticketId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .maybeSingle();

      if (response == null) return null;

      final ticket = TicketModel.fromJson(response);
      final results = await Future.wait([
        fetchComments(ticketId),
        fetchHistories(ticketId),
      ]);
      ticket.comments = results[0] as List<Map<String, String>>;
      ticket.history = results[1] as List<String>;
      return ticket;
    } catch (e) {
      return null;
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
