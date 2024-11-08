import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'feedback_controller.dart';
import '../screens/teacher_feedback_history.dart';

class TeacherProfile extends StatelessWidget{
  final String teacherId;

  const TeacherProfile({
    Key? key, required this.teacherId
  }): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Profile'),
      ),
      body: FutureBuilder<double>(
        future: FeedbackController.getAverageRating(teacherId),
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