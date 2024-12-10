import 'package:proyecto_rr_principal/mysql.dart';

class DatabaseHelper {
  Future<void> insertEvent(Map<String, dynamic> event) async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'INSERT INTO events(id, name, date, location) VALUES(?,?,?,?)',
        [
          event['id'],
          event['name'],
          event['date'],
          event['location'],
        ],
      );
      await conn.close();
    }
    catch(e){
      throw Exception('Could not insert the event: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getAllEvents()async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT * FROM events',
      );
      await conn.close();
      return result.map((row)=> row.fields as Map<String, dynamic>).toList();
    }
    catch(e){
      throw Exception('Could not get all the event: $e');
    }
  }


  Future<void> updateEvent(String id, Map<String, dynamic> event )async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'UPDATE events SET name = ?, date = ?, location = ?  WHERE id = ?',
        [
          event['name'],
          event['date'],
          event['location'],
          id,
        ],
      );
      await conn.close();
    }
    catch(e){
      throw Exception('Could not update the event: $e');
    }
  }

  Future<void> deleteEvent(String id)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'DELETE FROM events WHERE id = ?',
        [
          id
        ],
      );
      await conn.close();
    }
    catch(e){
      throw Exception('Could not delete the event: $e');
    }
  }
}
