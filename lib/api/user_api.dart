import 'package:recipe_app/common/values/server.dart';

import '../common/models/user_model.dart';
import '../common/net/init_dio.dart';

class UserApi {
  static Future<String?> authLogin(String username, String password) async {
    final response = await httpManager.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    if (response.code == 0) {
      logger.d("Login success ${response}");
      return response.data['access_token'];
    }
    return null;
  }

  static Future<UserInfo?> aboutMe() async {
    final response = await httpManager.get('/auth/me');
    if (response.code == 0) {
      logger.d("Get user info success ${response}");
      return UserInfo.fromJson(response.data);
    }
    return null;
  }

  static Future<String> signUp(SignUpUserInfo signUpInfo) async {
    final response = await httpManager.post('/auth/signup',data: signUpInfo.toJson());
    if (response.code == 0) {
      return "";
    }
    return response.message;
  }

  static Future<bool?> updateProfile(UserInfo profile) async {
    final response = await httpManager.post(
      '/auth/updateProfile',
      data: {
        'nickname': profile.nickname,
        'email': profile.email,
        'gender': profile.gender,
        'birthday': profile.birthday,
        'food_preferences':profile.foodPreferences,
      },
    );
    if (response.code == 0) {
      logger.d("Get user info success ${response}");
      return true;
    }
    return false;
  }
}