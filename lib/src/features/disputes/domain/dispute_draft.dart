import 'dart:typed_data';

enum DisputeType {
  paymentIssue,
  qualityOfWork,
  noShow,
  communicationIssue,
  other
}

enum EvidenceFileType { image, document }

abstract final class DisputeLimits {
  static const maxFiles = 5;
  static const maxMegabytes = 5;
  static const maxBytes = maxMegabytes * 1024 * 1024;
  static const descriptionLength = 1000;
  static const notesLength = 500;
  static const warningRatio = .9;
  static const reviewDays = '2–3';
}

class EvidenceFile {
  const EvidenceFile(
      {required this.localPathOrUrl,
      required this.fileName,
      required this.fileType,
      required this.bytes});
  final String localPathOrUrl, fileName;
  final EvidenceFileType fileType;
  final Uint8List bytes;
}

class DisputeDraft {
  const DisputeDraft(
      {required this.taskId,
      this.disputeType,
      this.againstUserId,
      this.againstName = '',
      this.againstRole = '',
      this.avatarUrl,
      this.subject = '',
      this.description = '',
      this.evidenceFiles = const [],
      this.additionalInfo = ''});
  final int taskId;
  final DisputeType? disputeType;
  final int? againstUserId;
  final String againstName, againstRole;
  final String? avatarUrl;
  final String subject, description, additionalInfo;
  final List<EvidenceFile> evidenceFiles;
  bool get isValid =>
      taskId > 0 &&
      againstUserId != null &&
      disputeType != null &&
      subject.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      description.length <= DisputeLimits.descriptionLength &&
      additionalInfo.length <= DisputeLimits.notesLength;
  bool get isDirty =>
      disputeType != null ||
      subject.isNotEmpty ||
      description.isNotEmpty ||
      evidenceFiles.isNotEmpty ||
      additionalInfo.isNotEmpty;
  DisputeDraft copyWith(
          {DisputeType? disputeType,
          String? subject,
          String? description,
          String? additionalInfo,
          List<EvidenceFile>? evidenceFiles}) =>
      DisputeDraft(
          taskId: taskId,
          disputeType: disputeType ?? this.disputeType,
          againstUserId: againstUserId,
          againstName: againstName,
          againstRole: againstRole,
          avatarUrl: avatarUrl,
          subject: subject ?? this.subject,
          description: description ?? this.description,
          additionalInfo: additionalInfo ?? this.additionalInfo,
          evidenceFiles:
              List.unmodifiable(evidenceFiles ?? this.evidenceFiles));
}
