import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final int userId;
  final String role;
  Uint8List? imageBytes;


  ChatListScreen({
    required this.role,
    required this.userId,
  });


  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}



class _ChatListScreenState extends State<ChatListScreen> {
  bool _isSearching = false;



  Future<List<Map<String, dynamic>>> _loadChatList() async {

    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        '''
          SELECT 
            CASE 
              WHEN m.sender_id = ? THEN m.recipient_id 
              ELSE m.sender_id 
            END AS chat_partner_id,
            
            u.username AS chat_partner_name,
            u.profile_picture AS chat_partner_picture,
        
            (SELECT text FROM messages 
             WHERE (sender_id = chat_partner_id AND recipient_id = ?) 
                OR (sender_id = ? AND recipient_id = chat_partner_id) 
             ORDER BY time_stamp DESC 
             LIMIT 1) AS last_message,
        
            MAX(m.time_stamp) AS last_message_time
        
          FROM messages m
          JOIN users u ON u.id = 
            (CASE WHEN m.sender_id = ? THEN m.recipient_id ELSE m.sender_id END)
        
          WHERE m.sender_id = ? OR m.recipient_id = ?
          GROUP BY chat_partner_id, u.username, u.profile_picture
          ORDER BY last_message_time DESC
        ''',
        [
          widget.userId, widget.userId, widget.userId,
          widget.userId, widget.userId, widget.userId
        ],
      );

      print("Resultados obtenidos de la BD: ${result.map((row) => row.fields).toList()}");



      List<Map<String, dynamic>> chatList = result.map((row) => row.fields).toList();


      for (var chat in chatList) {
        var unreadCountResult = await conn.query(
            '''
        SELECT COUNT(*) AS unread_count 
        FROM messages 
        WHERE recipient_id = ? AND sender_id = ? AND is_read = 0
        ''',
            [widget.userId, chat['chat_partner_id']]
        );

        chat['unread_count'] = unreadCountResult.isNotEmpty ? unreadCountResult.first['unread_count'] : 0;
      }



      await conn.close();

      print("Datos obtenidos de la BD: ${result.map((row) => row.fields).toList()}");

      return result.map((row) => row.fields).toList();
    } catch (e) {
      print('Error en la consulta SQL: $e');
      return [];
    }
  }


  Future<void> _deleteChat(int chatPartnerId)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'DELETE FROM messages WHERE(sender_id = ? and recipient_id = ?) OR (sender_id = ? and recipient_id = ?) ',
        [
          widget.userId,
          chatPartnerId,
          chatPartnerId,
          widget.userId,

        ]
      );
      await conn.close();
    }catch(e){
      print('Error eliminando el chat: $e');
    }
  }

  Future<void> _markAsRead()async{

  }


  String _formatTime(String timeStamp) {
    if (timeStamp == null || timeStamp.isEmpty) {
      return "--:--";
    }
    DateTime time = DateTime.parse(timeStamp);
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
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
        title: _isSearching
            ? TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search chats...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: null,
            )
            : Text(
              'Chats',
              style: TextStyle(color: Colors.white),
            ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },

          ),
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
            itemCount: chats.isNotEmpty ? chats.length + 1 : 1, // Si no hay chats, solo mostramos el texto
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              indent: 70,
              endIndent: 10,
            ),
            itemBuilder: (context, index) {


              if (chats.isEmpty || index == chats.length) {
                // Muestra el mensaje solo si la lista está vacía o al final de la lista
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.grey[600],),
                        SizedBox(width: 8,),
                        Text(
                          "Your personal messages are end-to-end encrypted",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600],),
                        ),
                      ],
                    )
                  ),
                );
              }

              final chat = chats[index];
              return Dismissible(
                  key: Key(chat['chat_partner_id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white,),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    bool shouldDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Deleting Chat"),
                          content: Text("Are you sure you want to delete the chat? This action cannot be reversed."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false), // Cancelar
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true), // Confirmar
                              child: Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                    return shouldDelete;
                  },
                  onDismissed: (direction){
                    _deleteChat(chat['chat_partner_id']);
                    setState(() {});
                  },
                  child: ListTile(
                    leading: chat['chat_partner_picture'] != null && chat['chat_partner_picture'] is Blob
                        ? CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: MemoryImage(
                        Uint8List.fromList((chat['chat_partner_picture'] as Blob).toBytes()),
                      ),
                    )
                        : CircleAvatar(
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
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chat['last_message_time'] != null
                              ? _formatTime(chat['last_message_time'].toString())
                              : '--:--',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (chat['unread_count'] > 0)
                          Container(
                            margin: EdgeInsets.only(top: 2), // Espacio entre la hora y la burbuja
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${chat['unread_count']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      int alumnoId = widget.userId;
                      int profesorId = chat['chat_partner_id'];
                      setState(() {
                        chat['unread_count'] = 0;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            alumnoId: alumnoId,
                            profesorId: profesorId,
                          ),
                        ),
                      );
                    },

                  )
              );
            },
          );
        },
      ),

    );
  }

}