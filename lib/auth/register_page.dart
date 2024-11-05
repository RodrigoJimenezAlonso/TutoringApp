import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../events.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget{
  @override
  _RegisterPageState createState()=> _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async{
    if(passwordController.text != confirmPasswordController.text){
      setState(() {
        errorMessage = 'Password does not match';
      });
      return;
    }
    try{
      final res = await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      if(res.user != null){
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder:(context)=> LoginPage()));
      }else{
        setState(() {
          errorMessage = 'Registration Failed, please try again';
        });
      }
    }catch(e){
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('REGISTER')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "please enter your email";
                      }else if(!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)){
                        return "please enter a valid email";
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "please enter your password";
                      }else if(value.length < 8){
                        return "please enter a longer password";
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password Controller'),
                    obscureText: true,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "please enter your password confirmation";
                      }else if(value != passwordController.text){
                        return "Password does not match";
                      }
                      return null;
                    }
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        signUp();
                      }
                    },
                    child: Text('Register')
                ),
                SizedBox(height: 10),
                if(errorMessage.isNotEmpty) Text(errorMessage, style: TextStyle(color: Colors.red)),
                TextButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('You do have an account! please log in Here')
                )

              ],
            ),
          )

      ),
    );
  }
}





