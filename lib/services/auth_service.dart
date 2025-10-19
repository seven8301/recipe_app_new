import 'package:flutter/foundation.dart';
import 'package:recipe_app/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // String? _token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNzU5OTc3NjQ5fQ.wxzEJyfJ0d7eFgCFlXB0AyqyueWIqJOELL939ufvwKM";
  bool _loggedIn = false;
  String? _token;
  bool get loggedIn => _loggedIn;
  String? get token => _token ;

  Future<void> load() async {
    _loggedIn =  false;
    notifyListeners();
  }

  Future<String?> getTokenForInterceptor() async {
    if (_token != null) {
      return _token;
    }
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    _loggedIn = _token != null;
    return _token;
  }

  Future<String?> login(String username, String password) async {
    final token = await UserApi.authLogin(username, password);
    if (token == null) {
      return "Invalid username or password";
    }
    _loggedIn = true;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('loggedIn', true);
    await sp.setString('token', token);
    notifyListeners();
    return "";
  }

  Future<void> logout() async {
    _loggedIn = false;
    _token = null;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('loggedIn', false);
    await sp.setString('token', '');
    notifyListeners();
  }
}