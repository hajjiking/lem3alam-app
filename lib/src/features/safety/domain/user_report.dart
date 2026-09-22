enum ReportReason {
  harassment('harassment'),
  spam('spam'),
  fraud('fraud'),
  inappropriateContent('inappropriate_content'),
  other('other');

  const ReportReason(this.apiValue);
  final String apiValue;
}

class UserReportDraft {
  const UserReportDraft({
    required this.reportedUserId,
    required this.reason,
    required this.details,
    this.taskId,
    this.messageId,
  });

  final int reportedUserId;
  final int? taskId;
  final int? messageId;
  final ReportReason reason;
  final String details;

  Map<String, dynamic> toJson() => {
        'reported_user_id': reportedUserId,
        if (taskId != null) 'task_id': taskId,
        if (messageId != null) 'message_id': messageId,
        'reason': reason.apiValue,
        'details': details.trim().isEmpty ? null : details.trim(),
      };
}

class SubmittedUserReport {
  const SubmittedUserReport({
    required this.id,
    required this.reportedUserId,
    required this.reason,
    required this.status,
  });

  final int id;
  final int reportedUserId;
  final String reason;
  final String status;

  factory SubmittedUserReport.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}') ?? 0;
    final reportedUserId = int.tryParse('${json['reported_user_id']}') ?? 0;
    if (id <= 0 || reportedUserId <= 0) {
      throw const FormatException('Invalid report response');
    }
    return SubmittedUserReport(
      id: id,
      reportedUserId: reportedUserId,
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}
