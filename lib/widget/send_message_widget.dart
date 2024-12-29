import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import '../cryptography/encryption_service.dart';
import '../services/key_service.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/models/message.dart';

class SendMessageWidget extends StatefulWidget{
  @override
  _SendMessageWidgetState createState()=> _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget>{
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage(String recipientId) async{
    final message = _messageController.text;
    if(message.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please insert a message')));
      return;
    }
    try {
      final keyService = KeyService();
      final encryptionService = EncryptionService();
      final encryptedMessage = await encryptionService.encrypt(message);
      final cipherText  = encryptedMessage.cipherText;
      final nonce = encryptedMessage.nonce;
      final mac = encryptedMessage.mac.bytes;
      final serializedMessage = [
        ...cipherText,
        ...mac,
        ...nonce
      ].join(',');
        final conn = await MySQLHelper.connect();
        await conn.query(
          'INSERT INTO messages(recipientId, encryptedMessage) VALUES(?,?)',
          [
            recipientId,
            serializedMessage,
          ],
        );
        await conn.close();
        print('Encrypted message was sent: $encryptedMessage');
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
            onPressed: ()=> _sendMessage('recipient_id'),
            child: Text(
                'send'
            ),
          )
        ],
      ),
    );
  }
}