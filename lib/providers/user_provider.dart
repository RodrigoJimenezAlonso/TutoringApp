import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier{
  int? _userId;
  int? get userId => _userId;

  String? _role;
  String? get role => _role;

  void setUserId(int id, String role){
    _userId = id;
    _role = role;
    notifyListeners();
  }

  void clearUserId(){
    _userId = null;
    _role = null;
    notifyListeners();
  }


}