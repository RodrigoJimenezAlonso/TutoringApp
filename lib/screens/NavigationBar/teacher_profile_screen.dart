import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/screens/chat_screen.dart'; // Añadido para la pantalla del chat
import 'message_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  final Map<String, dynamic> teacher;

  TeacherProfileScreen({
    required this.teacher,
  });

  Future<int?> getStudentId() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id FROM users WHERE role = ? LIMIT 1',
        [
          'student'
        ],
      );
      if (result.isEmpty) {
        return null;
      }
      final student = result.first;
      await conn.close();
      return student['id'];
    } catch (e) {
      print('Error obteniendo student Id: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStudentData() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id, role FROM users WHERE role = ? LIMIT 1',
        [
          'student'
        ],
      );
      if (result.isEmpty) {
        return null;
      }
      final student = result.first.fields;
      await conn.close();
      return {
        'id': student['id'],
        'role': 'Student',
      };
    } catch (e) {
      print('Error obteniendo student Id: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          teacher['name'],
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[700],
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              teacher['name'],
              style: TextStyle(
                color: Colors.blue[800],
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
                color: Colors.grey[800],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      teacher['bio'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.chat),
              label: Text('Contact the Teacher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                final studentData = await getStudentData();
                if (studentData == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error, no se encontró al alumno...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      alumnoId: studentData['id'],
                      profesorId: teacher['id'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}