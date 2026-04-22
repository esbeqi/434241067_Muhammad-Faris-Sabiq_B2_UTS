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
}