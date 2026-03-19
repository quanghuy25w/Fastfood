class User {
  const User({
    this.id,
    required this.email,
    this.name,
    this.password,
    this.role = 'user', // 'user' hoace 'admin'
  });

  final int? id;
  final String email;
  final String? name;
  final String? password;
  final String role;

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      password: map['password']?.toString(),
      role: map['role']?.toString() ?? 'user',
    );
  }
}
