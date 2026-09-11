class NotificationPayload {
  const NotificationPayload({
    required this.notificationId,
    required this.type,
    this.role,
    this.targetId,
    this.createdAt,
    this.taskId,
    this.applicationId,
    this.userId,
    this.conversationId,
    this.paymentId,
    this.disputeId,
  });

  final String notificationId;
  final String type;
  final String? role;
  final String? targetId;
  final String? createdAt;
  final int? taskId;
  final int? applicationId;
  final int? userId;
  final int? conversationId;
  final int? paymentId;
  final int? disputeId;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        throw FormatException('Missing notification payload field: $key');
      }
      return value;
    }

    final roleValue = json['role']?.toString().trim().toLowerCase();
    final role = roleValue == null || roleValue.isEmpty ? null : roleValue;
    if (role != null && role != 'client' && role != 'tasker') {
      throw FormatException('Unsupported notification role: $role');
    }

    String? optionalString(String key) {
      final value = json[key]?.toString().trim() ?? '';
      return value.isEmpty ? null : value;
    }

    int? optionalInt(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    return NotificationPayload(
      notificationId: requiredString('notification_id'),
      type: requiredString('type').toLowerCase(),
      role: role,
      targetId: optionalString('target_id'),
      createdAt: optionalString('created_at'),
      taskId: optionalInt('task_id'),
      applicationId: optionalInt('application_id'),
      userId: optionalInt('user_id') ??
          optionalInt('tasker_id') ??
          optionalInt('client_id'),
      conversationId:
          optionalInt('conversation_id') ?? optionalInt('chat_room_id'),
      paymentId: optionalInt('payment_id'),
      disputeId: optionalInt('dispute_id'),
    );
  }

  Map<String, String> toJson() => {
        'notification_id': notificationId,
        'type': type,
        if (role != null) 'role': role!,
        if (targetId != null) 'target_id': targetId!,
        if (createdAt != null) 'created_at': createdAt!,
        if (taskId != null) 'task_id': '$taskId',
        if (applicationId != null) 'application_id': '$applicationId',
        if (userId != null) 'user_id': '$userId',
        if (conversationId != null) 'conversation_id': '$conversationId',
        if (paymentId != null) 'payment_id': '$paymentId',
        if (disputeId != null) 'dispute_id': '$disputeId',
      };
}
