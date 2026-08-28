typedef ChatKey = ({int contactId, int? taskId});

class ConversationTaskContext {
  ConversationTaskContext.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as num).toInt(),
        title = (json['title'] ?? '').toString(),
        thumbnailUrl = json['thumbnail_url']?.toString(),
        location = json['location']?.toString(),
        budgetMin = num.tryParse('${json['budget_min']}'),
        budgetMax = num.tryParse('${json['budget_max']}');
  final int id;
  final String title;
  final String? thumbnailUrl, location;
  final num? budgetMin, budgetMax;
}

class ConversationModel {
  ConversationModel.fromJson(Map<String, dynamic> json)
      : contactId = (json['contact_id'] as num).toInt(),
        taskId = (json['task_id'] as num?)?.toInt(),
        contactName = (json['contact_name'] ?? '').toString(),
        contactRole = (json['contact_role'] ?? '').toString(),
        contactAvatarUrl = json['contact_avatar_url']?.toString(),
        isOnline = json['is_online'] as bool?,
        lastMessagePreview = (json['last_message_preview'] ?? '').toString(),
        lastMessageTime =
            DateTime.tryParse('${json['last_message_time']}')?.toLocal(),
        unreadCount = (json['unread_count'] as num?)?.toInt() ?? 0,
        relatedTask = json['related_task'] is Map<String, dynamic>
            ? ConversationTaskContext.fromJson(
                json['related_task'] as Map<String, dynamic>)
            : null;
  final int contactId;
  final int? taskId;
  final String contactName, contactRole, lastMessagePreview;
  final String? contactAvatarUrl;
  // Null means the server has no reliable presence information.
  final bool? isOnline;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final ConversationTaskContext? relatedTask;
  ChatKey get key => (contactId: contactId, taskId: taskId);
  String get id => '${taskId ?? 0}:$contactId';
}

enum MessageStatus { sent, delivered, read }

class ChatMessageModel {
  ChatMessageModel.fromJson(Map<String, dynamic> json, int userId)
      : id = (json['id'] as num).toInt(),
        senderId = (json['sender_id'] as num).toInt(),
        receiverId = (json['receiver_id'] as num).toInt(),
        taskId = (json['task_id'] as num?)?.toInt(),
        text = (json['content'] ?? '').toString(),
        sentAt = DateTime.parse(json['created_at'].toString()).toLocal(),
        isMe = json['sender_id'] == userId,
        status = MessageStatus.values.firstWhere(
            (s) => s.name == json['status'],
            orElse: () => MessageStatus.sent);
  final int id, senderId, receiverId;
  final int? taskId;
  final String text;
  final DateTime sentAt;
  final bool isMe;
  final MessageStatus status;
}
