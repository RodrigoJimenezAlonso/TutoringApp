import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class ChatScreen extends StatefulWidget {
  final int alumnoId;
  final int profesorId;

  ChatScreen({
    required this.alumnoId,
    required this.profesorId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollcontroller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _messageLoader(widget.alumnoId, widget.profesorId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data;
              if (messages == null || messages.isEmpty) {
                return Center(child: Text('No messages'));
              }

              return ListView.builder(
                controller: scrollcontroller,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message['sender_id'] == widget.alumnoId;

                  return Align(
                    alignment: isMe? Alignment.centerRight: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          color: Colors.grey[200],
          child: Row(
            children: [
              Expanded(child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                ),
              )),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async{
                  final message = messageController.text.trim();
                  if(message.isNotEmpty){
                    await _messageSender(
                      widget.alumnoId,
                      widget.profesorId,
                      message,
                    );
                    messageController.clear();
                    setState(() {
                      _scrollToBottom();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _messageLoader(int alumnoId, int profesorId) async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT * FROM messages WHERE (sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?) ORDER BY time_stamp ASC',
      [
        alumnoId,
        profesorId,
        profesorId,
        alumnoId,
      ],
    );
    await conn.close();
    return result.map((row) => row.fields).toList();
  }

  Future<void> _messageSender(int senderId, int recipientId, String message) async {
    final conn = await MySQLHelper.connect();
    final senderExist = await conn.query('SELECT id FROM users WHERE id = ?',[senderId]);
    final recipientExist = await conn.query('SELECT id FROM users WHERE id = ?',[recipientId]);
    if(senderExist.isEmpty || recipientExist.isEmpty){
      print('Error uno de los usuarios no existe');
      await conn.close();
      return;
    }
    await conn.query(
      'INSERT INTO messages(sender_id, recipient_id, sender_name, text, time_stamp, is_read) VALUES(?, ?, ?, ?, ?, ?)',
      [
        senderId,
        recipientId,
        senderId == widget.alumnoId ? 'Student' : 'Professor',
        message,
        DateTime.now().toIso8601String(),
        0,
      ],
    );
    await conn.close();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom(){
    Future.delayed(Duration(milliseconds: 300), (){
      scrollcontroller.animateTo(
        scrollcontroller.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}