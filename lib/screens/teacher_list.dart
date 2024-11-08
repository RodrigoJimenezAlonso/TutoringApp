import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'feedback_controller.dart';

class TeacherList extends StatefulWidget {
  const TeacherList({Key? key}) : super(key: key);

  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  double _minRating = 0.0;

  Future<List<Map<String, dynamic>>> _getFilteredTeacher() async {
    try{
      final response = await Supabase.instance.client
          .from('teachers')
          .select('*');
      final List<dynamic> teachers = response as List<dynamic>;
      final filteredTeachers = await Future.wait(teachers.map((teacher) async {
        final teacherId = teacher['id'];
        final averageRating = await FeedbackController.getAverageRating(teacherId);
        return averageRating >= _minRating?{
          'teacherId': teacherId,
          'name': teacher['name'],
          'averageRating': averageRating,
        }: null;
      }));
      return filteredTeachers.where((teacher) => teacher != null).cast<Map<String, dynamic>>().toList();
    }catch(e){
      print('Error fetching teachers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Filter by rating'),
                DropdownButton<double>(
                  value: _minRating,
                  items: [0, 3, 4, 5].map((rating) {
                    return DropdownMenuItem(
                      value: rating.toDouble(),
                      child: Text('$rating star'),
                    );
                  }).toList(),
                  onChanged: (newRating) {
                    if(newRating != null){
                      setState(() {
                        _minRating = newRating!;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getFilteredTeacher(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final teachers = snapshot.data!;
                return ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return ListTile(
                      title: Text(teacher['name']),
                      subtitle: Text('Average Rating: ${teacher['averageRating']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}