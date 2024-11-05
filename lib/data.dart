import 'services/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Data {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String baseUrl = '';

  Future<List<Map<String, dynamic>>> getAllEvents()async{
    try{
      return await _dbHelper.getAllEvents();
    }catch(e){
      print('error events: $e');
      return [];
    }

  }
 Future<void> addEvent(Map<String, dynamic> event)async{
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8'
      },
      body: json.encode(event),
    );
  }

  Future<void> updateEvent(String id, Map<String, dynamic> event) async{
    try{
      await _dbHelper.updateEvent(id, event);
    }catch(e){
      print('error events: $e');
    }
  }
  Future<void> deleteEvent(String id) async{
    await _dbHelper.deleteEvent(id);
    try{
      await _dbHelper.deleteEvent(id);
    }catch(e){
      print('error events: $e');
    }
  }

}

