import 'package:proyecto_rr_principal/mysql.dart';

class Message{
  final String id;
  final String senderId;
  final String recipientId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false
  });


  factory Message.fromMap(Map<String, dynamic> map){
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      recipientId: map['recipientId'],
      senderName: map['senderName'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'senderId':senderId,
      'recipientId':recipientId,
      'senderName':senderName,
      'text':text,
      'timestamp':timestamp.toIso8601String(),
      'isRead':isRead,
    };
  }

  static Future<List<Message>> fetchMessage() async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT * FROM messages',
    );
    return result.map(
        (row){
          return Message.fromMap(row.fields);
        }
    ).toList();
  }
  static Future<void> addMessage(Message message) async{
    final conn = await MySQLHelper.connect();
    await conn.query(
      'INSERT INTO messages(id, sender_id, recipient_id, sender_name, text, time_stamp, is_read) VALUES(?,?,?,?,?,?)',
      [
        message.id,
        message.senderId,
        message.recipientId,
        message.senderName,
        message.text,
        message.timestamp.toIso8601String(),
        message.isRead ? 1 : 0
      ]
    );
  }
}