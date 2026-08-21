class AdminNearbyTaskSettings {
  const AdminNearbyTaskSettings({
    required this.defaultRadiusKm,
    required this.minRadiusKm,
    required this.maxRadiusKm,
    required this.refreshIntervalMinutes,
    required this.notificationMinUrgency,
    required this.notificationsEnabled,
  });

  final int defaultRadiusKm;
  final int minRadiusKm;
  final int maxRadiusKm;
  final int refreshIntervalMinutes;
  final String notificationMinUrgency;
  final bool notificationsEnabled;

  factory AdminNearbyTaskSettings.fromJson(Map<String, dynamic> json) {
    return AdminNearbyTaskSettings(
      defaultRadiusKm: _toInt(json['default_radius_km']),
      minRadiusKm: _toInt(json['min_radius_km']),
      maxRadiusKm: _toInt(json['max_radius_km']),
      refreshIntervalMinutes: _toInt(json['refresh_interval_minutes']),
      notificationMinUrgency: (json['notification_min_urgency'] ?? 'high').toString(),
      notificationsEnabled: json['notifications_enabled'] == true || json['notifications_enabled']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_radius_km': defaultRadiusKm,
      'min_radius_km': minRadiusKm,
      'max_radius_km': maxRadiusKm,
      'refresh_interval_minutes': refreshIntervalMinutes,
      'notification_min_urgency': notificationMinUrgency,
      'notifications_enabled': notificationsEnabled,
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

