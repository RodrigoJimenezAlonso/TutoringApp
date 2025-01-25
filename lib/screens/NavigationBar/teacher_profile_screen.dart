import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'message_screen.dart';

class TeacherProfileScreen extends StatelessWidget{
  final Map<String, dynamic> teacher;

  TeacherProfileScreen({
    required this.teacher,
  });
  Future<int?> getStudentId()async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT id FROM users WHERE role = ? LIMIT 1',
          [
            'student'
          ],
      );
      if(result.isEmpty){
        return null;
      }
      final student = result.first;
      await conn.close();
      return student['id'];
    }catch(e){
      print('Error obteniendo student Id: $e');
      return null;
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(teacher['name']),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Subject: ${teacher['subject']}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Text(
                'Bio: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                teacher['bio'],
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              Spacer(),

              Center(
                child: ElevatedButton(
                    onPressed: ()async{
                      final studentId = await getStudentId();
                      if(studentId == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error, no se encontro al alumno...'),
                            )
                        );
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context)=> MessageScreen(
                                  alumnoId: studentId,
                                  professorId: teacher['id'],
                              )
                          ),
                      );
                    },
                    child: Text('Contact the Teacher'),
                ),
              ),
            ],
          ),
      ),
    );
  }
}