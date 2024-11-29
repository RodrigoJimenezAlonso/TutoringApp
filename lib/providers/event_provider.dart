import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  // Cargar eventos filtrados por el user_id del usuario autenticado
  Future<void> loadEvents() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT * FROM events',
      );

      _events = result.map((row) => Event.fromMap(row.fields)).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading events $e');
    }
  }

  // Agregar un nuevo evento con el user_id del usuario autenticado
  Future<void> addEvent(Event event) async {
    try {
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
      _events.add(event);
      notifyListeners();
    } catch (e) {
      print('Error adding events $e');
    }
  }
}
