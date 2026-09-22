class TicketMessageModel {
  final String id;
  final String sender;
  final String message;
  final DateTime timestamp;

  const TicketMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? json['senderName']?.toString() ?? 'Support',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['timestamp'] ?? json['createdAt']).toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };
}

class TicketModel {
  final String id;
  final String subject;
  final String category;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final List<TicketMessageModel> messages;

  const TicketModel({
    required this.id,
    required this.subject,
    this.category = 'shipping',
    required this.description,
    this.status = 'open',
    this.priority = 'medium',
    required this.createdAt,
    this.messages = const [],
  });

  DateTime? get updatedAt => messages.isNotEmpty ? messages.last.timestamp : null;


  factory TicketModel.fromJson(Map<String, dynamic> json) {
    List<TicketMessageModel> msgs = [];
    if (json['messages'] is List<dynamic>) {
      msgs = (json['messages'] as List<dynamic>)
          .map((m) => TicketMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return TicketModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? 'shipping',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: msgs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'category': category,
        'description': description,
        'status': status,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}
