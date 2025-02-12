import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  final UserProvider userProvider;
  EventProvider({
    required this.userProvider,
});
  List<Event> get events => _events;

  // Cargar eventos filtrados por el user_id del usuario autenticado
  Future<void> loadEvents() async {
    try {
      final conn = await MySQLHelper.connect();
      final userId = userProvider.userId;
      final role = userProvider.role;
      if(userId == null || role == null){
        print('User id or role is null in event provider');
        return;
      }

      String query  = "SELECT id, title, description, "
          "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS start_time,"
          "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS end_time "
          "FROM events WHERE user_id = ?";

      if (role == 'teacher') {
        query = "SELECT id, title, description, "
            "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS start_time,"
            "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS end_time "
            "FROM events WHERE user_id = ?";
      } else if (role == 'student') {
        query = "SELECT id, title, description, "
            "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS start_time,"
            "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS end_time "
            "FROM events WHERE user_id = ?";
      }
      final result = await conn.query(query, [userId]);
      _events = result.map((row){
        return Event(
          id: row['id'] ?? 0,
          title: row['title']?.toString() ?? 'No Title',
          description: row['description']?.toString() ?? 'No description',
          startTime: DateTime.tryParse(row['start_time']?.toString() ?? '') ?? DateTime.now(),
          endTime: DateTime.tryParse(row['end_time']?.toString() ?? '') ?? DateTime.now(),
          userId: '',//todo, poner userID
        );
      }).toList();

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
