
class User {
  int userId;
  String userName;

  User({
    this.userId,
    this.userName,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
        userId: json['id'],
        userName: json['username']
    );
  }
}
