import 'package:cryptography/cryptography.dart';

class EncryptionService{
  final SecretKey _key;
  EncryptionService(this._key);
  Future<SecretBox> encrypt (String message) async{
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    return await algorithm.encrypt(
        message.codeUnits,
        secretKey: _key,
        nonce: nonce,
    );
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