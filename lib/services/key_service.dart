import 'package:cryptography/cryptography.dart';
import '../services/flutter_storage.dart';

class KeyService{
  Future<SecretKey> generateKey() async{
    final algorithm = AesGcm.with256bits();
    final key = await algorithm.newSecretKey();
    return key;
  }
  Future<List<int>> getKeyBytes(SecretKey key)async{
    return await key.extractBytes();
  }
}
Future<void> main() async{
  final keyService = KeyService();
  final secretKey = await keyService.generateKey();
  final keyBytes = await keyService.getKeyBytes(secretKey);
  print('key bytes of the key: $keyBytes');

  await secureStorage.writeKey('user_key', keyBytes.join(','));

}
