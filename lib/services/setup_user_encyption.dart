import 'key_service.dart';

Future<void> setupUserEncryption() async{
  final keyService = KeyService();
  final key = await keyService.generateKey();
}