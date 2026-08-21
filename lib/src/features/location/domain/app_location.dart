import 'package:latlong2/latlong.dart';

class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;

  LatLng toLatLng() => LatLng(latitude, longitude);
}

