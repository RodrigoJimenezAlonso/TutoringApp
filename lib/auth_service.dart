import 'mysql.dart';

class AuthService{

  Future<Map<String, dynamic>?> login(String email, String password) async{
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT * FROM users WHERE email = ? AND password = ?',
        [
          email,
          password
        ],
      );
      if(result.isEmpty){
        await conn.close();
        return null;
      }
      final user = result.first;
      await conn.close();
      return {
        'id': user['id'],
        'email': user['email'],
      };
    }
    catch(e){
      print('Error LOGIN: $e');
      return null;
    }
  }

  /*Future<void> signOut()async{
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
  }*/
}