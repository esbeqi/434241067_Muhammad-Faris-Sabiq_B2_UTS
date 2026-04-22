import '../models/ticket_model.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();

  factory TicketService() {
    return _instance;
  }

  TicketService._internal();

  // SHARED DATA
  final List<TicketModel> _tickets = [
    // DIPROSES
    TicketModel(
      title: 'Internet Kantor Lambat',
      desc: 'Koneksi wifi di lantai 2 sangat lambat',
      status: 'Diproses',
      comments: [
        {
          "message": "Sedang dicek oleh tim IT",
          "author": "Admin",
          "role": "admin"
        }
      ],
      history: [
        '[Internet Kantor Lambat] Tiket dibuat',
      ],
    ),
    TicketModel(
      title: 'Komputer Tidak Bisa Nyala',
      desc: 'PC tidak merespon saat ditekan tombol power',
      status: 'Diproses',
      comments: [
        {
          "message": "Sudah dilaporkan",
          "author": "User",
          "role": "user"
        }
      ],
      history: [
        '[Komputer Tidak Bisa Nyala] Tiket dibuat',
      ],
    ),

    // ASSIGNED
    TicketModel(
      title: 'Server Down',
      desc: 'Server tidak bisa diakses sejak pagi',
      status: 'Assigned',
      comments: [
        {
          "message": "Sudah di-assign ke teknisi",
          "author": "Admin",
          "role": "admin"
        }
      ],
      history: [
        '[Server Down] Tiket dibuat',
      ],
    ),
    TicketModel(
      title: 'Email Tidak Masuk',
      desc: 'Tidak menerima email dari klien',
      status: 'Assigned',
      comments: [
        {
          "message": "Dalam pengecekan",
          "author": "Helpdesk",
          "role": "helpdesk"
        }
      ],
      history: [
        '[Email Tidak Masuk] Tiket dibuat',
      ],
    ),

    // SELESAI
    TicketModel(
      title: 'Printer Error',
      desc: 'Printer tidak bisa mencetak dokumen',
      status: 'Selesai',
      comments: [
        {
          "message": "Sudah diperbaiki",
          "author": "Admin",
          "role": "admin"
        }
      ],
      history: [
        '[Printer Error] Tiket dibuat',
      ],
    ),
    TicketModel(
      title: 'Aplikasi Crash',
      desc: 'Aplikasi force close saat login',
      status: 'Selesai',
      comments: [
        {
          "message": "Sudah diupdate versi terbaru",
          "author": "Admin",
          "role": "admin"
        }
      ],
      history: [
        '[Aplikasi Crash] Tiket dibuat',
      ],
    ),
  ];

  // GET
  Future<List<TicketModel>> fetchTickets() async {
    await Future.delayed(const Duration(seconds: 1));
    return _tickets;
  }

  // CREATE
  Future<void> createTicket(TicketModel ticket) async {
    await Future.delayed(const Duration(milliseconds: 500));

    ticket.history.add('[${ticket.title}] Tiket dibuat');

    _tickets.add(ticket);
  }

  // UPDATE
  Future<void> updateTicketStatus(
      TicketModel ticket, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));

    ticket.status = status;

    ticket.history.add(
      '[${ticket.title}] Status diubah ke $status',
    );
  }

  // COMMENT
  Future<void> addComment(
      TicketModel ticket,
      String comment,
      {String author = 'User Demo', String role = 'user'}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    ticket.comments.add({
      "message": comment,
      "author": author,
      "role": role,
    });

    ticket.history.add(
      '[${ticket.title}] $author menambahkan komentar',
    );
  }

  // DASHBOARD
  int getTotalTickets() => _tickets.length;

  int getTotalByStatus(String status) =>
      _tickets.where((t) => t.status == status).length;
}