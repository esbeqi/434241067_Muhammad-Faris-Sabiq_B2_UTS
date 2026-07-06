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
    return TicketModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      desc: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      assignedHelpdesk: json['assigned_helpdesk'],
      imagePath: json['image_url'],
      createdAt: json['created_at'],
      comments: [],
      history: json['history'] != null 
          ? List<String>.from(json['history']) 
          : ['Tiket dibuat'],
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
