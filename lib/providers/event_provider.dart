import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EventProvider extends ChangeNotifier{
  List<Event> _events = [];
  List<Event> get events => _events;

  Future<void> loadEvents() async{
    final response = await Supabase.instance.client
      .from('events');
    //tenemos que cambiar select es deprecado
    if(response.error == null){
      _events = (response.data as List)
        .map((eventMap) => Event.fromMap(eventMap))
        .toList();
      notifyListeners();
    }else{
      print(response.error!.message);
    }
  }

  Future<void> addEvent(Event event) async{
    final response = await Supabase.instance.client
        .from('events')
        .insert(event.toMap());
    //tenemos que cambiar select es deprecado
    if(response.error == null){
      _events.add(event);
      notifyListeners();
    }else{
      print(response.error!.message);
    }
  }
}