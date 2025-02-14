import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/StudentProfile/student_profile_screen.dart';
import 'package:proyecto_rr_principal/widget/home_page.dart';


class EditTeacherProfileScreen extends StatefulWidget {
  final int teacherId;
  EditTeacherProfileScreen({required this.teacherId});

  @override
  _EditTeacherProfileScreenState createState() => _EditTeacherProfileScreenState();
}

class _EditTeacherProfileScreenState extends State<EditTeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isSubmitting = false;
  String subject = '';
  String bio = '';

  File? _image;
  Uint8List? imageBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _loadTeacherInfo();
  }

  Future<void> _loadTeacherInfo()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT name, subject, bio FROM teachers WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
        [
          widget.teacherId
        ]
    );
    await conn.close();
    if(result.isNotEmpty){
      setState(() {
        _subjectController.text = result.first['subject'].toString();
        _bioController.text = result.first['bio']?.toString() ?? '';
      });
    }
  }

  Future<void> _loadStudentData() async {
    try {
      final conn = await MySQLHelper.connect();
      if (conn == null) throw Exception('Cannot connect to database');

      final result = await conn.query(
        'SELECT username, email, profile_picture FROM users WHERE id = ?',
        [widget.teacherId],
      );

      if (result.isEmpty) throw Exception('No se encontró el estudiante con el ID dado');

      final data = result.first;
      setState(() {
        _nameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';

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


  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final conn = await MySQLHelper.connect();
      String? passwordHash;

      if (_passwordController.text.trim().isNotEmpty) {
        passwordHash = BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());
      }

      if (_image != null) {
        imageBytes = await _image!.readAsBytes();
      }

      String query = 'UPDATE users SET username = ?, email = ?';
      List<dynamic> params = [
        _nameController.text.trim(),
        _emailController.text.trim(),
      ];

      if (passwordHash != null) {
        query += ', password_hash = ?';
        params.add(passwordHash);
      }

      if (imageBytes != null) {
        query += ', profile_picture = ?';
        params.add(imageBytes);
      }

      query += ' WHERE id = ?';
      params.add(widget.teacherId);

      await conn.query(query, params);

      await conn.query(
          'UPDATE teachers SET subject = ?, bio = ? WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
          [
            _subjectController.text.trim(),
            _bioController.text.trim(),
            widget.teacherId
          ]
      );

      await _loadTeacherInfo();
      await conn.close();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Updated Successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error updating student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Updating The Profile'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageBytes = _image!.readAsBytesSync();
      });
    }
  }

  Future<void> _deleteProfilePicture()async{
    try{
      final conn  = await MySQLHelper.connect();
      if(conn == null){
        throw Exception('Cannot connect to DB');
      }
      await conn.query(
          'UPDATE users SET profile_picture = null WHERe id = ?',
          [widget.teacherId]
      );
      setState(() {
        imageBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Picture DELETED'),
            backgroundColor: Colors.red,
          )
      );
    }catch(e){
      print('Error deleting PHOTO: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting image'),
            backgroundColor: Colors.red,
          )
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'El nombre no puede estar vacío';
    if (value.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    return null;
  }


  String? _validateSubject(String? value) {
    if (value == null || value.isEmpty) return 'El nombre no puede estar vacío';
    if (value.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    return null;
  }


  String? _validateBio(String? value) {
    if (value == null || value.isEmpty) return 'El nombre no puede estar vacío';
    if (value.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email no puede estar vacío';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Edit Teacher Profile', style: TextStyle(
            color: Colors.white
        ),),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            onPressed: _logOut,
            icon: Icon(Icons.logout, color: Colors.white,),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.blue,
                      backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
                      child: imageBytes == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    if (imageBytes != null)
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          padding: EdgeInsets.all(0), // Ajusta el tamaño del círculo
                          child: IconButton(
                            onPressed: _deleteProfilePicture,
                            icon: Icon(Icons.delete, color: Colors.white, size: 30,),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: _validateSubject,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Biography',
                  border: OutlineInputBorder(),
                ),
                validator: _validateBio,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Change password (Optional)',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateProfile,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}