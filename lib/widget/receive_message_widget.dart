import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import '../cryptography/encryption_service.dart';
import '../services/key_service.dart';

class ReceiveMessageWidget extends StatefulWidget{
  @override
  _ReceiveMessageWidgetState createState()=> _ReceiveMessageWidgetState();
}

class _ReceiveMessageWidgetState extends State<ReceiveMessageWidget>{
  late SecretKey _recipientKey;
  String _decryptedMessage = '';
  bool _isKeyInitialized = false;
  @override
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

  Future<void> _receiveMessage(List<int> encryptedMessage) async{
    if(!_isKeyInitialized){
      print('My recipient key has not being initialized');
      return;
    }
    try{
      final tag = encryptedMessage.sublist(encryptedMessage.length - 16);
      final nonce = encryptedMessage.sublist(encryptedMessage.length - 32, encryptedMessage.length - 16);
      final cipherText = encryptedMessage.sublist(0, encryptedMessage.length -32);
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(tag),
      );
      final encryptionService = EncryptionService(_recipientKey);
      final decryptedMessage = await encryptionService.decrypt(secretBox);
      setState(() {
        _decryptedMessage = decryptedMessage;
      });
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