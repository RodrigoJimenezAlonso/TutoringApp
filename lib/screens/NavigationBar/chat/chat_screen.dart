import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> _messages = [];
  late Future<List<Map<String, dynamic>>> futureMessages;
  final FocusNode _focusNode = FocusNode();
  String? professorUserName;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureMessages = _messageLoader();
    _loadProfessorUserName();
  }

  Future<void> _loadProfessorUserName()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT username FROM users WHERE id = ?',
      [
        widget.profesorId
      ]
    );
    if(result.isNotEmpty){
      setState(() {
        professorUserName = result.first[0];
      });
    }
    await conn.close();

  }

  @override
  Widget build(BuildContext context) {
    String channelName = '${widget.alumnoId} - ${widget.profesorId}';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            SizedBox(width: 10),
            Text(professorUserName ?? 'Cargando...', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No hay mensajes aún."));
                }

                final messages = snapshot.data!;
                print("Mensajes obtenidos: $messages");

                return ListView.builder(
                  controller: scrollcontroller,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == widget.alumnoId;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                          SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.all(12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[700] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                                bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
                              ),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    message['sender_name'] ?? '',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                SizedBox(height: 2),
                                Text(message['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black)),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                    textInputAction: TextInputAction.send,
                    onTap: () {
                      setState(() {});
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                    onSubmitted: (message) {
                      _sendMessage(message);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = messageController.text.trim();
                    _sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _messageLoader() async {
    final conn = await MySQLHelper.connect();

    int alumnoId = widget.alumnoId;
    print("Alumno ID: $alumnoId");

    int profesorId = widget.profesorId; // Usar el profesorId que ya viene de la pantalla anterior

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

    print("Mensajes obtenidos de la BD: $result");

    final messages = result.map((row) => row.fields).toList();
    print("Mensajes en formato de lista: $messages");

    return messages;
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    final conn = await MySQLHelper.connect();

    final result = await conn.query(
        'SELECT username FROM users WHERE id = ?', [widget.alumnoId]
    );
    String senderName = result.isNotEmpty ? result.first[0] : 'Unknown';

    int profesorId = widget.profesorId;
    await conn.query(
      'INSERT INTO messages(sender_id, recipient_id, sender_name, text, time_stamp, is_read) VALUES(?, ?, ?, ?, ?, ?)',
      [
        widget.alumnoId,
        profesorId,
        senderName,
        message,
        DateTime.now().toIso8601String(),
        0,
      ],
    );

    await conn.close();
    messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (scrollcontroller.hasClients) {
        scrollcontroller.animateTo(
          scrollcontroller.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}