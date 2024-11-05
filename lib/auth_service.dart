import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient _client = Supabase.instance.client;

  Future<User?> signIn(String email, String password) async{
    try{
      final response = await _client.auth.signInWithPassword(
          email: email,
          password: password
      );
      if(response.user != null){
        return response.user;
      }else{
        print('error signing in');
        return null;
      }
    }catch(e){
      print('error: $e');
      return null;
    }
  }
  Future<void> signOut()async{
    try{
      await _client.auth.signOut();
      print('user singed out');
    }catch(e){
      print('error: $e');
    }
  }

  User? getCurrentUser(){
    return _client.auth.currentUser;
  }

  Future<User?> register(String email, String password)async{
    try{
      final response = await _client.auth.signUp(
          email: email,
          password: password,
      );
      if(response.user != null){
        return response.user;
      }else{
        print('error signing up');
        return null;
      }
    }catch(e){
      print('error: $e');
      return null;
    }
  }
}