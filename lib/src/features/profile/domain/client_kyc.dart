import 'dart:typed_data';

enum KycDocumentType {
  idCard('id_card'),
  passport('passport'),
  driverLicense('driver_license'),
  selfie('selfie'),
  addressProof('address_proof');

  const KycDocumentType(this.apiValue);
  final String apiValue;

  static KycDocumentType? fromApi(dynamic value) {
    final text = value?.toString();
    for (final type in values) {
      if (type.apiValue == text) return type;
    }
    return null;
  }
}

class KycDocument {
  const KycDocument({
    required this.id,
    required this.type,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final int id;
  final KycDocumentType type;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}') ?? 0;
    final type = KycDocumentType.fromApi(json['type']);
    if (id <= 0 || type == null) {
      throw const FormatException('Invalid KYC document');
    }
    return KycDocument(
      id: id,
      type: type,
      status: (json['status'] ?? '').toString(),
      submittedAt: DateTime.tryParse('${json['submitted_at'] ?? ''}'),
      reviewedAt: DateTime.tryParse('${json['reviewed_at'] ?? ''}'),
      rejectionReason: _optional(json['rejection_reason']),
    );
  }
}

class KycOverview {
  const KycOverview({
    required this.isVerified,
    required this.documents,
    this.verifiedAt,
  });

  final bool isVerified;
  final DateTime? verifiedAt;
  final List<KycDocument> documents;

  KycDocument? get latest => documents.isEmpty ? null : documents.first;

  factory KycOverview.fromJson(Map<String, dynamic> json) {
    final documents = <KycDocument>[];
    final raw = json['documents'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          documents.add(KycDocument.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ));
        }
      }
    }
    return KycOverview(
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      verifiedAt: DateTime.tryParse('${json['verified_at'] ?? ''}'),
      documents: List.unmodifiable(documents),
    );
  }
}

class KycSubmission {
  const KycSubmission({
    required this.type,
    required this.fileName,
    required this.bytes,
  });

  final KycDocumentType type;
  final String fileName;
  final Uint8List bytes;
}

String? _optional(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
