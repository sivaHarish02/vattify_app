enum UserRole {
  ADMIN,
  FAMILY_MEMBER;

  static UserRole fromString(String value) {
    if (value == 'ADMIN') return UserRole.ADMIN;
    return UserRole.FAMILY_MEMBER;
  }

  String toJson() => name;
}

class UserModel {
  final int id;
  final String username;
  final String name;
  final UserRole role;
  final String? token;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.token,
  });

  bool get isAdmin => role == UserRole.ADMIN;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role.toJson(),
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? name,
    UserRole? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
