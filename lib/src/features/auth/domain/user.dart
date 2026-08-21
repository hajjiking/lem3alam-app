class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.city,
    this.adminRole,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? city;
  final String? adminRole;

  bool get isClient => role == 'client';
  bool get isTasker => role == 'tasker';
  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      city: json['city']?.toString(),
      adminRole: json['admin_role']?.toString(),
    );
  }
}
