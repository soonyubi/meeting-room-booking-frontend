class LoginDto {
  final String employeeNumber;
  final String password;

  LoginDto({required this.employeeNumber, required this.password});

  Map<String, dynamic> toJson() {
    return {'employeeNumber': employeeNumber, 'password': password};
  }

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      employeeNumber: json['employeeNumber'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class LoginResponseDto {
  final String accessToken;
  final User user;

  LoginResponseDto({required this.accessToken, required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['accessToken'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String employeeNumber;
  final String name;

  User({required this.id, required this.employeeNumber, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      employeeNumber: json['employeeNumber'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
