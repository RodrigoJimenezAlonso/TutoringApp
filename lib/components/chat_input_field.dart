import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget{
  final TextEditingController messageController = TextEditingController();

  final Function(String) onSend;
  ChatInputField({required this.onSend});
  @override

  Widget build (BuildContext context){
    return Row(
      children: [
        Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message'
              ),
            ),
        ),
        IconButton(
            onPressed: (){
              if(messageController.text.isNotEmpty){
                onSend(messageController.text);
                messageController.clear();
              }
            },
            icon: Icon(Icons.send),
        )
      ],
    );
  }
}