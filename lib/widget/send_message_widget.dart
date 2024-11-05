import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import '../cryptography/encryption_service.dart';
import '../services/key_service.dart';

class SendMessageWidget extends StatefulWidget{
  @override
  _SendMessageWidgetState createState()=> _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget>{
  final TextEditingController _messageController = TextEditingController();
  late SecretKey _recipientKey;
  Future<void> _sendMessage() async{
    final message = _messageController.text;

    if(message.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
      return;
    }
    final encryptionService = EncryptionService(_recipientKey);
    final encryptedMessage = await encryptionService.encrypt(message);

    print('Encrypted message sent: $encryptedMessage');
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'message',
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text(
                'send'
            ),
          )
        ],
      ),
    );
  }
}