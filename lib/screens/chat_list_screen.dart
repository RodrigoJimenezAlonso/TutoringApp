import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget{
  final int userId;
  final String row;

  ChatListScreen({
    required this.row,
    required this.userId,
  });

  @override
  _ChatListScreenState createState()=> _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>{
  Future<List<Map<String, dynamic>>> _loadChatList()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      '''
       SELECT 
         CASE
          WHEN m.sender_id = ? THEN m.recipient_id
          ELSE m.sender_id
         END AS chat_partner_id,
         u.name as chat_partner_name,
         MAX(m.text) AS last_message,
         MAX(m.time_stamp) AS last_message_time,
       FROM messages m 
       JOIN users u ON u.id = CASE
         WHEN m.sender_id = ? THEN m.recipient_id
         ELSE m.sender_id
       END 
       WHERE m.sender_id = ? OR m.recipient_id = ?
       GROUP BY chat_partner_id, chat_partner_name
       ORDER BY last_message_time DESC
      ''',
      [
        widget.userId,
        widget.userId,
        widget.userId,
        widget.userId,
      ],
    );
    await conn.close();
    return result.map(
        (row)=> row.fields
    ).toList();
  }

  String _formatTime(String timeStamp){
    DateTime time = DateTime.parse(timeStamp);
    return "${time.hour.toString().padLeft(2, '0')}: ${time.minute.toString().padLeft(2, '0')}";
  }

  String _getInitials(String name){
    List<String> words = name.split(' ');
    String initials = words.map((word)=> word[0]).take(2).join().toUpperCase();
    return initials;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<List<Map<String,dynamic>>>(
          future: _loadChatList(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final chats = snapshot.data!;
            if(chats.isEmpty){
              return Center(
                child: Text(
                  'No Chats Available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (context, index)=>Divider(color: Colors.grey[300], indent: 70, endIndent: 10,),
              itemBuilder: (context, index){
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Text(
                      _getInitials(chat['chat_partner_name']),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    chat['chat_partner_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    chat['last_message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  trailing: Text(
                    chat['last_message_time'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),

                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=> ChatScreen(
                                alumnoId: widget.row == 'Student'? widget.userId : chat['chat_partner_id'],
                                profesorId: widget.row == 'Professor'? widget.userId : chat['chat_partner_id'],
                            ),
                        ),
                    );
                  },



                );
              },
            );
          },
      ),
    );
  }
}