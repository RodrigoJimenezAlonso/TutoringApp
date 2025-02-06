import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/screens/chat_list_screen.dart';
import 'package:proyecto_rr_principal/screens/chat_screen.dart';
import 'package:proyecto_rr_principal/video_call_screen.dart';

class MessageScreen extends StatelessWidget{

  final int userId;
  final String role;
  final int alumnoId;
  final int professorId;



  MessageScreen({
    required this.userId,
    required this.role,
    required this.alumnoId,
    required this.professorId,
  });

  @override
  Widget build(BuildContext context) {
    String channelName = '${alumnoId}-${professorId}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ChatListScreen(
          role: role,
          userId: userId
      ),
    );
  }
}