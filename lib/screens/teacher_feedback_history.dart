import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'feedback_controller.dart';

class TeacherFeedbackHistory extends StatelessWidget{
  final String teacherId;
  const TeacherFeedbackHistory({
    Key? key, required this.teacherId
  }): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('My history'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: FeedbackController.getTeacherComments(teacherId),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final feedbackList = snapshot.data!;
            return ListView.builder(
                itemCount: feedbackList.length,
                itemBuilder: (context, index){
                  final feedback = feedbackList[index];
                  final rating = feedback['rating']?? 'No rating';
                  final comment = feedback['comment']?? 'No comment';
                  final timeStamp = feedback['timeStamp'] != null
                      ? DateFormat.yMd().add_Hm().format(DateTime.parse(feedback['timeStamp']))
                      : 'Unknown date';
                  return ListTile(
                    leading: Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    title: Text('Score: $rating'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(comment != null && comment.isNotEmpty)
                          Text('comment: $comment'),
                        Text('Date: $timeStamp'),

                      ],
                    ),
                  );
                },
            );
          },
      ),
    );
  }
}