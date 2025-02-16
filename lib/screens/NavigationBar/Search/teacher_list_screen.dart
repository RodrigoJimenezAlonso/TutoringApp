import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import '../Profiles/teacherProfile/teacher_profile_screen.dart';
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
      '''
      SELECT 
        t.id, 
        t.name, 
        t.bio, 
        t.subject, 
        u.id AS user_id, 
        u.profile_picture 
      FROM teachers t 
      INNER JOIN users u on t.id= u.teacher_id 
      WHERE t.subject LIKE ?
      ''',
      ['%$subject%'],
    );
    await conn.close();

    return result.map((row){
      final fields = row.fields;
      return{
        'id': fields['id'],
        'user_id':fields['user_id'],
        'name': fields['name'] is Uint8List
            ? utf8.decode(fields['name'])
            : fields['name'].toString(),
        'bio': fields['bio'] is Uint8List
            ? utf8.decode(fields['bio'])
            : fields['bio'].toString(),
        'subject': fields['subject'] is Uint8List
            ? utf8.decode(fields['subject'])
            : fields['subject'].toString(),
        'profile_picture': fields['profile_picture'],
      };
    }).toList();
  }


  Future<int?> _fetchAlumnoId(int userId)async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT id FROM users WHERE id = ? AND role = ?',
      [userId, 'student'],
    );
    await conn.close();
    if(result.isNotEmpty){
      return result.first['id'] as int?;
    }
    return null;
  }

  Future<int?> getUserIdByEmail(String email)async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id FROM users WHERE email = ?',
        [email],
      );
      await conn.close();
      if(result.isNotEmpty){
        return result.first['id'] as int;
      }
      return null;
    }catch(e){
      print('Error al obtener el user_id: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Teachers For $subject', style: TextStyle(
          color: Colors.white,
        ),),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
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
        leading: teacher['profile_picture'] != null
            ? CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: MemoryImage(
            Uint8List.fromList((teacher['profile_picture'] as Blob).toBytes()),
          ),
        )
            : CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
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
        onTap: () async {
          final userID = await getUserIdByEmail('rodrigo2@gmail.com'); // todo: Obtener el userId dinámicamente
          if (userID != null) {
            final alumnoId = await _fetchAlumnoId(userID);
            if (alumnoId != null) {
              final teacherId = teacher['id'] is int ? teacher['id'] : int.tryParse(teacher['id'].toString()) ?? 0;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherCalendarScreen(
                    alumnoId: alumnoId,
                    teacherId: teacher['user_id'],
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: alumnoId no encontrado')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: userId no encontrado')),
            );
          }
        },
      ),
    );
  }

}