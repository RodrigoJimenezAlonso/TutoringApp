import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  final SupabaseClient _client = Supabase.instance.client;
  Future<void> insertEvent(Map<String, dynamic> event)async{
    final response = await _client
        .from('events')
        .insert(event);
    if(response.error != null){
      throw response.error!;
    }
  }
  Future<List<Map<String, dynamic>>> getAllEvents()async{
    final response = await _client
        .from('events');
    if(response.error != null){
      throw response.error!;
    }
    return List<Map<String, dynamic>>.from(response.data as List);
  }
  Future<void> updateEvent(String id, Map<String, dynamic> event )async{
    final response = await _client
        .from('events')
        .update(event)
        .eq('id', id);
    if(response.error != null){
      throw response.error!;
    }
  }

  Future<void> deleteEvent(String id)async{
    final response = await _client
        .from('events')
        .delete()
        .eq('id', id);
    if(response.error != null){
      throw response.error!;
    }
  }
}
