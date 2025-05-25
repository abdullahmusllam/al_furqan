class Message {
  final String? id;
  final String senderId;
  final String receiverId;
  final String content;
  final String timestamp;
  final String senderType;
  final String receiverType;
  final String circleId; // معرف الحلقة لربط الرسائل بالحلقة التي ينتمي إليها الطالب

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.senderType,
    required this.receiverType,
    required this.circleId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] ?? '',
      senderType: map['senderType'] ?? '',
      receiverType: map['receiverType'] ?? '',
      circleId: map['circleId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'senderType': senderType,
      'receiverType': receiverType,
      'circleId': circleId,
    };
  }
}