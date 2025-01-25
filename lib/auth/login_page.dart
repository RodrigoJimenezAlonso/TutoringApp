import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/widget/home_page.dart';
import '../auth/register_page.dart';
import '../events.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (!_formKey.currentState!.validate()) return;

    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT id, password_hash, teacher_id FROM users WHERE email = ?',
        [emailController.text.trim()],
      );

      if (result.isEmpty) {
        setState(() {
          errorMessage = 'Invalid email or password';
        });
        return;
      }

      final user = result.first;
      final passwordHash = user['password_hash'];
      if (!BCrypt.checkpw(passwordController.text.trim(), passwordHash)) {
        setState(() {
          errorMessage = 'Invalid email or password';
        });
        return;
      }

      final userId = user['id'];
      final profesorId = user['teacher_id'] ?? 0;
      final role = user['role'] ?? 'student';

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setInt('userId', userId);

      Provider.of<UserProvider>(context, listen: false).setUserId(userId);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            userID: userId,
            alumnoId: userId,
            profesorId: profesorId,
            role: role,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Login With Your Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email,color: Colors.blue,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              )
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 7,),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock,color: Colors.blue,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              )
                          ),
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
                        /*SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signIn();
                            }
                          },
                          child: Text('Log In'),
                        ),*/
                        SizedBox(height: 20),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 80,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'LogIn',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                        ),
                        SizedBox(height: 10,),
                        TextButton(
                            onPressed: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context)=> RegisterPage()
                                )
                              );
                            },
                            child: Text(
                                'If you do not have an account, Register Here!',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}