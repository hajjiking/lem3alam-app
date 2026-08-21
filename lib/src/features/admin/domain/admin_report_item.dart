class AdminReportItem {
  const AdminReportItem({
    required this.id,
    required this.reason,
    required this.status,
    this.description,
    this.createdAtLabel,
  });

  final int id;
  final String reason;
  final String status;
  final String? description;
  final String? createdAtLabel;

  factory AdminReportItem.fromJson(Map<String, dynamic> json) {
    return AdminReportItem(
      id: _toInt(json['id']),
      reason: (json['reason'] ?? 'Report').toString(),
      status: (json['status'] ?? '').toString(),
      description: json['description']?.toString() ?? json['details']?.toString(),
      createdAtLabel: json['created_at']?.toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

