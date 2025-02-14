import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final int userId;
  final String role;

  ChatListScreen({
    required this.role,
    required this.userId,
  });

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<List<Map<String, dynamic>>> _loadChatList() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        '''
      SELECT 
        chat_partner_id, 
        MAX(chat_partner_name) AS chat_partner_name,
        MAX(last_message) AS last_message,
        MAX(last_message_time) AS last_message_time
      FROM(
        SELECT
          CASE 
            WHEN m.sender_id = ? THEN m.recipient_id 
            ELSE m.sender_id 
          END AS chat_partner_id,
          u.username AS chat_partner_name,
          m.text AS last_message,
          m.time_stamp AS last_message_time
        FROM messages m
        LEFT JOIN users u ON u.teacher_id = 
          (CASE WHEN m.sender_id = ? THEN m.recipient_id ELSE m.sender_id END)
        WHERE m.sender_id = ? OR m.recipient_id = ?
      ) AS grouped_chat
      GROUP BY chat_partner_id
      ORDER BY last_message_time DESC
      ''',
        [
          widget.userId, widget.userId, widget.userId, widget.userId,
        ],
      );
      await conn.close();

      // Verificar los datos obtenidos en la consulta
      print("Datos obtenidos de la BD: ${result.map((row) => row.fields).toList()}");

      return result.map((row) => row.fields).toList();
    } catch (e) {
      print('Error en la consulta SQL: $e');
      return [];
    }
  }

  String _formatTime(String timeStamp) {
    if(timeStamp == null || timeStamp.isEmpty){
      return "--:--";
    }
    DateTime time = DateTime.parse(timeStamp);
    return "${time.hour.toString().padLeft(2, '0')}: ${time.minute.toString().padLeft(2, '0')}";
  }

  String _getInitials(String? name) {
    if(name == null || name.isEmpty){
      return "?";
    }
    List<String> words = name.split(' ');
    String initials = words.map((word) => word[0]).take(2).join().toUpperCase();
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[800],
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,

        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          )
        ],

      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar los chats: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

          final chats = snapshot.data!;
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              indent: 70,
              endIndent: 10,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[700],
                  child: Text(
                    _getInitials(chat['chat_partner_name']?.toString()),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  chat['chat_partner_name'] ?? "Unknown user",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  chat['last_message'] != null ? chat['last_message'] : 'No Messages Available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Text(
                  chat['last_message_time'] != null
                    ? _formatTime(chat['last_message_time'].toString())
                    : '--:--',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        alumnoId: widget.role == 'Student' ? widget.userId : chat['chat_partner_id'],
                        profesorId: widget.role == 'Professor' ? widget.userId : chat['chat_partner_id'],
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