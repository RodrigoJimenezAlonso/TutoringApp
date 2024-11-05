import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class EncryptionService{
  final SecretKey _key;
  EncryptionService(this._key);
  Future<List<int>> encrypt (String message) async{
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
        message.codeUnits,
        secretKey: _key,
        nonce: nonce,
    );
    return secretBox.cipherText;
  }
  Future<String> decrypt (SecretBox secretBox) async{
    final algorithm = AesGcm.with256bits();
    final plainText = await algorithm.decrypt(
        secretBox,
        secretKey: _key,
    );
    return String.fromCharCodes(plainText);
  }
}