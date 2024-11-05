class Message{
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false
  });

  Map<String, dynamic> toMap(){
    return {
      'senderId':senderId,
      'senderName':senderName,
      'text':text,
      'timestamp':timestamp.toIso8601String(),
      'isRead':isRead,
    };
  }

  static Message fromMap(String id, Map<String, dynamic> map ){
    return Message(
        id: id,
        senderId: map['senderId'],
        senderName: map['senderName'],
        text: map['text'],
        timestamp: DateTime.parse(map['timestamp']),
        isRead: map['isRead'] ?? false,
    );
  }

}