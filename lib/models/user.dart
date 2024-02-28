class User {
  final int id;
  final String username;
  final String telephone;
  final String actualName;
  final bool passwordModified;

  User(
      {required this.id,
      required this.username,
      required this.passwordModified,
      required this.telephone,
      required this.actualName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['name'],
      telephone: json['telephone'],
      actualName: json['actual_name'],
      passwordModified: json['password_modified'] == 1,
      id: json['id'],
    );
  }
}
