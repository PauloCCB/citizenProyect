class UserModel {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  String get fullName => '$name $lastName';

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? lastName,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
} 