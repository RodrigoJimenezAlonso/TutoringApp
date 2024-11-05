import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class ChatService{
  final SupabaseClient _client = Supabase.instance.client;
  Stream<List<Message>> getMessages(String chatId){
    return _client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('chat_id', chatId)
      .order('timestamp', ascending: false)
      .map((data){
        return (data as List<dynamic>)
        .map((doc)=> Message.fromMap(doc['id'], doc as Map<String, dynamic>))
        .toList();
    });
  }
  Future<void> sendMessage(String chatId, Message message)async{
    final response = await _client.from('messages').insert({
      'chat_id': chatId,
      ...message.toMap(),
    });
    if(response.error != null){
      throw Exception(response.error!.message);
    }
  }
}