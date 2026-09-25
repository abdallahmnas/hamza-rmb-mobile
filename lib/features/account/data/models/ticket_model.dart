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
  final String? customerId;
  final String? customerName;
  final String subject;
  final String category;
  final String description;
  final String status;
  final String priority;
  final String? referenceId;
  final String? imageUrl;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketMessageModel> messages;

  const TicketModel({
    required this.id,
    this.customerId,
    this.customerName,
    required this.subject,
    this.category = 'other',
    required this.description,
    this.status = 'open',
    this.priority = 'medium',
    this.referenceId,
    this.imageUrl,
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });

  TicketModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? subject,
    String? category,
    String? description,
    String? status,
    String? priority,
    String? referenceId,
    String? imageUrl,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TicketMessageModel>? messages,
  }) {
    return TicketModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      referenceId: referenceId ?? this.referenceId,
      imageUrl: imageUrl ?? this.imageUrl,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    List<TicketMessageModel> msgs = [];
    if (json['messages'] is List<dynamic>) {
      msgs = (json['messages'] as List<dynamic>)
          .map((m) => TicketMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    List<String> attachList = [];
    if (json['attachments'] is List<dynamic>) {
      attachList = (json['attachments'] as List<dynamic>)
          .map((a) => a.toString())
          .toList();
    }

    return TicketModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString(),
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      description: json['description']?.toString() ?? json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      referenceId: json['referenceId']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      attachments: attachList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      messages: msgs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (customerId != null) 'customerId': customerId,
        if (customerName != null) 'customerName': customerName,
        'subject': subject,
        'category': category,
        'description': description,
        'status': status,
        'priority': priority,
        if (referenceId != null) 'referenceId': referenceId,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'attachments': attachments,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}
