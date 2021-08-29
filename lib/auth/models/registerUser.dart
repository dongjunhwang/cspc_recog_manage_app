import 'package:cspc_recog_manage/auth/models/user.dart';

class RegisterUser {
  User user;
  String token;

  RegisterUser({
    this.user,
    this.token,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}
