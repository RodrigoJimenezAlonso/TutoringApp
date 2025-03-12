import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/video_call_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/StudentProfile/student_profile_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/teacherProfile/teacher_profile_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';


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
  final FocusNode _focusNode = FocusNode();
  String? professorUserName;
  Uint8List? professorProfilePicture;




  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    print("Inicializando ChatScreen con alumnoId: ${widget.alumnoId}, profesorId: ${widget.profesorId}");


    _loadProfessorUserName();
    _loadMessages();
  }

  Future<void> _loadProfessorUserName()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT username, profile_picture FROM users WHERE id = ?',
      [
        widget.profesorId
      ]
    );
    print('LOAD PROFESSOR DATA: ${result}');

    if (result.isNotEmpty) {
      setState(() {
        professorUserName = result.first.fields['username'];

        var profilePictureBlob = result.first.fields['profile_picture'];
        if (profilePictureBlob != null && profilePictureBlob is Blob) {
          professorProfilePicture = Uint8List.fromList(profilePictureBlob.toBytes());
        } else {
          professorProfilePicture = null;
        }
      });
    }
    await conn.close();

  }

  @override
  Widget build(BuildContext context) {
    String channelName = '${widget.alumnoId} - ${widget.profesorId}';
    print("Cargando mensajes entre alumno ID: ${widget.alumnoId} y profesor ID: ${widget.profesorId}");
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode == true ? Colors.white : Colors.black, //change your color here
        ),
        backgroundColor: themeProvider.isDarkMode == true ? Colors.black : Colors.grey[200],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: themeProvider.isDarkMode == true ? Colors.white : Colors.white,
              backgroundImage: professorProfilePicture != null
                  ? MemoryImage(professorProfilePicture!)
                  : null,
              child: professorProfilePicture == null
                  ? Icon(Icons.person, color: Colors.blue)
                  : null,
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: _navigateToProfileScreen,
              child: Text(
                professorUserName ?? 'Cargando...',
                style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              ),
            )

          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black),
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
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Color(0xFFECE5DD),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text(""))
                : ListView.builder(
              controller: scrollcontroller,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBocadillo(message);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: themeProvider.isDarkMode == true ? Colors.black : Colors.grey[200],
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black, size: 30,),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: themeProvider.isDarkMode == true ? Colors.grey[800] : Colors.white,
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
                    icon: Icon(Icons.send_rounded),
                    onPressed: () {
                      String message = messageController.text.trim();
                      _sendMessage(message);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _sendMessage(String? text, [Uint8List? imageBytes]) async {
    if ((text == null || text.isEmpty) && imageBytes == null) return;

    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT username FROM users WHERE id = ?', [widget.alumnoId]
      );

      String senderName = result.isNotEmpty ? result.first[0] : 'Unknown';
      int profesorId = widget.profesorId;
      String formattedDateTime = DateTime.now().toUtc().toString().split('.')[0];

      await conn.query(
        'INSERT INTO messages(sender_id, recipient_id, sender_name, text, image, time_stamp, is_read) VALUES(?, ?, ?, ?, ?, ?, ?)',
        [
          widget.alumnoId,
          profesorId,
          senderName,
          text,
          imageBytes,
          formattedDateTime,
          0,
        ],
      );

      await conn.close();
      messageController.clear();

      setState(() {
        _messages.add({
          'sender_id': widget.alumnoId,
          'recipient_id': widget.profesorId,
          'sender_name': senderName,
          'text': text,
          'image': imageBytes,
          'time_stamp': formattedDateTime,
        });
      });

      _scrollToBottom();
    } catch (e) {
      print("Error enviando mensaje: $e");
    }
  }



  Future<void> _loadMessages() async {
    try {
      final conn = await MySQLHelper.connect();

      final result = await conn.query(
          '''
        SELECT sender_id, recipient_id, sender_name, text, image, time_stamp 
        FROM messages 
        WHERE (sender_id = ? AND recipient_id = ?) 
           OR (sender_id = ? AND recipient_id = ?) 
        ORDER BY time_stamp ASC
        ''',
          [widget.alumnoId, widget.profesorId, widget.profesorId, widget.alumnoId]
      );

      await conn.query(
          '''
      UPDATE messages 
      SET is_read = 1 
      WHERE recipient_id = ? AND sender_id = ?
      ''',
          [widget.alumnoId, widget.profesorId]
      );

      await conn.close();

      print("Mensajes obtenidos de la BD: ${result.map((row) => row.fields).toList()}");

      setState(() {
        _messages = result.map((row) {
          var imageBlob = row['image'];

          return {
            'sender_id': row['sender_id'],
            'recipient_id': row['recipient_id'],
            'sender_name': row['sender_name'],
            'text': row['text'],
            'image': (imageBlob != null && imageBlob is Blob) ? Uint8List.fromList(imageBlob.toBytes()) : null,
            'time_stamp': row['time_stamp'],
            'is_read': row['is_read'],
          };
        }).toList();
      });


      _scrollToBottom();
    } catch (e) {
      print("Error cargando mensajes: $e");
    }
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


  Widget _buildMessageBocadillo(Map<String, dynamic> message) {
    final bool isMe = message['sender_id'] == widget.alumnoId;
    Uint8List? imageBytes = message['image'];

    // Formatear la hora
    String formattedTime = '';
    if (message['time_stamp'] != null) {
      DateTime dateTime;
      if (message['time_stamp'] is DateTime) {
        dateTime = message['time_stamp'];
      } else if (message['time_stamp'] is String) {
        dateTime = DateTime.parse(message['time_stamp']);
      } else {
        dateTime = DateTime.now();
      }
      dateTime = dateTime.toLocal();
      formattedTime = "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    double maxWidth = MediaQuery.of(context).size.width * 0.60;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[800] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(4),
              bottomRight: isMe ? Radius.circular(4) : Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageBytes != null && imageBytes.isNotEmpty)
                GestureDetector(
                  onTap: () => _showFullImage(context, imageBytes),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes,
                      width: MediaQuery.of(context).size.width * 0.40,
                      height: MediaQuery.of(context).size.height * 0.25,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: imageBytes != null ? 6 : 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          message['text'] ?? "",
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }











  void _showFullImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }






  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Uint8List imageBytes = await imageFile.readAsBytes();
      _sendMessage(null, imageBytes);
    }
  }


  Future<void> _navigateToProfileScreen() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT role FROM users WHERE id = ?',
        [widget.profesorId]
    );

    if (result.isNotEmpty) {
      String role = result.first.fields['role'];
      if (role == 'student') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentProfileScreen(studentId: widget.profesorId),
        ));
      } else if (role == 'teacher') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeacherProfileScreen(teacherId: widget.profesorId, studentId: widget.alumnoId,)),
        );
      }
    }
    await conn.close();
  }




}