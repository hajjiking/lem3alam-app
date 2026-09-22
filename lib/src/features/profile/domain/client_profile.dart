import 'dart:typed_data';

class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.location,
    required this.status,
    required this.isVerified,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String location;
  final String status;
  final bool isVerified;
  final String? avatarUrl;

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    final id = _integer(json['id']);
    if (id == null || id <= 0) {
      throw const FormatException('Profile response has no valid user id');
    }
    return ClientProfile(
      id: id,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      location: (json['location'] ?? json['address'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isVerified: _boolean(json['is_verified']),
      avatarUrl: _optionalString(
        json['avatar_url'] ?? json['avatar'] ?? json['profile_image'],
      ),
    );
  }
}

class ClientAvatarFile {
  const ClientAvatarFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class ClientProfileUpdate {
  const ClientProfileUpdate({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });

  final String name;
  final String email;
  final String phone;
  final String location;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'location': location.trim(),
      };
}

int? _integer(dynamic value) => switch (value) {
      int number => number,
      num number => number.toInt(),
      _ => int.tryParse('$value'),
    };

bool _boolean(dynamic value) => switch (value) {
      true || 1 || '1' || 'true' => true,
      _ => false,
    };

String? _optionalString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
