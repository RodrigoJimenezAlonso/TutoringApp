import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter/material.dart';
import 'feedback_controller.dart';
import '../screens/teacher_feedback_history.dart';

class TeacherProfile extends StatelessWidget{
  final String teacherId;

  const TeacherProfile({
    Key? key, required this.teacherId
  }): super(key: key);

  Future<double> _getAverageRating(String teacherId) async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT AVG(rating) AS averageRating FROM feedbacks WHERE teacherId = ?',
          [
            teacherId
          ],
      );
      final row = result.first;
      final averageRating = row["averageRating"] ?? 0.0;
      await conn.close();
      return averageRating;
    }
    catch(e){
      print('error fetching Average Rating: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Profile'),
      ),
      body: FutureBuilder<double>(
        future: _getAverageRating(teacherId),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          final averageRating = snapshot.data?? 0.0;
          return Column(
            children: [
              Text('Average Rating: $averageRating stars'),
              ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=> TeacherFeedbackHistory(
                                teacherId: teacherId,
                            ),
                        ),
                    );
                  },
                  child: Text('Check feedbacks history'),
              )
            ],
          );
         /* ElevatedButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context)=> TeacherFeedbachHistory(
                          teacherId: teacherId
                      )
                  ),
              ),
            },
          );*/
        },
      ),
    );
  }
}