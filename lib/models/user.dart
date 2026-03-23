class User {
  final int id;
  final String email;
  final String name;
  final String role;
  /// JSON địa chỉ ([Address.toJson]) hoặc chuỗi cũ.
  final String address;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'user',
    this.address = '',
  });

  bool get isAdmin => role == 'admin';

  User copyWith({String? address, String? name, String? role}) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      address: address ?? this.address,
    );
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      name: map['name'] as String,
      role: (map['role'] as String?) ?? 'user',
      address: (map['address'] as String?) ?? '',
    );
  }
}
