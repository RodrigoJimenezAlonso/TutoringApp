import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proyecto_rr_principal/mysql.dart';
class FeedbackController{
  static Future<void> submitFeedback(String teacherId, String studentId, double rating, String comment) async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        '''
        INSERT INTO feedback (teacherId, studentId, rating, comment, timeStamp)
        VALUES(?,?,?,?,?)
        ''',
        [
          teacherId,
          studentId,
          rating,
          comment,
          DateTime.now().toIso8601String(),
        ]
      );
    }catch(e){
      print('Error submiting the feedback: $e');
      rethrow;
    }
  }

  static Future<double> getAverageRating(String teacherId) async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          '''
          SELECT AVG(rating) AS averageRating
          FROM feedback WHERE teacherId = ?
          ''',
          [teacherId],
      );
      if(result.isNotEmpty && result.first['averageRating'] != null){
        return result.first['averageRating'] as double;
      }else{
        return 0.0;
      }
    }catch(e){
      print('error fetching feedback: $e');
      return 0.0;
    }
  }

  static Future<List<Map<String, dynamic>>> getTeacherComments(String teacherId) async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        '''
          SELECT id , teacherId, studentId, rating, comment, timeStamp
          FROM feedback WHERE teacherId = ? 
          ORDER BY timeStamp DESC
          ''',
        [teacherId],
      );
      return result.map((row)=> {
        'id': row['id'],
        'teacherId': row['teacherId'],
        'studentId': row['studentId'],
        'rating': row['rating'],
        'comment': row['comment'],
        'timeStamp': row['timeStamp'],
      }).toList();
    }catch(e){
      print('error fetching teacher comments: $e');
      return [];
    }
  }
}