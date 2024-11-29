import 'package:flutter/foundation.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  //final String userId; // Campo para el user_id

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    //required this.userId, // Inicializa el user_id
  });

  factory Event.fromMap(Map<String, dynamic> map){
    return Event(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        startTime: DateTime.parse(map['start_time']),
        endTime: DateTime.parse(map['end_time']),
        //userId: userId
    );
  }

  // Convierte el evento a un Map para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      //'user_id': userId, // Incluye el user_id en el Map
    };
  }

  static Future<List<Event>> fetchEvents() async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT * FROM events',
    );
    return result.map((row){
      return Event.fromMap(row.fields);
    }).toList();
  }

  static Future<void> addEvents(Event event) async{
    final conn = await MySQLHelper.connect();
    await conn.query(
      'INSERT INTO events(id, title, description, start_time, end_time) VALUES(?,?,?,?,?)',
      [
        event.id,
        event.title,
        event.description,
        event.startTime.toIso8601String(),
        event.endTime.toIso8601String(),
      ]
    );
  }

}
