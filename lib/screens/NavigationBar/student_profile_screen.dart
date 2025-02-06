import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:bcrypt/bcrypt.dart';


class StudentProfileScreen extends StatefulWidget {
  final int studentId;
  StudentProfileScreen({
    required this.studentId,
});

  @override
  _StudentProfileScreenState createState()=> _StudentProfileScreenState();

}

class _StudentProfileScreenState extends State<StudentProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState(){
    super.initState();
    _loadStudentData();
  }

  Future<void>_loadStudentData()async{
    try{
      final conn = await MySQLHelper.connect();
      if(conn == null){
        throw Exception('Cannot connect to database');
      }
      final result = await conn.query(
        'SELECT username, email FROM users WHERE id = ?',
        [
          widget.studentId,
        ],
      );

      if(result.isEmpty){
        throw Exception('No se encontro el estudiante con el id dado');
      }
      final data = result.first;
      setState(() {
        _nameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
      });
    }catch(e){
      print('Error loading student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading Student Data: $e'),
          backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _updateProfile() async {

    if(!_formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      final conn = await MySQLHelper.connect();
      String? passwordHash;

      if (_passwordController.text.trim().isNotEmpty) {
        passwordHash = BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());
      }

      String query = 'UPDATE users SET username = ?, email = ?';

      List<dynamic> params = [
        _nameController.text.trim(),
        _emailController.text.trim(),
      ];
      if(passwordHash != null){
        query += ',password_hash = ?';
        params.add(passwordHash);
      }
      query += ' WHERE id = ?';
      params.add(widget.studentId);

      await conn.query(query,params);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile Updated Successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Error updating student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating Student Data'),
        backgroundColor: Colors.red,
      ));
    }finally{
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _validateName(String? value){
    if(value == null || value.isEmpty){
      return 'Name can not be empty';
    }

    if(value.length < 3){
      return 'Name needs to have at least 3 characters';
    }

    return null;
  }

  String? _validateEmail(String? value){
    if(value == null || value.isEmpty){
      return 'Email can not be empty';
    }

    if(!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)){
      return 'Type a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value){
    if(value != null && value.isNotEmpty && value.length < 6){
      return 'Password needs to have at least 6 characters';
    }
    return null;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                ),
                validator: _validateName,
              ),
              SizedBox(height: 10,),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Change Password (OPTIONAL)',
                  border: OutlineInputBorder(),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                ),
                validator: _validatePassword,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _isSubmitting? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
                child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white,)
                  : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              )
            ],
          ),
        ),

      )
    );
  }
}