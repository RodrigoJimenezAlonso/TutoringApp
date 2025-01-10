import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/screens/chat_screen.dart';

class MessageScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Messages'),
            bottom: TabBar(
                tabs: [
                  Tab(text: 'Student Message',),
                  Tab(text: 'Teacher Message',)
                ],
            ),
          ),
          body: TabBarView(
              children: [
                ChatScreen(
                    alumnoId: 7,
                    profesorId: 8,
                    senderType: 'student',
                ),
                ChatScreen(
                  alumnoId: 7,
                  profesorId: 8,
                  senderType: 'teacher',
                ),
              ]
          ),
        ),
    );
  }
}