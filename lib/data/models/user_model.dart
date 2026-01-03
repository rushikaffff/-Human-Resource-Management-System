class User {
  final String id;
  final String email;
  final String role;
  final String token;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Employee',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'token': token,
    };
  }
}
