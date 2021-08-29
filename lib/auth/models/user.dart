class User {
  int userId;
  String userName;

  User({
    required this.userId,
    required this.userName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(userId: json['id'], userName: json['username']);
  }
}
