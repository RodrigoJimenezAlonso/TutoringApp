import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import '../../../providers/user_provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'teacher_calendar_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/teacherProfile/teacher_profile_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';



class TeacherListScreen extends StatefulWidget {
  final String subject;
  final String userEmail;

  TeacherListScreen({
    required this.subject,
    required this.userEmail,
  });

  @override
  _TeacherListScreenState createState() => _TeacherListScreenState();

}

class _TeacherListScreenState extends State<TeacherListScreen>{

  int? userId;

  @override
  void initState(){
    super.initState();
    _loadUserIdFromMySql();

  }

  Future<void> _loadUserIdFromMySql()async{

    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      '''
      SELECT id FROM users WHERE email = ? AND role  = "student"
      ''',
      [widget.userEmail],
    );
    await conn.close();

    if(result.isNotEmpty){
      setState(() {
        userId = result.first['id'] as int?;
      });
    }

  }


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
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Teachers For ${widget.subject}', style: TextStyle(
          color: Colors.white,
        ),),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode == true ? Colors.black : Colors.blue[800],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchTeachers(widget.subject),
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
                    'No teachers found for: ${widget.subject}',
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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userID = userProvider.userId;
    final userRole = userProvider.role;
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);


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
            color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey[700],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey,),
        onTap: () async {
          if (userID != null) {
            final alumnoId = userID;

            if (alumnoId != null) {

              final teacherId = teacher['id'] is int ? teacher['id'] : int.tryParse(teacher['id'].toString()) ?? 0;

              final conn = await MySQLHelper.connect();
              final result = await conn.query(
                  'SELECT id FROM users WHERE teacher_id = ?',
                  [
                    teacherId
                  ]
              );
              await conn.close();

              final idTeacherUser = (result.isNotEmpty && result.first.fields['id'] != null)
                  ? int.tryParse(result.first.fields['id'].toString()) ?? 0
                  : 0;

              print('teacher id: $teacherId and studentID: $alumnoId');
              print('UserId del estudiante: $userID y el TeacherId del profesor ${teacher['user_id']} ');
              Navigator.push(
                context,
                /*MaterialPageRoute(
                  builder: (context) => TeacherProfileScreen(
                      teacherId: teacherId,
                      studentId: alumnoId
                  ),
                ),*/
                MaterialPageRoute(
                  builder: (context) => TeacherProfileScreen(
                      teacherId: idTeacherUser,
                      studentId: alumnoId
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