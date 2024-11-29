import 'package:flutter/material.dart';
import '../auth/register_page.dart';
import '../events.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id, password_hash FROM users WHERE email = ?',
        [emailController.text.trim()]
      );

      if(result.isEmpty){
        setState(() {
          errorMessage = 'Invalid email or password';
        });
        return;
      }
      final user = result.first;
      final passwordHash = user['password_hash'];
      if(!BCrypt.checkpw(passwordController.text.trim(), passwordHash)){
        setState(() {
          errorMessage = 'Invalid email or password';
        });
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context)=> EventsController()
        ),
      );
    }catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LOGIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  } else if (value.length < 8) {
                    return "Please enter a longer password";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signIn();
                  }
                },
                child: Text('Log In'),
              ),
              SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('You do not have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
