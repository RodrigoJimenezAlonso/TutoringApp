import 'package:cryptography/cryptography.dart';
import 'package:proyecto_rr_principal/services/key_service.dart';

class EncryptionService{
  final Future<SecretKey> _key;
  EncryptionService() : _key = KeyService().getKey();
  Future<SecretBox> encrypt (String message) async{
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final secretKey = await _key;
    return await algorithm.encrypt(
        message.codeUnits,
        secretKey: secretKey,
        nonce: nonce,
    );
  }
  Future<String> decrypt (SecretBox secretBox) async{
    final algorithm = AesGcm.with256bits();
    final secretKey = await _key;
    final plainText = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
    );
    return String.fromCharCodes(plainText);
  }
}