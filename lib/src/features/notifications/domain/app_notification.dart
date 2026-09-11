class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.taskId,
    this.applicationId,
    this.userId,
    this.conversationId,
    this.paymentId,
    this.disputeId,
    this.imageUrl,
    this.actionUrl,
    this.data = const {},
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? taskId;
  final int? applicationId;
  final int? userId;
  final int? conversationId;
  final int? paymentId;
  final int? disputeId;
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic> data;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final nested = _mapOrEmpty(json['data']);
    final sender = _mapOrEmpty(json['sender']);
    final assignedTasker = _mapOrEmpty(json['assigned_tasker']);
    final merged = <String, dynamic>{...nested, ...json};

    return AppNotification(
      id: _string(merged['id']),
      type: _string(merged['type'], fallback: 'system_announcement')
          .toLowerCase(),
      title: _string(merged['title']),
      message: _string(merged['message'] ?? merged['body']),
      isRead: _isRead(merged),
      createdAt: _date(merged['created_at']),
      taskId: _int(merged['task_id']),
      applicationId: _int(merged['application_id']),
      userId: _int(
        merged['user_id'] ??
            merged['tasker_id'] ??
            merged['client_id'] ??
            sender['id'] ??
            assignedTasker['id'],
      ),
      conversationId: _int(merged['conversation_id'] ??
          merged['chat_room_id'] ??
          merged['peer_id']),
      paymentId: _int(merged['payment_id'] ?? merged['transaction_id']),
      disputeId: _int(merged['dispute_id']),
      imageUrl: _nullableString(
          merged['image_url'] ?? sender['avatar_url'] ?? sender['avatar']),
      actionUrl: _nullableString(merged['action_url']),
      data: Map<String, dynamic>.unmodifiable(merged),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        taskId: taskId,
        applicationId: applicationId,
        userId: userId,
        conversationId: conversationId,
        paymentId: paymentId,
        disputeId: disputeId,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        data: data,
      );

  static bool _isRead(Map<String, dynamic> json) {
    if (json['read_at'] != null && _string(json['read_at']).isNotEmpty) {
      return true;
    }
    final value = json['is_read'] ?? json['read'];
    return value == true || value == 1 || value?.toString() == '1';
  }

  static DateTime _date(dynamic value) {
    final parsed = DateTime.tryParse(_string(value));
    return parsed?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_string(value));
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final string = value?.toString().trim() ?? '';
    return string.isEmpty ? fallback : string;
  }

  static String? _nullableString(dynamic value) {
    final string = _string(value);
    return string.isEmpty ? null : string;
  }

  static Map<String, dynamic> _mapOrEmpty(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.unreadCount,
  });

  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final int unreadCount;

  bool get hasNextPage => currentPage < lastPage;
}
