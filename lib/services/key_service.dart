import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../services/flutter_storage.dart';

class KeyService{
  final AesGcm _algorithm = AesGcm.with256bits();
  SecretKey? _cachedKey;

  Future<SecretKey> getKey() async{
    if(_cachedKey != null){
      return _cachedKey!;
    }
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();
    _cachedKey = secretKey;
    return secretKey;
  }


  Future<SecretKey> generateKey() async{
    try{
      return await _algorithm.newSecretKey();
    }catch(e){
      print('Error generating secret KEY: $e');
      rethrow;
    }
  }

  Future<List<int>> getKeyBytes(SecretKey key)async{
    try{
      return await key.extractBytes();
    }catch(e){
      print('Error generating getting key bytes: $e');
      rethrow;
    }
  }

  String encodeKey(List<int> keyBytes){
    return base64Encode(keyBytes);
  }

  List<int> decodeKey(String encodedKey){
    return base64Decode(encodedKey);
  }

}

Future<void> main() async{
  final keyService = KeyService();
  try{
    final secretKey = await keyService.generateKey();
    final keyBytes = await keyService.getKeyBytes(secretKey);
    final encodedKey = keyService.encodeKey(keyBytes);
    await secureStorage.writeKey('user_key', encodedKey);
    print('Stored key on base 64: $encodedKey');

  }catch(e){
    print('Error on generating the key Service: $e');
  }


}
