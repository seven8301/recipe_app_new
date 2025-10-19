class UserInfo {
  String nickname;
  String email;
  String gender;
  String birthday;
  int userRecipeCount;
  int userIngredientCount;
  int userCollectRecipeCount;
  String foodPreferences;

  UserInfo({
    required this.nickname,
    required this.email,
    required this.gender,
    required this.birthday,
    required this.userRecipeCount,
    required this.userIngredientCount,
    required this.userCollectRecipeCount,
    required this.foodPreferences,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    return UserInfo(
      nickname: safeString(json['nickname']),
      email: safeString(json['email']),
      gender: safeString(json['gender']),
      birthday: safeString(json['birthday']),
      userRecipeCount: safeInt(json['user_recipe_count']),
      userIngredientCount: safeInt(json['user_ingredient_count']),
      userCollectRecipeCount: safeInt(json['user_collect_recipe_count']),
      foodPreferences: safeString(json['food_preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nickname'] = nickname;
    data['email'] = email;
    data['gender'] = gender;
    data['birthday'] = birthday;
    data['user_recipe_count'] = userRecipeCount;
    data['user_ingredient_count'] = userIngredientCount;
    data['user_collect_recipe_count'] = userCollectRecipeCount;
    data['food_preferences'] = foodPreferences;
    return data;
  }

  @override
  String toString() {
    return 'UserInfo(nickname: $nickname, email: $email, gender: $gender, birthday: $birthday, userRecipeCount: $userRecipeCount, userIngredientCount: $userIngredientCount)';
  }
}

class SignUpUserInfo {
  final String username;
  final String nickname;
  final String email;
  final String password;
  final String gender;
  final String birthday;
  final List<String> foodPreferences;

  SignUpUserInfo({
    required this.username,
    required this.nickname,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthday,
    required this.foodPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nickname': nickname,
      'email': email,
      'password': password,
      'gender': gender,
      'birthday': birthday,
      'food_preferences': foodPreferences,
    };
  }

}