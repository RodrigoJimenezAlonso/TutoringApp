import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StudentProfileScreen extends StatefulWidget {
  final int studentId;
  StudentProfileScreen({required this.studentId});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String _name = "";
  String _email = "";
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final conn = await MySQLHelper.connect();
      if (conn == null) throw Exception('Cannot connect to database');

      final result = await conn.query(
        'SELECT username, email, profile_picture FROM users WHERE id = ?',
        [widget.studentId],
      );

      if (result.isEmpty) throw Exception('No se encontró el estudiante con el ID dado');

      final data = result.first;
      setState(() {
        _name = data['username'] ?? '';
        _email = data['email'] ?? '';

        final blobData = data['profile_picture'];
        if (blobData != null && blobData is Blob) {
          imageBytes = Uint8List.fromList(blobData.toBytes());
        } else {
          imageBytes = null;
        }
      });
    } catch (e) {
      print('Error loading student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Student Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
              child: imageBytes == null ? Icon(Icons.person, size: 80, color: Colors.grey) : null,
            ),
            SizedBox(height: 20),
            Text(
              _name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _email,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30,),
                  Icon(Icons.lock, color: Colors.black, size: 20),
                  SizedBox(height: 5), // Espacio entre el texto y el icono
                  Text(
                    "Student Data are Secured End to End",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
