import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import '../cryptography/encryption_service.dart';
import '../services/key_service.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class ReceiveMessageWidget extends StatefulWidget{
  @override
  _ReceiveMessageWidgetState createState()=> _ReceiveMessageWidgetState();
}

class _ReceiveMessageWidgetState extends State<ReceiveMessageWidget>{

  String _decryptedMessage = '';

  Future<void> _receiveMessage(String messageId) async{
    try{

      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT encryptedMessage FROM messages WHERE id = ?',
        [
          messageId
        ],
      );
      if(result.isEmpty) {
        print('No meesage with the id found $messageId');
        return;
      }
      final encryptedData = result.first['encryptedMessage'] as String;
      final encryptedMessage = encryptedData.split(',').map(int.parse).toList();
      final tag = encryptedMessage.sublist(encryptedMessage.length - 16);
      final nonce = encryptedMessage.sublist(
          encryptedMessage.length - 32,
          encryptedMessage.length - 16
      );
      final cipherText = encryptedMessage.sublist(
          0,
          encryptedMessage.length -32
      );
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(tag),
      );
      final encryptionService = EncryptionService();
      final decryptedMessage = await encryptionService.decrypt(secretBox);
      setState(() {
        _decryptedMessage = decryptedMessage;
      });
      await conn.close();
    }catch(e){
      print('Error encrypting message: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      //Pendiente la construccion de la inbterfaz de los mensajes de descifrado
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent,),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Message Received',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
              _decryptedMessage.isNotEmpty ? _decryptedMessage : 'No message yet' ,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

}