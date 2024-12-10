import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mysql.dart';

class Data {
  final String baseUrl = '';

  Future<List<Map<String, dynamic>>> getAllEvents()async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT * FROM events',
      );
      final List<Map<String, dynamic>> events = result
        .map((row)=> Map<String, dynamic>.from(row.fields))
        .toList();
      await conn.close();
      return events;
    }
    catch(e){
      print('Could not get all events: $e');
      return [];
    }

  }
 Future<void> addEvent(Map<String, dynamic> event)async{
   try{
     final conn = await MySQLHelper.connect();
     await conn.query(
       'INSERT INTO events(name, date, location) VALUES(?,?,?)',
       [
         event['name'],
         event['date'],
         event['location'],
       ]
     );
     await conn.close();
   }
   catch(e){
     print('Could not add event: $e');
   }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> event) async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
          'UPDATE events SET name = ?, date = ?, location = ? WHERE id = ?',
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
      print('Could not update event: $e');
    }
  }


  Future<void> deleteEvent(String id) async{
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
      print('Could not delete event: $e');
    }
  }

}

