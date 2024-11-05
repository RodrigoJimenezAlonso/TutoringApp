import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<void> writeKey(String key, String value)async{
    await _storage.write(key: key, value: value);
  }
  Future<String?> readKey(String key)async{
    return await _storage.read(key: key);
  }
  Future<void> deleteKey(String key)async{
    await _storage.delete(key: key);
  }
}
final secureStorage = SecureStorage();
Future<void> main()async{
  const key = 'user_key';
  await secureStorage.writeKey(key, 'some_secure_value');
  final keyBytes = await secureStorage.readKey(key);
  print('Storaged value: $keyBytes');
}