import 'package:cryptography/cryptography.dart';

Future<void> shareKey(String userId, SecretKey key)async{
  final keyBytes = await key.extractBytes();
}