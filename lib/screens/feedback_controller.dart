import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackController{
  static Future<void> submitFeedback(String teacherId, String studentId, double rating, String comment) async{
    try{
      final feedback = {
        'teacherId': teacherId,
        'studentId': studentId,
        'rating': rating,
        'comment': comment,
        'timeStamp':DateTime.now().toIso8601String(),
      };
      await Supabase.instance.client.from('feedback').insert(feedback);
    }catch(e){
      print('Error saving the feedback: $e');
    }
  }

  static Future<double> getAverageRating(String teacherId) async{
    try{
      final response = await Supabase.instance.client
          .from('feedback')
          .select('rating')
          .eq('teacherId', teacherId);
      final List<dynamic> ratings = response ?? [];
      if(ratings.isEmpty){
        return 0.0;
      }
      double totalRating = ratings.fold(0, (sum,rating)=> sum + (rating['rating'] ?? 0.0));
      return totalRating/ratings.length;
    }catch(e){
      print('error fetching feedback: $e');
      return 0.0;
    }
  }

  static Future<List<Map<String, dynamic>>> getTeacherComments(String teacherId) async{
    try{
      final response = await Supabase.instance.client
          .from('feedback')
          .select('*')
          .eq('teacherId', teacherId)
          .order('timeStamp' , ascending: false);
      return List<Map<String, dynamic>>.from(response ?? []);
    }catch(e){
      print('error fetching teacher comments: $e');
      return [];
    }

  }
}