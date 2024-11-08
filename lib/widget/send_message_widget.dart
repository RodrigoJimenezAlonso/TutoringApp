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
  bool _isKeyInitialized = false;

  void initState(){
    super.initState();
    _initializedRecipientKey();
  }

  Future<void> _initializedRecipientKey()async{
    final keyService = KeyService();
    _recipientKey = await keyService.generateKey();
    setState(() {
      _isKeyInitialized = true;
    });
  }
  Future<void> _sendMessage() async{
    if(!_isKeyInitialized){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Encryptions has not been initialized')));
      return;
    }
    final message = _messageController.text;

    if(message.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
      return;
    }
    try{
      final encryptionService = EncryptionService(_recipientKey);
      final encryptedMessage = await encryptionService.encrypt(message);

      print('Encrypted message sent: $encryptedMessage');
      _messageController.clear();
    }catch(e){
      print('Error encrypting message: $e');
    }
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