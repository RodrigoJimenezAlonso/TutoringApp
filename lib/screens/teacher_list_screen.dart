import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'NavigationBar/teacher_profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'teacher_calendar_screen.dart';

class TeacherListScreen extends StatelessWidget{
  final String subject;

  TeacherListScreen({
    required this.subject,
  });

  Future<List<Map<String, dynamic>>> _fetchTeachers(String subject) async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT id, name, bio, subject FROM teachers WHERE subject LIKE ?',
      ['%$subject%'],
    );
    await conn.close();

    return result.map((row){
      final fields = row.fields;
      return{
        'id': fields['id'],
        'name': fields['name'] is Uint8List
            ? utf8.decode(fields['name'])
            : fields['name'].toString(),
        'bio': fields['bio'] is Uint8List
            ? utf8.decode(fields['bio'])
            : fields['bio'].toString(),
        'subject': fields['subject'] is Uint8List
            ? utf8.decode(fields['subject'])
            : fields['subject'].toString(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Teachers For $subject'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchTeachers(subject),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if(snapshot.hasError){
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final teachers = snapshot.data!;

            if(teachers.isEmpty){
              return Center(
                child: Text('No teachers found for: $subject'),
              );
            }

            return ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index){
                  final teacher = teachers[index];
                  return ListTile(
                    title: Text(teacher['name']),
                    subtitle: Text(teacher['bio']),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context)=> TeacherCalendarScreen(teacherId: teacher['id'])
                          ),
                      );
                    },
                  );
                }
            );
          }
      ),
    );
  }

}