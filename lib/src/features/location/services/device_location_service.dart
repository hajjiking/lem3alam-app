import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationException implements Exception {
  const LocationException(this.code, {this.message});

  final String code;
  final String? message;

  @override
  String toString() => message == null ? code : '$code: $message';
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<void> ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('service_disabled');
    }
  }

  Future<void> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('permission_denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('permission_denied_forever');
    }
  }

  Future<Position> getCurrentPosition() async {
    await ensureServiceEnabled();
    await ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
