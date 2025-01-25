import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/screens/chat_screen.dart';
import 'package:proyecto_rr_principal/video_call_screen.dart';

class MessageScreen extends StatelessWidget{

  final int alumnoId;
  final int professorId;

  MessageScreen({
    required this.alumnoId,
    required this.professorId,
  });

  @override
  Widget build(BuildContext context) {
    String channelName = '${alumnoId}-${professorId}';
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context)=> VideoCallScreen(
                          userId: alumnoId,
                          token: '',
                          channelName: channelName,
                      ),
                  )
                );
              },

              
          ),
        ],
      ),
      body: ChatScreen(
          alumnoId: alumnoId,
          profesorId: professorId,
      ),
    );
  }
}