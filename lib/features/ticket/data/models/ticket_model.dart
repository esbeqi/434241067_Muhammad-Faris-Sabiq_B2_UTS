class TicketModel {
  String title;
  String desc;
  String status;
  String? assignedHelpdesk;

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
    this.assignedHelpdesk,
    required this.comments,
    this.imagePath,
    this.id,
    this.author,
    this.createdAt,
    List<String>? history,
  }) : history = history ?? ['Tiket dibuat'];

  factory TicketModel.fromJson(Map<String, dynamic> json) {

    List<Map<String, String>> parsedComments = [];
    if (json['comments'] != null) {
      parsedComments = (json['comments'] as List).map((c) => {
        "message": c['message']?.toString() ?? '',
        "author": c['author']?.toString() ?? '',
        "role": c['role']?.toString() ?? '',
      }).toList();
    }

    List<String> parsedHistory = ['Tiket dibuat'];
    if (json['histories'] != null) {
      parsedHistory = (json['histories'] as List)
          .map((h) => h['activity']?.toString() ?? '')
          .toList();
    } else if (json['history'] != null) {
      parsedHistory = List<String>.from(json['history']);
    }

    return TicketModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      desc: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      assignedHelpdesk: json['assigned_helpdesk'],
      imagePath: json['image_url'],
      createdAt: json['created_at'],
      comments: parsedComments,
      history: parsedHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': desc,
      'status': status,
      'assigned_helpdesk': assignedHelpdesk,
      'image_url': imagePath,
    };
  }
}
