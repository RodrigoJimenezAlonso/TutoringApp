import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart';
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
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchTeachers(subject),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return _buildLoadingEffect();
            }

            if(snapshot.hasError){
              return Center(
                child: Text(
                    'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final teachers = snapshot.data ?? [];

            if(teachers.isEmpty){
              return Center(
                child: Text(
                    'No teachers found for: $subject',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                ),
              );
            }

            return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: teachers.length,
                itemBuilder: (context, index){
                  final teacher = teachers[index];
                  return _buildTeacherCard(context, teacher);
                }
            );
          }
      ),
    );
  }

  Widget _buildLoadingEffect(){
    return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index){
          return Card(
            margin: EdgeInsets.symmetric(
              vertical: 8,
            ),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 25,
              ),
              title: Container(
                width: 150,
                height: 16,
                color: Colors.grey[300],
              ),
              subtitle: Container(
                width: 100,
                height: 12,
                color: Colors.grey[300],
                margin: EdgeInsets.only(top: 6),
              ),
            ),
          );
        }
    );
  }

  Widget _buildTeacherCard(BuildContext context, Map<String, dynamic> teacher){
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.person, color: Colors.white,),
        ),
        title: Text(
          teacher['name'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          teacher['bio'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey,),
        onTap: (){
          Navigator.push(
            context, MaterialPageRoute(
              builder: (context)=>TeacherCalendarScreen(
                  teacherId: teacher['id'],
              ),
            )
          );
        },
      ),
    );
  }

}