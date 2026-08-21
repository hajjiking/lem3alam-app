import 'package:latlong2/latlong.dart';

class NearbyProvider {
  const NearbyProvider({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceKm;

  LatLng toLatLng() => LatLng(latitude, longitude);

  factory NearbyProvider.fromJson(Map<String, dynamic> json) {
    return NearbyProvider(
      id: _intRequired(json['id']),
      name: (json['name'] ?? '').toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0,
      distanceKm: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
    );
  }
}

int _intRequired(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

