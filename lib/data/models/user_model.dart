class User {
  const User({
    this.id,
    required this.email,
    this.name,
    this.password,
  });

  final int? id;
  final String email;
  final String? name;
  final String? password;

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString(),
      password: map['password']?.toString(),
    );
  }
}
