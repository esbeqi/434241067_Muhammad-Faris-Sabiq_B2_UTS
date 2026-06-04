class TicketModel {
  String title;
  String desc;
  String status;

  List<Map<String, String>> comments;
  List<String> history;

  String? imagePath;
  String? id;
  String? author;
  String? createdAt;

  TicketModel({
    required this.title,
    required this.desc,
    required this.status,
    required this.comments,
    this.imagePath,
    this.id,
    this.author,
    this.createdAt,
    List<String>? history,
  }) : history = history ?? ['Tiket dibuat'];

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      desc: json['description'] ?? '',
      status: json['status'] ?? 'Diproses',
      imagePath: json['image_url'],
      createdAt: json['created_at'],
      // Akan diisi secara manual setelah fetch dari tabel terpisah
      comments: [],
      history: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': desc,
      'status': status,
      'image_url': imagePath,
    };
  }
}
