import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  List<Event> get events => _events;

  // Cargar eventos filtrados por el user_id del usuario autenticado
  Future<void> loadEvents() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('user_id', user.id); // Filtra eventos por user_id del usuario autenticado

    if (response != null && response is List) {
      _events = response.map((eventMap) => Event.fromMap(eventMap)).toList();
      notifyListeners();
    } else {
      print("Error al cargar eventos o respuesta inesperada.");
    }
  }

  // Agregar un nuevo evento con el user_id del usuario autenticado
  Future<void> addEvent(Event event) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    final response = await Supabase.instance.client
        .from('events')
        .insert(event.toMap());

    if (response.error == null) {
      _events.add(event);
      notifyListeners();
    } else {
      print(response.error!.message);
    }
  }
}
