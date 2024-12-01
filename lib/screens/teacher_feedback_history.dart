import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'feedback_controller.dart';

class TeacherFeedbackHistory extends StatelessWidget{
  final String teacherId;
  const TeacherFeedbackHistory({
    Key? key, required this.teacherId
  }): super(key: key);

  Future<List<Map<String, dynamic>>> _getTeacherComment()async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT rating, comment, timeStamp FROM feedbacks WHERE teacherId = ? ',
          [teacherId]
      );
      await conn.close();
      return result.map((row)=>{
        'rating': row['rating'],
        'comment': row['comment'],
        'timeStamp': row['timeStamp']?.toString(),
      }).toList();
    }catch(e){
      print('Error fetching feedback');
      return [];
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('My history'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getTeacherComment(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(snapshot.hasError){
              return Center(
                child: Text(
                  'error fetching feedback ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            final feedbackList = snapshot.data ?? [];
            if(feedbackList.isEmpty){
              return const Center(child: Text('No feedback available'),);
            }
            return ListView.separated(
                itemCount: feedbackList.length,
                separatorBuilder: (_,__)=> const Divider(),
                itemBuilder: (context, index){
                  final feedback = feedbackList[index];
                  final rating = feedback['rating']?? 'No rating';
                  final comment = feedback['comment']?? 'No comment';
                  final timeStamp = feedback['timeStamp'] != null
                      ? DateFormat.yMd().add_Hm().format(DateTime.parse(feedback['timeStamp']))
                      : 'Unknown date';
                  return ListTile(
                    leading: const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    title: Text('Score: $rating'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(comment.isNotEmpty)
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