import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:proyecto_rr_principal/mysql.dart';
import '../models/message.dart';

class ChatService{
  Future<List<Message>> getMessage(String chatId)async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT * FROM messages WHERE chat_id = ? ORDER BY timestamp DESC',
          [
            chatId
          ],
      );
      await conn.close();
      return result.map((row){
        return Message.fromMap(row['id']);
      }).toList();
    }
    catch(e){
      throw Exception('Could not get the message: $e');
    }
  }

  Future<void> sendMessage(String chatId, Message message)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'INSERT INTO messages (chat_id, text, sender_id, timestamp) VALUES(?,?,?,?)',
        [
          chatId,
          message.text,
          message.senderId,
          message.timestamp.toIso8601String(),
        ],
      );
      await conn.close();
    }
    catch(e){
      throw Exception('error sending message: $e');
    }
  }
}