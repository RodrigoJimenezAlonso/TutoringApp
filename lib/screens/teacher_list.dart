import 'dart:math';
import 'package:proyecto_rr_principal/mysql.dart';
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
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id,name FROM teachers'
      );
      final teachers = <Map<String, dynamic>> [];
      for(var row in result){
        final teacherId  = row['id'];
        final name  = row['name'];
        final averageRating = await _getAverageRating(teacherId);
        if(averageRating >= _minRating){
          teachers.add
          ({
            'teacherId': teacherId,
            'name': name,
            'averageRating': averageRating,
          });
        }
      }
      await conn.close();
      return teachers;
      }catch(e){
        print('Error fetching teachers: $e');
        return [];
    }
  }

  Future<double> _getAverageRating(int teacherId) async{
    final conn = await MySQLHelper.connect();
    final results  = await conn.query(
      'SELECT AVG(rating) AS averageRating FROM feedback WHERE teacherId = ?',
      [teacherId]
    );
    await conn.close();
    if(results.isNotEmpty){
      return results.first['averageRating'] ?? 0.0;
    }
    return 0.0;
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