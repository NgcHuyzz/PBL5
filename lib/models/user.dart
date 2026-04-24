class User {
  final String username;
  final String email;
  final String fullName;
  final String status;

  User({
    required this.username,
    required this.email,
    required this.fullName,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}