import 'package:mysql1/mysql1.dart';

class MySQLHelper{
  static Future<MySqlConnection> connect() async{
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: '10.0.2.2',
        port: 3306,
        user: 'root',
        password: 'password',
        db: 'tfg_database',
      )
    );
    return conn;
  }
}