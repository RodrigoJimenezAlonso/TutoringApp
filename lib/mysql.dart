import 'package:mysql1/mysql1.dart';

class MySQLHelper{
  static Future<MySqlConnection> connect() async{
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: '127.0.0.1',
        port: 3306,
        user: 'tfg',
        password: '1234',
        db: 'tfg',
      )
    );
    return conn;
  }
}