import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<void> writeKey(String key, String value)async{
    try{
      await _storage.write(key: key, value: value);
    }catch(e){
      print('error writing key $key, $e');
      rethrow;
    }
  }
  Future<String?> readKey(String key)async{
    try{
      return await _storage.read(key: key);
    }catch(e){
      print('error reading key $key, $e');
      return null;
    }
  }
  Future<void> deleteKey(String key)async{
    try{
      await _storage.delete(key: key);
    }catch(e){
      print('error deleting key $key, $e');
      rethrow;
    }
  }
}

final secureStorage = SecureStorage();
Future<void> main()async{
  const key = 'user_key';
  try{
    await secureStorage.writeKey(key, 'some_secure_value');
    final keyBytes = await secureStorage.readKey(key);
    print('Storaged value: $keyBytes');
  }catch(e){
    print('error interacting with the Secure Storage: $e');
  }
}