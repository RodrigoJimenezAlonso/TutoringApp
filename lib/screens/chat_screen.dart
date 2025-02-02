import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/video_call_screen.dart';

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

    String channelName  = '${widget.alumnoId} - ${widget.profesorId}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue,),
            ),
            SizedBox(width: 10,),

            Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.white,),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context)=> VideoCallScreen(
                          userId: widget.alumnoId,
                          token: '',
                          channelName: channelName,
                      ),
                  ),
              );
            },

          ),
        ],
      ),

      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _messageLoader(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: scrollcontroller,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == widget.alumnoId;

                    return Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      alignment: isMe? Alignment.centerRight: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if(!isMe) CircleAvatar(child: Icon(Icons.person, color: Colors.white,),),
                          SizedBox(width: 5,),
                          Container(
                            padding: EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[700] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: isMe ? Radius.circular(15) :Radius.circular(0),
                                bottomRight: isMe ? Radius.circular(0) :Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(!isMe)
                                  Text(
                                    message['sender_name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                SizedBox(height: 2,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _messageLoader() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT * FROM messages WHERE (sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?) ORDER BY time_stamp ASC',
      [
        widget.alumnoId,
        widget.profesorId,
        widget.profesorId,
        widget.alumnoId,
      ],
    );
    await conn.close();
    return result.map((row) => row.fields).toList();
  }

  Future<void> _sendMessage(String message) async {
    if(message.isEmpty) return;

    final conn = await MySQLHelper.connect();
    await conn.query(
      'INSERT INTO messages(sender_id, recipient_id, sender_name, text, time_stamp, is_read) VALUES(?, ?, ?, ?, ?, ?)',
      [
        widget.alumnoId,
        widget.profesorId,
        widget.alumnoId == widget.alumnoId ? 'Student' : 'Professor',
        message,
        0,
      ],
    );
    await conn.close();
    messageController.clear();
    setState(() {});
    _scrollToBottom();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom(){
    Future.delayed(Duration(milliseconds: 300), (){
      if(scrollcontroller.hasClients){
        scrollcontroller.animateTo(
          scrollcontroller.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage()async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      print('Imagen Seleccionada: ${pickedFile.path}');
      //todo: agregar logica para enviar imagenes
    }
  }
}