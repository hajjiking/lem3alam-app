class NotificationPayload {
  const NotificationPayload({
    required this.notificationId,
    required this.type,
    required this.role,
    required this.targetId,
    required this.createdAt,
  });

  final String notificationId;
  final String type;
  final String role;
  final String targetId;
  final String createdAt;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        throw FormatException('Missing notification payload field: $key');
      }
      return value;
    }

    final role = requiredString('role').toLowerCase();
    if (role != 'client' && role != 'tasker') {
      throw FormatException('Unsupported notification role: $role');
    }

    return NotificationPayload(
      notificationId: requiredString('notification_id'),
      type: requiredString('type').toLowerCase(),
      role: role,
      targetId: requiredString('target_id'),
      createdAt: requiredString('created_at'),
    );
  }

  Map<String, String> toJson() => {
        'notification_id': notificationId,
        'type': type,
        'role': role,
        'target_id': targetId,
        'created_at': createdAt,
      };
}
