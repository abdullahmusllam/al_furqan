class Message {
  int? id;
  int? senderId;
  int? receiverId;
  String content;
  String timestamp;
  int sync;
  String senderType;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.sync,
    required this.senderType,
  });

  // Convert Message to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'sync': sync,
      'senderType': senderType,
    };
  }

  // Create Message from Map (for SQLite)
  factory Message.fromMap(Map<String, dynamic> map) {
  return Message(
    id: map['id'],
    senderId: map['senderId'] ?? 0,
    receiverId: map['receiverId'] ?? 0,
    content: map['content'] ?? '',
    timestamp: map['timestamp'] ?? '',
    sync: map['sync'] ?? 0,
    senderType: map['senderType'] ?? '',
  );
}


  // Convert Message to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'sync':sync,
      'senderType': senderType,
    };
  }

  // Create Message from Firebase document
  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: int.tryParse(id),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: json['timestamp'],
      sync: 1, // Synced messages from Firebase
      senderType: json['senderType'],
    );
  }
}