class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.isVerified,
    this.city,
    this.banReason,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final bool isVerified;
  final String? city;
  final String? banReason;

  bool get isBanned => banReason != null && banReason!.trim().isNotEmpty;
  bool get isSuspended => status == 'suspended';

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isVerified:
          json['is_verified'] == true || json['is_verified']?.toString() == '1',
      city: json['city']?.toString(),
      banReason: json['ban_reason']?.toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
