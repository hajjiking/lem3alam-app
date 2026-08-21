import '../../../core/networking/pagination.dart';
import 'task.dart';

class NearbyTaskSettings {
  const NearbyTaskSettings({
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

  factory NearbyTaskSettings.fromJson(Map<String, dynamic> json) {
    return NearbyTaskSettings(
      defaultRadiusKm: _intOr(json['default_radius_km'], 50),
      minRadiusKm: _intOr(json['min_radius_km'], 5),
      maxRadiusKm: _intOr(json['max_radius_km'], 100),
      refreshIntervalMinutes: _intOr(json['refresh_interval_minutes'], 15),
      notificationMinUrgency: (json['notification_min_urgency'] ?? 'high').toString(),
      notificationsEnabled: json['notifications_enabled'] == true || json['notifications_enabled']?.toString() == '1',
    );
  }
}

class NearbyTaskFeed {
  const NearbyTaskFeed({
    required this.page,
    required this.settings,
  });

  final Paginated<Task> page;
  final NearbyTaskSettings settings;
}

int _intOr(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

