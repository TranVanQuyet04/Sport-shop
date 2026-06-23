class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.sentAt,
  });

  final String id;
  final String content;
  final String sender;
  final DateTime? sentAt;

  bool get fromMe => sender.toUpperCase() == 'CUSTOMER';
  bool get fromAdmin => sender.toUpperCase() == 'ADMIN';

  factory ChatMessageModel.local({
    required String content,
    required String sender,
  }) {
    return ChatMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: content,
      sender: sender,
      sentAt: DateTime.now(),
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      content: (json['content'] ?? json['message'] ?? '').toString(),
      sender: (json['sender'] ?? '').toString(),
      sentAt: DateTime.tryParse((json['sentAt'] ?? '').toString()),
    );
  }
}

class ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    required this.customerName,
    required this.adminName,
    required this.hasUnread,
    required this.lastMessageAt,
  });

  final String id;
  final String customerName;
  final String adminName;
  final bool hasUnread;
  final DateTime? lastMessageAt;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: (json['id'] ?? '').toString(),
      customerName: (json['customerName'] ?? '').toString(),
      adminName: (json['adminName'] ?? '').toString(),
      hasUnread: json['hasUnread'] == true,
      lastMessageAt: DateTime.tryParse(
        (json['lastMessageAt'] ?? '').toString(),
      ),
    );
  }
}
