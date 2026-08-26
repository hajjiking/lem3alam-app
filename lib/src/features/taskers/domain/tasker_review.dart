class TaskerReview {
  const TaskerReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAtIso,
    required this.reviewerName,
    this.reviewerAvatar,
    this.taskTitle,
  });

  final int id;
  final int rating;
  final String comment;
  final String createdAtIso;
  final String reviewerName;
  final String? reviewerAvatar;
  final String? taskTitle;

  factory TaskerReview.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'];
    final task = json['task'];

    final translations = json['comment_translations'];
    String comment = (json['comment'] ?? '').toString();
    if (translations is Map) {
      comment = (translations['ar'] ??
              translations['en'] ??
              translations['fr'] ??
              comment)
          .toString();
    }

    return TaskerReview(
      id: _intRequired(json['id']),
      rating: _intRequired(json['rating']),
      comment: comment,
      createdAtIso: (json['created_at'] ?? '').toString(),
      reviewerName: reviewer is Map<String, dynamic>
          ? (reviewer['name'] ?? '').toString()
          : '',
      reviewerAvatar: reviewer is Map<String, dynamic>
          ? reviewer['profile_image']?.toString()
          : null,
      taskTitle:
          task is Map<String, dynamic> ? task['title']?.toString() : null,
    );
  }
}

int _intRequired(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}
